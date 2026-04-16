-- ==============================================================================
-- Behavior_LootNearby.lua
-- Anchored companion looting with protect-style combat interruption.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

pcall(require, "DC/Common/Colony/ColonyConfig/DC_ColonyConfig")
pcall(require, "DC/Common/Colony/ColonyRegistry/DC_ColonyRegistry")
pcall(require, "DC/Common/Colony/ColonyNetwork/DC_ColonyNetwork")
pcall(require, "DC/Common/Colony/Job/Scavenging/DC_Job_Scavenging_ConfigLogic")
pcall(require, "DC/Common/Colony/Job/Scavenging/DC_Job_Scavenging_ConfigData")
pcall(require, "DC/Common/Colony/Job/Scavenging/DC_Job_Scavenging_ConfigProfiles")

local LOOT_MOVE_SPEED = 0.045
local LOOT_STOP_DISTANCE = 1.15
local LOOT_VEHICLE_STOP_DISTANCE = 1.8
local LOOT_MOVE_STUCK_TICKS = 12
local LOOT_MOVE_ABORT_TICKS = 30
local LOOT_THREAT_RADIUS = 10
local LOOT_THREAT_LEASH_BONUS = 2
local LOOT_SYNC_COOLDOWN_MS = 1250

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

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function getDistance(ax, ay, bx, by)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dy = (tonumber(ay) or 0) - (tonumber(by) or 0)
    return math.sqrt((dx * dx) + (dy * dy))
end

local function normalizeLootConfig(npcData)
    local config = type(npcData and npcData.dcLootConfig) == "table" and npcData.dcLootConfig or {}
    return {
        radius = math.max(2, math.min(25, math.floor(tonumber(npcData and npcData.dcLootRadius or config.radius) or 10))),
        includeWorldContainers = config.includeWorldContainers ~= false,
        includeCorpseContainers = config.includeCorpseContainers ~= false,
        includeVehicleContainers = config.includeVehicleContainers ~= false,
        profileID = tostring(config.profileID or "") ~= "" and tostring(config.profileID) or nil,
        rawTags = type(config.rawTags) == "table" and config.rawTags or {},
    }
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

local function markLootContainerVisited(npcData, key)
    if not npcData or not key then
        return
    end

    npcData.dcLootVisited = type(npcData.dcLootVisited) == "table" and npcData.dcLootVisited or {}
    npcData.dcLootVisited[key] = true
end

local function isLootContainerVisited(npcData, key)
    return type(npcData and npcData.dcLootVisited) == "table" and npcData.dcLootVisited[key] == true
end

