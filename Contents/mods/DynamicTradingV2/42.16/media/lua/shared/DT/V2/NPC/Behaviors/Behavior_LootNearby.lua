-- ==============================================================================
-- Behavior_LootNearby.lua
-- Travel companion manual loot search behavior with protect-style combat interruption.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLootDebug = DTNPCLootDebug or {}

require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "DT/V2/NPC/LootSearch/DTNPC_LootSearch_Shared"
require "DT/V2/NPC/Behaviors/Behavior_AntiStuck"

pcall(require, "DC/Common/Colony/ColonyRegistry/DC_ColonyRegistry")
pcall(require, "DC/Common/Colony/ColonyNetwork/DC_ColonyNetwork")

local LOOT_THREAT_RADIUS = 10
local LOOT_THREAT_LEASH_BONUS = 2
local LOOT_DEBUG_ENABLED = true
local LOOT_DISCOVERY_DWELL_MS = 900
local LOOT_FORCE_PHASE_STALL_TICKS = 42
local LOOT_FORCE_PHASE_DISTANCE = 1.15
local LOOT_APPROACH_TIMEOUT_MS = 5000

local function buildPointTarget(x, y, z)
    if x == nil or y == nil then
        return nil
    end

    local px = tonumber(x)
    local py = tonumber(y)
    local pz = tonumber(z) or 0
    return {
        getX = function() return px end,
        getY = function() return py end,
        getZ = function() return pz end,
    }
end

local function getDistance(ax, ay, bx, by)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dy = (tonumber(ay) or 0) - (tonumber(by) or 0)
    return math.sqrt((dx * dx) + (dy * dy))
end

local function nowMillis()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor((tonumber(gameTime:getWorldAgeHours()) or 0) * 3600000)
    end
    return 0
end

local function lootDebugLog(npcData, worker, stage, message)
    if not LOOT_DEBUG_ENABLED then
        return
    end

    local name = tostring(npcData and npcData.name or worker and worker.name or "Unknown")
    local uuid = tostring(npcData and npcData.uuid or "nil")
    local workerID = tostring(worker and worker.workerID or npcData and npcData.linkedWorkerID or "nil")
    local text = "[DTV2 Loot Debug][" .. tostring(stage or "Trace") .. "][" .. name .. "][uuid=" .. uuid .. "][workerID=" .. workerID .. "] " .. tostring(message or "")
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTV2", "NPC", "LootDebug", text)
    else
        print(text)
    end
end

local function lootDebugLogChanged(npcData, worker, cacheKey, stage, message)
    if not LOOT_DEBUG_ENABLED then
        return
    end

    if not npcData then
        lootDebugLog(npcData, worker, stage, message)
        return
    end

    npcData.dcLootDebugMessages = npcData.dcLootDebugMessages or {}
    if npcData.dcLootDebugMessages[cacheKey] == message then
        return
    end

    npcData.dcLootDebugMessages[cacheKey] = message
    lootDebugLog(npcData, worker, stage, message)
end

local function normalizeLootConfig(npcData)
    local config = type(npcData and npcData.dcLootConfig) == "table" and npcData.dcLootConfig or {}
    return {
        radius = math.max(2, math.min(25, math.floor(tonumber(npcData and npcData.dcLootRadius or config.radius) or 10))),
        includeLooseWorldItems = config.includeLooseWorldItems ~= false,
        includeGroundContainers = config.includeGroundContainers ~= false,
        includeFurnitureContainers = config.includeFurnitureContainers ~= false,
        includeCorpseContainers = config.includeCorpseContainers ~= false,
        includeVehicleContainers = config.includeVehicleContainers ~= false,
    }
end

local function formatSourceConfigDebug(config)
    if type(config) ~= "table" then
        return "no-config"
    end

    return table.concat({
        "radius=" .. tostring(config.radius or "nil"),
        "groundItems=" .. tostring(config.includeLooseWorldItems ~= false),
        "groundBags=" .. tostring(config.includeGroundContainers ~= false),
        "furniture=" .. tostring(config.includeFurnitureContainers ~= false),
        "corpses=" .. tostring(config.includeCorpseContainers ~= false),
        "vehicles=" .. tostring(config.includeVehicleContainers ~= false),
    }, " ")
end

local function clearLootTarget(npcData, nextStatus)
    if not npcData then
        return
    end

    npcData.dcLootTarget = nil
    npcData.dcLootTargetKey = nil
    npcData.dcLootMoveBlockedTicks = 0
    npcData.isMovingState = false
    if nextStatus ~= nil then
        npcData.dcLootStatus = nextStatus
    end
end

local function getColonyApis()
    local colony = DC_Colony or nil
    return {
        registry = colony and colony.Registry or nil,
        network = colony and colony.Network or nil,
    }
end

local function getLinkedWorker(npcData)
    local apis = getColonyApis()
    local registry = apis.registry
    if not registry or not registry.GetWorker or not npcData or not npcData.linkedWorkerID then
        return nil, apis
    end

    return registry.GetWorker(npcData.linkedWorkerID), apis
end

local function buildDebugItemLootState(item, worker, registry)
    local quantity = math.max(1, math.floor(tonumber(item and item.quantity) or 1))
    if not item or not item.fullType then
        return false, "invalid", 0, quantity
    end
    if not worker or not registry or not registry.GetFittingInventoryQuantity then
        return true, "visible", quantity, quantity
    end

    local fitQty = registry.GetFittingInventoryQuantity(worker, item.fullType, quantity) or 0
    fitQty = math.max(0, tonumber(fitQty) or 0)
    if fitQty <= 0 then
        return false, "no-capacity", fitQty, quantity
    end
    if fitQty < quantity then
        return true, "lootable-partial", fitQty, quantity
    end
    return true, "lootable", fitQty, quantity
end

function DTNPCLootDebug.ScanNearbySources(player, npcData, radiusOverride)
    if not player then
        return {
            sources = {},
            totalSources = 0,
            totalItems = 0,
            radius = tonumber(radiusOverride) or 0,
            filterActive = false,
        }
    end

    local mockNpcData = type(npcData) == "table" and npcData or {}
    if radiusOverride ~= nil then
        mockNpcData = {}
        for key, value in pairs(type(npcData) == "table" and npcData or {}) do
            mockNpcData[key] = value
        end
        mockNpcData.dcLootRadius = radiusOverride
    end

    local worker, apis = getLinkedWorker(mockNpcData)
    local registry = apis and apis.registry or nil
    local config = normalizeLootConfig(mockNpcData)
    local rawSources = DTNPCLootSearch.ScanNearbySources(player, mockNpcData, false)
    local sources = {}
    local totalItems = 0

    for _, source in ipairs(rawSources or {}) do
        local debugItems = {}
        for _, item in ipairs(source.items or {}) do
            local lootable, lootReason, fitQty, requestedQty = buildDebugItemLootState(item, worker, registry)
            debugItems[#debugItems + 1] = {
                key = item.key,
                itemID = item.itemID,
                displayName = item.displayName,
                fullType = item.fullType,
                quantity = item.quantity,
                depth = 0,
                lootable = lootable,
                lootReason = lootReason,
                fitQty = fitQty,
                requestedQty = requestedQty,
            }
        end
        totalItems = totalItems + #debugItems
        sources[#sources + 1] = {
            key = source.key,
            kind = source.kind,
            label = source.label,
            x = source.x,
            y = source.y,
            z = source.z,
            distance = source.distance,
            items = debugItems,
        }
    end

    return {
        sources = sources,
        totalSources = #sources,
        totalItems = totalItems,
        radius = config.radius,
        center = {
            x = math.floor(player:getX()),
            y = math.floor(player:getY()),
            z = math.floor(player:getZ()),
        },
        filterActive = false,
        workerName = worker and worker.name or nil,
        workerID = worker and worker.workerID or nil,
    }
end