local function getColonyApis()
    local colony = DC_Colony or nil
    return {
        config = colony and colony.Config or nil,
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

local function addUniqueTag(result, seen, tag)
    local normalized = tostring(tag or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if normalized == "" or seen[normalized] then
        return
    end
    seen[normalized] = true
    result[#result + 1] = normalized
end

local function buildPresetTags(config, colonyConfig)
    local result = {}
    local seen = {}
    if not colonyConfig or not config or not config.profileID then
        return result
    end

    local profile = colonyConfig.GetScavengeSiteProfile and colonyConfig.GetScavengeSiteProfile(config.profileID) or nil
    local ruleWeights = type(profile and profile.ruleWeights) == "table" and profile.ruleWeights or nil
    for _, rule in ipairs(colonyConfig.ScavengeLootRules or {}) do
        local weight = ruleWeights and tonumber(ruleWeights[rule.id]) or 0
        if weight and weight > 0 then
            for _, tag in ipairs(rule.tags or {}) do
                addUniqueTag(result, seen, tag)
            end
        end
    end

    return result
end

local function buildLootFilterContext(npcData)
    local apis = getColonyApis()
    local colonyConfig = apis.config
    local config = normalizeLootConfig(npcData)
    local presetTags = buildPresetTags(config, colonyConfig)
    local rawTags = {}
    local seen = {}

    for _, tag in ipairs(config.rawTags or {}) do
        addUniqueTag(rawTags, seen, tag)
    end

    return {
        config = config,
        presetTags = presetTags,
        rawTags = rawTags,
        hasAnyFilter = (#presetTags > 0) or (#rawTags > 0),
        colonyConfig = colonyConfig,
        apis = apis,
    }
end

local function getItemTags(fullType, filterContext)
    local colonyConfig = filterContext and filterContext.colonyConfig or nil
    if colonyConfig and colonyConfig.GetItemCombinedTags then
        return colonyConfig.GetItemCombinedTags(fullType) or {}
    end
    if colonyConfig and colonyConfig.FindItemTags then
        return colonyConfig.FindItemTags(fullType) or {}
    end

    local masterList = DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.MasterList or nil
    local entry = masterList and masterList[fullType] or nil
    return type(entry and entry.tags) == "table" and entry.tags or {}
end

local function tagMatches(itemTags, queryTag, filterContext)
    local colonyConfig = filterContext and filterContext.colonyConfig or nil
    if colonyConfig and colonyConfig.HasMatchingTag then
        return colonyConfig.HasMatchingTag(itemTags, queryTag)
    end
    if DynamicTrading and DynamicTrading.Economy and DynamicTrading.Economy.Common and DynamicTrading.Economy.Common.HasMatchingTag then
        return DynamicTrading.Economy.Common.HasMatchingTag(itemTags, queryTag)
    end

    local normalizedQuery = tostring(queryTag or "")
    for _, itemTag in ipairs(itemTags or {}) do
        if itemTag == normalizedQuery or string.find(tostring(itemTag), normalizedQuery .. "%.") == 1 then
            return true
        end
    end
    return false
end

local function itemMatchesLootFilter(invItem, filterContext)
    if not invItem or not filterContext or not filterContext.hasAnyFilter then
        return false
    end

    local fullType = invItem.getFullType and invItem:getFullType() or nil
    if not fullType then
        return false
    end

    local itemTags = getItemTags(fullType, filterContext)
    for _, tag in ipairs(filterContext.rawTags or {}) do
        if tagMatches(itemTags, tag, filterContext) then
            return true
        end
    end
    for _, tag in ipairs(filterContext.presetTags or {}) do
        if tagMatches(itemTags, tag, filterContext) then
            return true
        end
    end
    return false
end

local function getInventoryItemQuantity(invItem)
    local count = invItem and invItem.getCount and tonumber(invItem:getCount()) or 1
    if count and count > 1 then
        return math.max(1, math.floor(count))
    end
    return 1
end

local function findMatchingItemRecursive(container, filterContext, worker, registry)
    if not container or not filterContext or not filterContext.hasAnyFilter then
        return nil, 0
    end

    local items = container.getItems and container:getItems() or nil
    if not items then
        return nil, 0
    end

    for index = 0, items:size() - 1 do
        local invItem = items:get(index)
        local nestedInventory = invItem and invItem.getInventory and invItem:getInventory() or nil
        if nestedInventory then
            local nestedItem, nestedQty = findMatchingItemRecursive(nestedInventory, filterContext, worker, registry)
            if nestedItem and nestedQty > 0 then
                return nestedItem, nestedQty
            end
        end

        if invItem and itemMatchesLootFilter(invItem, filterContext) then
            local requestedQty = getInventoryItemQuantity(invItem)
            local fitQty = registry and registry.GetFittingInventoryQuantity
                and registry.GetFittingInventoryQuantity(worker, invItem:getFullType(), requestedQty)
                or requestedQty
            if fitQty > 0 then
                return invItem, fitQty
            end
        end
    end

    return nil, 0
end

local function resolveLootTargetContainer(target)
    if type(target) ~= "table" then
        return nil
    end

    local cell = getCell and getCell() or nil
    if not cell then
        return nil
    end

    local square = cell:getGridSquare(tonumber(target.x) or 0, tonumber(target.y) or 0, tonumber(target.z) or 0)
    if not square then
        return nil
    end

    if target.kind == "world" then
        local objects = square:getObjects()
        if not objects then
            return nil
        end
        local object = objects:get(tonumber(target.objectIndex) or -1)
        if not object or not object.getContainerByIndex then
            return nil
        end
        return object:getContainerByIndex(tonumber(target.containerIndex) or 0)
    end

    if target.kind == "bag" then
        local worldObjects = square:getWorldObjects()
        if not worldObjects then
            return nil
        end
        local itemID = tonumber(target.itemID)
        for index = 0, worldObjects:size() - 1 do
            local worldObject = worldObjects:get(index)
            local item = worldObject and worldObject.getItem and worldObject:getItem() or nil
            if item and tonumber(item.getID and item:getID() or 0) == itemID then
                return item.getInventory and item:getInventory() or nil
            end
        end
        return nil
    end

    if target.kind == "corpse" then
        local staticObjects = square:getStaticMovingObjects()
        if not staticObjects then
            return nil
        end
        local objectID = tonumber(target.objectID)
        for index = 0, staticObjects:size() - 1 do
            local staticObject = staticObjects:get(index)
            if staticObject and tonumber(staticObject.getID and staticObject:getID() or 0) == objectID then
                return staticObject.getContainer and staticObject:getContainer() or nil
            end
        end
        return nil
    end

    if target.kind == "vehicle" then
        local vehicle = square:getVehicleContainer()
        if not vehicle then
            return nil
        end
        local part = vehicle:getPartByIndex(tonumber(target.partIndex) or -1)
        return part and part.getItemContainer and part:getItemContainer() or nil
    end

    return nil
end

local function canLootTarget(target)
    local container = resolveLootTargetContainer(target)
    if not container then
        return false
    end

    local items = container.getItems and container:getItems() or nil
    return items ~= nil and items:size() > 0
end

local function addCandidate(candidates, npcData, target)
    if not target or not target.key or isLootContainerVisited(npcData, target.key) then
        return
    end
    candidates[#candidates + 1] = target
end

local function buildLootCandidates(zombie, npcData, filterContext)
    local cell = getCell and getCell() or nil
    if not cell or not zombie or not npcData then
        return {}
    end

    local radius = filterContext.config.radius
    local anchorX = tonumber(npcData.dcLootAnchorX or npcData.anchorX or zombie:getX()) or zombie:getX()
    local anchorY = tonumber(npcData.dcLootAnchorY or npcData.anchorY or zombie:getY()) or zombie:getY()
    local anchorZ = tonumber(npcData.dcLootAnchorZ or npcData.anchorZ or zombie:getZ()) or zombie:getZ()
    local candidates = {}
    local seenVehicles = {}

    for y = math.floor(anchorY - radius), math.floor(anchorY + radius) do
        for x = math.floor(anchorX - radius), math.floor(anchorX + radius) do
            local square = cell:getGridSquare(x, y, anchorZ)
            if square then
                if filterContext.config.includeWorldContainers then
                    local worldObjects = square:getWorldObjects()
                    if worldObjects then
                        for index = 0, worldObjects:size() - 1 do
                            local worldObject = worldObjects:get(index)
                            local item = worldObject and worldObject.getItem and worldObject:getItem() or nil
                            local inventory = item and item.getInventory and item:getInventory() or nil
                            if item and inventory and lower(item.getCategory and item:getCategory() or "") == "container" then
                                addCandidate(candidates, npcData, {
                                    key = "bag:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(item:getID()),
                                    kind = "bag",
                                    x = x,
                                    y = y,
                                    z = anchorZ,
                                    itemID = item:getID(),
                                    distance = getDistance(anchorX, anchorY, x, y),
                                    stopDistance = LOOT_STOP_DISTANCE,
                                })
                            end
                        end
                    end

                    local objects = square:getObjects()
                    if objects then
                        for objectIndex = 0, objects:size() - 1 do
                            local object = objects:get(objectIndex)
                            local containerCount = object and object.getContainerCount and tonumber(object:getContainerCount()) or 0
                            for containerIndex = 0, math.max(0, containerCount - 1) do
                                local container = object and object.getContainerByIndex and object:getContainerByIndex(containerIndex) or nil
                                local items = container and container.getItems and container:getItems() or nil
                                if items and items:size() > 0 then
                                    addCandidate(candidates, npcData, {
                                        key = "world:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(objectIndex) .. ":" .. tostring(containerIndex),
                                        kind = "world",
                                        x = x,
                                        y = y,
                                        z = anchorZ,
                                        objectIndex = objectIndex,
                                        containerIndex = containerIndex,
                                        distance = getDistance(anchorX, anchorY, x, y),
                                        stopDistance = LOOT_STOP_DISTANCE,
                                    })
                                end
                            end
                        end
                    end
                end

                if filterContext.config.includeCorpseContainers then
                    local staticObjects = square:getStaticMovingObjects()
                    if staticObjects then
                        for index = 0, staticObjects:size() - 1 do
                            local staticObject = staticObjects:get(index)
                            local container = staticObject and staticObject.getContainer and staticObject:getContainer() or nil
                            local items = container and container.getItems and container:getItems() or nil
                            if items and items:size() > 0 then
                                addCandidate(candidates, npcData, {
                                    key = "corpse:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(staticObject:getID()),
                                    kind = "corpse",
                                    x = x,
                                    y = y,
                                    z = anchorZ,
                                    objectID = staticObject:getID(),
                                    distance = getDistance(anchorX, anchorY, x, y),
                                    stopDistance = LOOT_STOP_DISTANCE,
                                })
                            end
                        end
                    end
                end

                if filterContext.config.includeVehicleContainers then
                    local vehicle = square:getVehicleContainer()
                    if vehicle and not seenVehicles[vehicle] then
                        seenVehicles[vehicle] = true
                        local vehicleID = vehicle.getId and vehicle:getId()
                            or vehicle.getID and vehicle:getID()
                            or tostring(vehicle)
                        for partIndex = 0, vehicle:getPartCount() - 1 do
                            local vehiclePart = vehicle:getPartByIndex(partIndex)
                            local container = vehiclePart and vehiclePart.getItemContainer and vehiclePart:getItemContainer() or nil
                            local items = container and container.getItems and container:getItems() or nil
                            if items and items:size() > 0 then
                                addCandidate(candidates, npcData, {
                                    key = "vehicle:" .. tostring(vehicleID) .. ":" .. tostring(partIndex),
                                    kind = "vehicle",
                                    x = x,
                                    y = y,
                                    z = anchorZ,
                                    partIndex = partIndex,
                                    distance = getDistance(anchorX, anchorY, x, y),
                                    stopDistance = LOOT_VEHICLE_STOP_DISTANCE,
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        if math.abs((a.distance or 0) - (b.distance or 0)) > 0.05 then
            return (a.distance or 0) < (b.distance or 0)
        end
        return tostring(a.key or "") < tostring(b.key or "")
    end)

    return candidates
end

local function selectNextLootTarget(zombie, npcData, filterContext, worker, registry)
    local candidates = buildLootCandidates(zombie, npcData, filterContext)
    for _, candidate in ipairs(candidates) do
        local container = resolveLootTargetContainer(candidate)
        if container then
            local invItem, fitQty = findMatchingItemRecursive(container, filterContext, worker, registry)
            if invItem and fitQty > 0 then
                return candidate
            end
            markLootContainerVisited(npcData, candidate.key)
        end
    end
    return nil
end

local function stopLooting(zombie, npcData, notice, sentiment)
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

local function syncWorkerLootUpdate(worker, npcData, apis)
    local registry = apis and apis.registry or nil
    local network = apis and apis.network or nil
    if not worker or not registry then
        return
    end

    if registry.RecalculateWorker then
        registry.RecalculateWorker(worker)
    end
    if registry.Save then
        registry.Save()
    end

    local currentTime = nowMillis()
    if currentTime > 0 and (tonumber(npcData.dcLootLastWorkerSyncAt) or 0) > 0
        and (currentTime - tonumber(npcData.dcLootLastWorkerSyncAt or 0)) < LOOT_SYNC_COOLDOWN_MS then
        return
    end
    npcData.dcLootLastWorkerSyncAt = currentTime

    local synced = {}
    local usernames = {
        tostring(npcData and npcData.dcCommanderUsername or ""),
        tostring(worker.ownerUsername or ""),
    }
    for _, username in ipairs(usernames) do
        if username ~= "" and not synced[username] then
            synced[username] = true
            local player = findOnlinePlayer(username)
            if player and network and network.Internal then
                if network.Internal.syncWorkerDetail then
                    network.Internal.syncWorkerDetail(player, worker.workerID, nil, true)
                end
                if network.Internal.syncWorkerList then
                    network.Internal.syncWorkerList(player)
                end
            end
        end
    end
end

local function transferLootToWorker(zombie, npcData, worker, invItem, movedQty, filterContext)
    local apis = filterContext and filterContext.apis or getColonyApis()
    local registry = apis and apis.registry or nil
    local helpers = DynamicTrading and DynamicTrading.ServerHelpers or nil
    if not registry or not invItem or movedQty <= 0 then
        return false
    end

    local outputBuilder = registry.Internal and registry.Internal.BuildOutputEntryFromInventoryItem or nil
    local outputEntry = outputBuilder and outputBuilder(invItem) or {
        fullType = invItem:getFullType(),
        displayName = invItem.getDisplayName and invItem:getDisplayName() or invItem:getFullType(),
        qty = movedQty,
    }
    if not outputEntry or not outputEntry.fullType then
        return false
    end

    local availableQty = math.max(1, tonumber(outputEntry.qty) or getInventoryItemQuantity(invItem))
    local container = invItem.getContainer and invItem:getContainer() or nil
    outputEntry.qty = math.max(1, math.min(availableQty, math.floor(movedQty)))

    local storedQty = registry.AddOutputEntry and registry.AddOutputEntry(worker, outputEntry) or 0
    if storedQty <= 0 then
        return false
    end

    if helpers and helpers.RemoveItem then
        helpers.RemoveItem(invItem)
    elseif container and container.DoRemoveItem then
        container:DoRemoveItem(invItem)
    end

    if availableQty > storedQty and container then
        local customData = registry.Internal and registry.Internal.BuildOutputAddItemCustomData
            and registry.Internal.BuildOutputAddItemCustomData(outputEntry)
            or nil
        if helpers and helpers.AddItemWithCondition then
            helpers.AddItemWithCondition(container, outputEntry.fullType, availableQty - storedQty, customData)
        elseif container.AddItems then
            container:AddItems(outputEntry.fullType, availableQty - storedQty)
        end
    end

    syncWorkerLootUpdate(worker, npcData, apis)

    if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        local displayName = tostring(outputEntry.displayName or outputEntry.fullType or "loot")
        local countText = storedQty > 1 and ("x" .. tostring(storedQty) .. " ") or ""
        DTNPCProtect.PushCompanionNotice(zombie, npcData, "Grabbed " .. countText .. displayName .. ".", "positive")
    end

    npcData.dcLootStatus = "looting"
    return true
end

local function runLootCombat(zombie, npcData)
    if not zombie or not npcData or not DTNPCProtect then
        return false
    end

    local anchorTarget = DTNPCProtect.GetCombatAnchorTarget and DTNPCProtect.GetCombatAnchorTarget(npcData, zombie) or buildPointTarget(zombie:getX(), zombie:getY(), zombie:getZ())
    local engageRadius = tonumber(npcData.protectEngageRadius) or LOOT_THREAT_RADIUS
    local leashRadius = math.max(engageRadius + LOOT_THREAT_LEASH_BONUS, tonumber(npcData.dcLootRadius) or engageRadius)
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

local function moveToLootTarget(zombie, npcData, target)
    if not zombie or not npcData or not target then
        return false
    end

    local pointTarget = buildPointTarget(target.x, target.y, target.z)
    if not pointTarget then
        return false
    end

    local moved, moveState = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = pointTarget,
        speed = LOOT_MOVE_SPEED,
        stopDistance = tonumber(target.stopDistance) or LOOT_STOP_DISTANCE,
        allowObstacleInteract = true,
        allowDamageRetreat = true,
        blockCounterKey = "dcLootMoveBlockedTicks",
        stuckTicks = LOOT_MOVE_STUCK_TICKS,
        targetZ = target.z or 0,
        faceX = target.x,
        faceY = target.y,
        closeDoorSafeRadius = 2.5,
        anim = {
            animSpeed = 1.0,
            isRunning = false,
            dtWalkType = "Walk",
        },
    })

    if moved or moveState == "moving" or moveState == "unstuck" then
        npcData.isMovingState = true
        npcData.dcLootStatus = "moving"
        return false
    end

    if moveState == "arrived" or moveState == "close_enough" then
        npcData.isMovingState = false
        return true
    end

    if (tonumber(npcData.dcLootMoveBlockedTicks) or 0) >= LOOT_MOVE_ABORT_TICKS then
        markLootContainerVisited(npcData, target.key)
        clearLootTarget(npcData, "searching")
        if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
            DTNPCProtect.PushCompanionNotice(zombie, npcData, "Can't reach that container. Skipping it.", "warning")
        end
        if DTNPCMobility and DTNPCMobility.Stop then
            DTNPCMobility.Stop(zombie)
        end
        return false
    end

    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
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

    if npcData.dcLootAnchorX == nil or npcData.dcLootAnchorY == nil then
        npcData.dcLootAnchorX = npcData.anchorX or zombie:getX()
        npcData.dcLootAnchorY = npcData.anchorY or zombie:getY()
        npcData.dcLootAnchorZ = npcData.anchorZ or zombie:getZ()
    end
    npcData.anchorX = npcData.dcLootAnchorX
    npcData.anchorY = npcData.dcLootAnchorY
    npcData.anchorZ = npcData.dcLootAnchorZ

    local worker, apis = getLinkedWorker(npcData)
    local registry = apis and apis.registry or nil
    if not worker or not registry then
        stopLooting(zombie, npcData, "Looting isn't available right now.", "warning")
        return
    end

    if registry.GetInventoryRemainingCapacity and registry.GetInventoryRemainingCapacity(worker) <= 0 then
        stopLooting(zombie, npcData, "I'm full. Can't carry more loot.", "warning")
        return
    end

    local filterContext = buildLootFilterContext(npcData)
    if not filterContext.hasAnyFilter then
        stopLooting(zombie, npcData, "Set loot filters first.", "warning")
        return
    end

    filterContext.apis = apis

    if runLootCombat(zombie, npcData) then
        return
    end

    local target = type(npcData.dcLootTarget) == "table" and npcData.dcLootTarget or nil
    if target and (target.key ~= npcData.dcLootTargetKey or not canLootTarget(target)) then
        markLootContainerVisited(npcData, target.key)
        clearLootTarget(npcData, "searching")
        target = nil
    end

    if not target then
        target = selectNextLootTarget(zombie, npcData, filterContext, worker, registry)
        if not target then
            stopLooting(zombie, npcData, "Done looting nearby containers.", "positive")
            return
        end
        npcData.dcLootTarget = target
        npcData.dcLootTargetKey = target.key
        npcData.dcLootStatus = "searching"
    end

    local arrived = moveToLootTarget(zombie, npcData, target)
    if not arrived then
        return
    end

    local container = resolveLootTargetContainer(target)
    if not container then
        markLootContainerVisited(npcData, target.key)
        clearLootTarget(npcData, "searching")
        return
    end

    local invItem, fitQty = findMatchingItemRecursive(container, filterContext, worker, registry)
    if not invItem or fitQty <= 0 then
        markLootContainerVisited(npcData, target.key)
        clearLootTarget(npcData, "searching")
        return
    end

    local transferred = transferLootToWorker(zombie, npcData, worker, invItem, fitQty, filterContext)
    if not transferred then
        if registry.GetInventoryRemainingCapacity and registry.GetInventoryRemainingCapacity(worker) <= 0 then
            stopLooting(zombie, npcData, "I'm full. Can't carry more loot.", "warning")
            return
        end
        clearLootTarget(npcData, "searching")
        return
    end

    if registry.GetInventoryRemainingCapacity and registry.GetInventoryRemainingCapacity(worker) <= 0 then
        stopLooting(zombie, npcData, "I'm full. Can't carry more loot.", "warning")
        return
    end

    local nextItem = findMatchingItemRecursive(container, filterContext, worker, registry)
    if not nextItem then
        markLootContainerVisited(npcData, target.key)
        clearLootTarget(npcData, "searching")
    else
        npcData.dcLootStatus = "looting"
    end
end