local function stopLooting(zombie, npcData, notice, sentiment)
    lootDebugLog(npcData, nil, "Stop", "Looting stopped. notice=" .. tostring(notice) .. " sentiment=" .. tostring(sentiment))
    if npcData then
        npcData.state = "Stay"
        npcData.dcLootStatus = notice and "idle" or npcData.dcLootStatus
        npcData.dcLootTarget = nil
        npcData.dcLootTargetKey = nil
        npcData.isMovingState = false
    end
    if DTNPCProtect and DTNPCProtect.ResetGuardedCombatState then
        DTNPCProtect.ResetGuardedCombatState(zombie, npcData, {
            clearAutoProtectState = true,
        })
    end
    if zombie and DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    end
    if notice and DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        DTNPCProtect.PushCompanionNotice(zombie, npcData, notice, sentiment or "neutral")
    end
end

local function runLootCombat(zombie, npcData)
    if not zombie or not npcData or not DTNPCProtect then
        return false
    end

    local anchorTarget = DTNPCProtect.GetCombatAnchorTarget and DTNPCProtect.GetCombatAnchorTarget(npcData, zombie) or buildPointTarget(zombie:getX(), zombie:getY(), zombie:getZ())
    local engageRadius = tonumber(npcData.protectEngageRadius) or LOOT_THREAT_RADIUS
    local lootRadius = tonumber(npcData.dcLootRadius) or engageRadius
    local leashRadius = math.max(engageRadius + LOOT_THREAT_LEASH_BONUS, lootRadius)
    local target, targetDist = DTNPCProtect.SelectNearestThreat(
        zombie,
        npcData,
        engageRadius,
        anchorTarget,
        leashRadius
    )

    if not target then
        if DTNPCProtect.ResetGuardedCombatState then
            DTNPCProtect.ResetGuardedCombatState(zombie, npcData, {
                clearAutoProtectState = true,
            })
        end
        npcData.dcLootStatus = npcData.dcLootStatus == "combat" and "searching" or npcData.dcLootStatus
        return false
    end

    local requestedState = npcData.combatOrder or "ProtectAuto"
    local resolvedState = DTNPCProtect.ResolveProtectState and DTNPCProtect.ResolveProtectState(npcData, requestedState) or requestedState
    if requestedState == "ProtectAuto" and DTNPCProtect.GetAutoProtectState then
        resolvedState = DTNPCProtect.GetAutoProtectState(npcData, targetDist)
    end

    npcData.autoProtectActiveState = resolvedState
    npcData.dcLootStatus = "combat"
    if DTNPCProtect.EnsureManualCombatControl then
        DTNPCProtect.EnsureManualCombatControl(zombie)
    end
    if DTNPCProtect.AnnounceCompanionCombatEngage then
        DTNPCProtect.AnnounceCompanionCombatEngage(zombie, npcData, "loot")
    end

    if resolvedState == "ProtectRanged" and DTNPCProtect.ExecuteGuardedRangedCombat then
        DTNPCProtect.ExecuteGuardedRangedCombat(zombie, npcData, target, targetDist, {
            mode = "loot",
            issuePrefix = "LootRanged",
            unavailableText = "Can't cover the loot. No usable firearm.",
            onRangedAttack = function(attackZombie, attackNpcData)
                if DTNPCProtect and DTNPCProtect.AnnounceCompanionRangedAttack then
                    DTNPCProtect.AnnounceCompanionRangedAttack(attackZombie, attackNpcData, "loot")
                end
            end,
        })
        return true
    end

    if resolvedState == "ProtectMelee" and DTNPCProtect.ExecuteGuardedMeleeCombat then
        local anchorX = anchorTarget and anchorTarget.getX and anchorTarget:getX() or zombie:getX()
        local anchorY = anchorTarget and anchorTarget.getY and anchorTarget:getY() or zombie:getY()
        local anchorZ = anchorTarget and anchorTarget.getZ and anchorTarget:getZ() or zombie:getZ()
        DTNPCProtect.ExecuteGuardedMeleeCombat(zombie, npcData, target, targetDist, {
            mode = "loot",
            issuePrefix = "LootMelee",
            unavailableText = "Can't defend the loot. No usable melee weapon.",
            blockedText = "Can't reach that threat from the looting area.",
            blockCounterKey = "lootCombatBlockedTicks",
            fallbackReach = 1.25,
            defaultSpeed = 0.05,
            enterBuffer = 0.25,
            holdBuffer = 0.45,
            stopBuffer = 0.16,
            debugLabel = "LootMeleeSwing",
            anchorX = anchorX,
            anchorY = anchorY,
            anchorZ = anchorZ,
            leashRadius = leashRadius,
        })
        return true
    end

    if DTNPCProtect.ReportCombatIssue then
        local text, sentiment = nil, nil
        if DTNPCProtect.BuildFallbackNotice then
            text, sentiment = DTNPCProtect.BuildFallbackNotice(requestedState, resolvedState)
        end
        DTNPCProtect.ReportCombatIssue(
            zombie,
            npcData,
            "LootNoLoadout",
            text or "No combat loadout ready to cover looting.",
            sentiment or "warning",
            "requested=" .. tostring(requestedState) .. " resolved=" .. tostring(resolvedState)
        )
    end
    return false
end

local function findOnlinePlayer(username)
    if not username or username == "" then
        return nil
    end

    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil
    if onlinePlayers then
        for index = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(index)
            if player and player.getUsername and player:getUsername() == username then
                return player
            end
        end
    end

    local localPlayer = getSpecificPlayer and getSpecificPlayer(0) or nil
    if localPlayer and localPlayer.getUsername and localPlayer:getUsername() == username then
        return localPlayer
    end

    return nil
end

local function getLootCommanderTarget(npcData, worker)
    local usernames = {
        tostring(npcData and npcData.dcCommanderUsername or ""),
        tostring(worker and worker.ownerUsername or ""),
    }

    for _, username in ipairs(usernames) do
        if username ~= "" then
            local player = findOnlinePlayer(username)
            if player then
                return player
            end
        end
    end

    return nil
end

local function updateLootFollowEscort(zombie, npcData, commander)
    if not zombie or not npcData or not commander then
        return nil
    end

    local dist = getDistance(zombie:getX(), zombie:getY(), commander:getX(), commander:getY())
    if DTNPCLogic and DTNPCLogic.Behaviors and DTNPCLogic.Behaviors["Follow"] then
        DTNPCLogic.Behaviors["Follow"](zombie, npcData, commander, dist)
    end
    return dist
end

local function resetLootAntiStuck(npcData)
    if DTNPCBehaviorAntiStuck and DTNPCBehaviorAntiStuck.Reset then
        DTNPCBehaviorAntiStuck.Reset(npcData, "LootNearby")
    end
end

local function beginLootInspection(npcData, sourceKey)
    if not npcData or not sourceKey then
        return false
    end

    local currentTime = nowMillis()
    if npcData.dcLootInspectSourceKey ~= sourceKey then
        npcData.dcLootInspectSourceKey = sourceKey
        npcData.dcLootInspectStartedAt = currentTime
        return false
    end

    return currentTime > 0 and (currentTime - (tonumber(npcData.dcLootInspectStartedAt) or 0)) >= LOOT_DISCOVERY_DWELL_MS
end

local function clearLootInspection(npcData, sourceKey)
    if not npcData then
        return
    end
    if sourceKey == nil or npcData.dcLootInspectSourceKey == sourceKey then
        npcData.dcLootInspectSourceKey = nil
        npcData.dcLootInspectStartedAt = nil
    end
end

local function trackLootApproach(npcData, sourceKey)
    if not npcData or not sourceKey then
        return
    end

    local currentTime = nowMillis()
    if npcData.dcLootApproachSourceKey ~= sourceKey then
        npcData.dcLootApproachSourceKey = sourceKey
        npcData.dcLootApproachStartedAt = currentTime
    elseif not npcData.dcLootApproachStartedAt or tonumber(npcData.dcLootApproachStartedAt) <= 0 then
        npcData.dcLootApproachStartedAt = currentTime
    end
end

local function clearLootApproach(npcData, sourceKey)
    if not npcData then
        return
    end
    if sourceKey == nil or npcData.dcLootApproachSourceKey == sourceKey then
        npcData.dcLootApproachSourceKey = nil
        npcData.dcLootApproachStartedAt = nil
    end
end

local function shouldTeleportLootApproach(npcData, sourceKey)
    if not npcData or not sourceKey or npcData.dcLootApproachSourceKey ~= sourceKey then
        return false
    end

    local currentTime = nowMillis()
    local startedAt = tonumber(npcData.dcLootApproachStartedAt) or 0
    return currentTime > 0 and startedAt > 0 and (currentTime - startedAt) >= LOOT_APPROACH_TIMEOUT_MS
end

local function teleportLootToSource(zombie, npcData, source)
    if not zombie or not npcData or not source then
        return false
    end

    local targetX = tonumber(source.approachX or source.x)
    local targetY = tonumber(source.approachY or source.y)
    local targetZ = tonumber(source.approachZ or source.z) or zombie:getZ()
    if targetX == nil or targetY == nil then
        return false
    end

    zombie:setX(targetX)
    zombie:setY(targetY)
    zombie:setZ(targetZ)
    zombie:faceLocation(tonumber(source.x) or targetX, tonumber(source.y) or targetY)
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    end

    npcData.lootSearchBlockedTicks = 0
    npcData.dcLootForcedPassageAt = nowMillis()
    clearLootApproach(npcData, source.key)
    return true
end

local function forceLootPassage(zombie, npcData, source)
    if not zombie or not npcData or not source then
        return false
    end

    local targetX = tonumber(source.approachX or source.x)
    local targetY = tonumber(source.approachY or source.y)
    local targetZ = tonumber(source.approachZ or source.z) or zombie:getZ()
    if targetX == nil or targetY == nil then
        return false
    end

    local faceX = tonumber(source.x) or targetX
    local faceY = tonumber(source.y) or targetY
    local dx = faceX - targetX
    local dy = faceY - targetY
    local len = math.sqrt((dx * dx) + (dy * dy))
    if len <= 0.001 then
        dx = targetX - zombie:getX()
        dy = targetY - zombie:getY()
        len = math.sqrt((dx * dx) + (dy * dy))
    end
    if len <= 0.001 then
        dx = 1
        dy = 0
        len = 1
    end

    dx = dx / len
    dy = dy / len

    zombie:setX(targetX + (dx * LOOT_FORCE_PHASE_DISTANCE))
    zombie:setY(targetY + (dy * LOOT_FORCE_PHASE_DISTANCE))
    zombie:setZ(targetZ)
    zombie:faceLocation(faceX, faceY)
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    end

    npcData.lootSearchBlockedTicks = 0
    npcData.dcLootForcedPassageAt = nowMillis()
    return true
end

local function tryRecoverLootMovement(zombie, npcData, source, moved, moveState)
    if not zombie or not npcData or not source or not DTNPCBehaviorAntiStuck or not DTNPCBehaviorAntiStuck.TryRecover then
        return false
    end

    local targetX = tonumber(source.approachX or source.x) or zombie:getX()
    local targetY = tonumber(source.approachY or source.y) or zombie:getY()
    local targetZ = tonumber(source.approachZ or source.z) or zombie:getZ()
    local currentDist = getDistance(zombie:getX(), zombie:getY(), targetX, targetY)

    local recovered = DTNPCBehaviorAntiStuck.TryRecover(zombie, npcData, {
        behaviorKey = "LootNearby",
        target = {
            getX = function() return targetX end,
            getY = function() return targetY end,
            getZ = function() return targetZ end,
        },
        currentDist = currentDist,
        moved = moved,
        moveState = moveState,
        blockCounterKey = "lootSearchBlockedTicks",
        blockedTicks = npcData.lootSearchBlockedTicks,
        blockedThreshold = 18,
        hardBlockedThreshold = 28,
        stallThreshold = 20,
        minDistance = 1.0,
        farDistance = 12.0,
        farStallThreshold = 30,
        cooldownTicks = 180,
        maxRecoveries = 2,
        arrivalRadius = 1.0,
        allowExactTarget = false,
        faceX = tonumber(source.x) or targetX,
        faceY = tonumber(source.y) or targetY,
    })

    if recovered then
        lootDebugLogChanged(npcData, nil, "loot_antistuck", "AntiStuck", "Recovered near source " .. tostring(source.label or source.key))
        npcData.dcLootForcePhaseUsed = nil
        return true
    end

    local blockedTicks = math.max(0, tonumber(npcData.lootSearchBlockedTicks) or 0)
    local currentTime = nowMillis()
    local lastForcedAt = tonumber(npcData.dcLootForcedPassageAt) or 0
    if blockedTicks >= LOOT_FORCE_PHASE_STALL_TICKS
        and (currentTime <= 0 or lastForcedAt <= 0 or (currentTime - lastForcedAt) >= 2500)
        and forceLootPassage(zombie, npcData, source) then
        npcData.dcLootForcePhaseUsed = true
        lootDebugLogChanged(npcData, nil, "loot_antistuck_phase", "AntiStuck", "Forced passage near source " .. tostring(source.label or source.key))
        return true
    end

    return false
end

DTNPCLogic.Behaviors["LootNearby"] = function(zombie, npcData)
    if not zombie or not npcData then
        return
    end

    if isClient() and not isServer() then
        return
    end

    DTNPCProtect.EnsureDataDefaults(npcData)
    clearLootTarget(npcData)

    local worker, apis = getLinkedWorker(npcData)
    local registry = apis and apis.registry or nil
    if not worker or not registry then
        lootDebugLog(npcData, worker, "Init", "Looting unavailable: worker=" .. tostring(worker ~= nil) .. " registry=" .. tostring(registry ~= nil))
        stopLooting(zombie, npcData, "Looting isn't available right now.", "warning")
        return
    end

    local debugSignature = table.concat({
        tostring(npcData.state or "nil"),
        tostring(npcData.dcLootStatus or "nil"),
        formatSourceConfigDebug(normalizeLootConfig(npcData)),
        "mode=manual_search_collect",
    }, " | ")
    if npcData.dcLootDebugSignature ~= debugSignature then
        npcData.dcLootDebugSignature = debugSignature
        lootDebugLog(npcData, worker, "Init", debugSignature)
    end

    if runLootCombat(zombie, npcData) then
        return
    end

    local commander = getLootCommanderTarget(npcData, worker)
    if not commander then
        npcData.dcLootStatus = "idle"
        return
    end

    local lootState = DTNPCLootSearch.EnsureState(npcData)

    local queuedSourceKey = DTNPCLootSearch.GetQueuedSourceKey(npcData)
    if queuedSourceKey then
        lootState.currentSourceKey = queuedSourceKey
        local queuedSource = DTNPCLootSearch.FindSourceByKey(commander, npcData, queuedSourceKey)
        if queuedSource then
            trackLootApproach(npcData, queuedSource.key)
            local moved, moveState = DTNPCLootSearch.MoveTowardSource(zombie, npcData, queuedSource)
            npcData.dcLootStatus = "collecting"
            if moveState == "arrived" or moveState == "close_enough" then
                clearLootApproach(npcData, queuedSource.key)
                clearLootInspection(npcData)
                resetLootAntiStuck(npcData)
                local collectedCount = DTNPCLootSearch.TryCollectQueuedItems(zombie, npcData, worker, apis, queuedSource)
                DTNPCLootSearch.SendSyncToCommander(npcData, worker, queuedSource.key, true)
                npcData.dcLootStatus = collectedCount > 0 and "looting" or "collecting"
            elseif moved or moveState == "damage_retreat" or (moveState and string.find(tostring(moveState), "interacted_", 1, true)) then
                clearLootInspection(npcData)
                resetLootAntiStuck(npcData)
                lootDebugLogChanged(npcData, worker, "collect_target", "Collect", "Moving to collect from " .. tostring(queuedSource.label or queuedSource.key))
            elseif shouldTeleportLootApproach(npcData, queuedSource.key) and teleportLootToSource(zombie, npcData, queuedSource) then
                clearLootInspection(npcData)
                resetLootAntiStuck(npcData)
                lootDebugLogChanged(npcData, worker, "collect_teleport", "Collect", "Teleported to collect source " .. tostring(queuedSource.label or queuedSource.key))
            elseif tryRecoverLootMovement(zombie, npcData, queuedSource, moved, moveState) then
                clearLootInspection(npcData)
                resetLootAntiStuck(npcData)
            end
            return
        end
        lootState.currentSourceKey = nil
    end

    local searchSource = nil
    if lootState.currentSourceKey and not lootState.searchedSources[lootState.currentSourceKey] then
        searchSource = DTNPCLootSearch.FindSourceByKey(commander, npcData, lootState.currentSourceKey)
    end
    if not searchSource then
        searchSource = DTNPCLootSearch.SelectNextUndiscoveredSource(commander, npcData)
        lootState.currentSourceKey = searchSource and searchSource.key or nil
    end

    if searchSource then
        trackLootApproach(npcData, searchSource.key)
        local moved, moveState = DTNPCLootSearch.MoveTowardSource(zombie, npcData, searchSource)
        npcData.dcLootStatus = "searching"
        if moveState == "arrived" or moveState == "close_enough" then
            clearLootApproach(npcData, searchSource.key)
            resetLootAntiStuck(npcData)
            if beginLootInspection(npcData, searchSource.key) then
                local discovered = DTNPCLootSearch.DiscoverSource(npcData, searchSource)
                clearLootInspection(npcData, searchSource.key)
                lootState.currentSourceKey = nil
                npcData.dcLootStatus = "found"
                if discovered then
                    DTNPCLootSearch.SendSyncToCommander(npcData, worker, searchSource.key, true)
                    lootDebugLogChanged(npcData, worker, "discover_source", "Discover", "Discovered source " .. tostring(searchSource.label or searchSource.key) .. " items=" .. tostring(#(searchSource.items or {})))
                end
            else
                npcData.dcLootStatus = "inspecting"
                lootDebugLogChanged(npcData, worker, "inspect_wait", "Search", "Inspecting source " .. tostring(searchSource.label or searchSource.key) .. " before reveal")
            end
        elseif moved or moveState == "damage_retreat" or (moveState and string.find(tostring(moveState), "interacted_", 1, true)) then
            clearLootInspection(npcData, searchSource.key)
            resetLootAntiStuck(npcData)
            lootDebugLogChanged(npcData, worker, "search_target", "Search", "Inspecting source " .. tostring(searchSource.label or searchSource.key))
        elseif shouldTeleportLootApproach(npcData, searchSource.key) and teleportLootToSource(zombie, npcData, searchSource) then
            clearLootInspection(npcData, searchSource.key)
            resetLootAntiStuck(npcData)
            lootDebugLogChanged(npcData, worker, "search_teleport", "Search", "Teleported to source " .. tostring(searchSource.label or searchSource.key))
        elseif tryRecoverLootMovement(zombie, npcData, searchSource, moved, moveState) then
            clearLootInspection(npcData, searchSource.key)
            resetLootAntiStuck(npcData)
        end
        return
    end

    clearLootInspection(npcData)
    clearLootApproach(npcData)
    resetLootAntiStuck(npcData)
    lootState.currentSourceKey = nil

    local followDist = updateLootFollowEscort(zombie, npcData, commander)
    npcData.dcLootStatus = (followDist and followDist > 2.0) and "following" or "idle"
end
