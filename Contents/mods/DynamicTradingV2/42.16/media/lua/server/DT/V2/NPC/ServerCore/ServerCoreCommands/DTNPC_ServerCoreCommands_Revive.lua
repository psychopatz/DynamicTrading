-- ==============================================================================
-- DTNPC_ServerCoreCommands_Revive.lua
-- Revive command handlers for incapacitated NPC recovery.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreCommands = DTNPCServerCoreCommands or {}
DTNPCServerCoreCommands.Internal = DTNPCServerCoreCommands.Internal or {}
DTNPCServerCoreCommands.Handlers = DTNPCServerCoreCommands.Handlers or {}
DTNPCServerCoreControl = DTNPCServerCoreControl or {}
DTNPCServerCoreControl.Internal = DTNPCServerCoreControl.Internal or {}

if isClient() and not isServer() then return end

local Handlers = DTNPCServerCoreCommands.Handlers

local function formatReviveItemLabel(fullType)
    local raw = tostring(fullType or "")
    local label = raw:match("^[^%.]+%.(.+)$") or raw
    label = label:gsub("(%l)(%u)", "%1 %2")
    label = label:gsub("Sheets", "Sheets")
    if label == "" then
        return "bandages or rags"
    end
    return label
end

local function sendReviveResult(playerObj, payload)
    if not playerObj or not DynamicTrading or not DynamicTrading.ServerHelpers or not DynamicTrading.ServerHelpers.SendResponse then
        return false
    end

    DynamicTrading.ServerHelpers.SendResponse(playerObj, "DTNPC", "ReviveResult", payload)
    return true
end

local function getReviveTarget(uuid)
    if not uuid or not DTNPCServerCore.GetNPCDataByUUID then
        return nil, nil
    end
    return DTNPCServerCore.GetNPCDataByUUID(uuid)
end

local function setPlayerReviveLease(npcData, playerObj, durationMs)
    if type(npcData) ~= "table" then
        return false
    end

    if type(npcData.reviveData) ~= "table" then
        npcData.reviveData = {}
    end

    local now = DTNPCHealth
        and DTNPCHealth.Internal
        and DTNPCHealth.Internal.nowMillis
        and DTNPCHealth.Internal.nowMillis()
        or (getTimeInMillis and getTimeInMillis() or 0)
    local reviveData = npcData.reviveData
    reviveData.playerReviveLeaseUntil = now + math.max(1000, math.floor(tonumber(durationMs) or 5000))
    reviveData.playerReviveLeaseUsername = playerObj and playerObj.getUsername and playerObj:getUsername() or nil
    reviveData.playerReviveLeaseOnlineID = playerObj and playerObj.getOnlineID and playerObj:getOnlineID() or nil
    return true
end

local function clearPlayerReviveLease(npcData, playerObj)
    local reviveData = type(npcData) == "table" and type(npcData.reviveData) == "table" and npcData.reviveData or nil
    if not reviveData then
        return false
    end

    local username = playerObj and playerObj.getUsername and playerObj:getUsername() or nil
    local onlineID = playerObj and playerObj.getOnlineID and playerObj:getOnlineID() or nil
    if reviveData.playerReviveLeaseUsername ~= nil
        and username ~= nil
        and tostring(reviveData.playerReviveLeaseUsername) ~= tostring(username) then
        return false
    end
    if reviveData.playerReviveLeaseOnlineID ~= nil
        and onlineID ~= nil
        and tonumber(reviveData.playerReviveLeaseOnlineID) ~= tonumber(onlineID) then
        return false
    end

    reviveData.playerReviveLeaseUntil = nil
    reviveData.playerReviveLeaseUsername = nil
    reviveData.playerReviveLeaseOnlineID = nil
    return true
end

local function isWithinReviveRange(playerObj, zombie)
    if not playerObj or not zombie then
        return false
    end

    local dz = math.abs((playerObj:getZ() or 0) - (zombie:getZ() or 0))
    if dz > 1 then
        return false
    end

    local dx = playerObj:getX() - zombie:getX()
    local dy = playerObj:getY() - zombie:getY()
    local distance = math.sqrt((dx * dx) + (dy * dy))
    return distance <= (tonumber(DTNPCHealth and DTNPCHealth.REVIVE_INTERACT_RANGE) or 3.5)
end

local function awardReviveReputation(playerObj, npcData)
    if not playerObj then
        return false
    end

    local amount = tonumber(DTNPCHealth and DTNPCHealth.REVIVE_REPUTATION_REWARD) or 5
    if isServer() then
        return DynamicTrading
            and DynamicTrading.ServerHelpers
            and DynamicTrading.ServerHelpers.SendReputationSync
            and DynamicTrading.ServerHelpers.SendReputationSync(playerObj, {
                action = "personalRepDelta",
                traderUUID = npcData and npcData.uuid or nil,
                factionID = npcData and npcData.factionID or nil,
                amount = amount,
                reason = "revive_success",
            })
            or false
    end

    if DT_Reputation and DT_Reputation.ModifyPersonalRep then
        DT_Reputation.ModifyPersonalRep(
            npcData and npcData.uuid or nil,
            npcData and npcData.factionID or nil,
            amount,
            "revive_success"
        )
        return true
    end

    return false
end

local function getNearestActivePlayer(zombie)
    if not zombie or not DTNPCManager or not DTNPCManager.GetActivePlayers then
        return nil
    end

    local bestPlayer = nil
    local bestDist = nil
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()

    for _, playerObj in ipairs(DTNPCManager.GetActivePlayers()) do
        if playerObj and math.abs((playerObj:getZ() or 0) - zz) <= 1 then
            local dx = zx - playerObj:getX()
            local dy = zy - playerObj:getY()
            local dist = math.sqrt((dx * dx) + (dy * dy))
            if not bestDist or dist < bestDist then
                bestDist = dist
                bestPlayer = playerObj
            end
        end
    end

    return bestPlayer, bestDist
end

local function computeReviveEscapeTarget(zombie, npcData)
    if not zombie then
        return nil, nil, nil
    end

    local targetDist = tonumber(DTNPCHealth and DTNPCHealth.REVIVE_ESCAPE_TARGET_DIST) or 20
    local nearestPlayer = getNearestActivePlayer(zombie)
    local dirX = tonumber(npcData and npcData.lastFleeX) or 0
    local dirY = tonumber(npcData and npcData.lastFleeY) or 0

    if nearestPlayer then
        dirX = zombie:getX() - nearestPlayer:getX()
        dirY = zombie:getY() - nearestPlayer:getY()
    end

    local len = math.sqrt((dirX * dirX) + (dirY * dirY))
    if len <= 0.001 then
        dirX = 1
        dirY = 0
        len = 1
    end

    dirX = dirX / len
    dirY = dirY / len

    return zombie:getX() + (dirX * targetDist), zombie:getY() + (dirY * targetDist), zombie:getZ()
end

local function startReviveDeparture(uuid, zombie, npcData)
    local nextStatus = "Resting"
    local walkHours = SandboxVars
        and SandboxVars.DynamicTrading
        and SandboxVars.DynamicTrading.NPCTradingWalkHours
        or 1.0
    local home = npcData and npcData.homeCoords or nil

    if home and home.x ~= nil and home.y ~= nil
        and DTNPCManager and DTNPCManager.StartLiveDepartureFromBody
        and DTNPCManager.StartLiveDepartureFromBody(
            uuid,
            zombie,
            npcData,
            nextStatus,
            walkHours,
            home.x,
            home.y,
            home.z or 0,
            "revive_home"
        ) then
        return true, "live_departure"
    end

    local targetX, targetY, targetZ = computeReviveEscapeTarget(zombie, npcData)
    if targetX and DTNPCManager and DTNPCManager.StartLiveDepartureFromBody
        and DTNPCManager.StartLiveDepartureFromBody(
            uuid,
            zombie,
            npcData,
            nextStatus,
            walkHours,
            targetX,
            targetY,
            targetZ or 0,
            "revive_escape"
        ) then
        return true, "escape_departure"
    end

    return false, "departure_failed"
end

Handlers.ReviveRequest = function(playerObj, args)
    local uuid = args and args.uuid or nil
    local requiredFullType = args and args.requiredFullType ~= nil and tostring(args.requiredFullType) or nil
    if not playerObj or not uuid then
        return
    end

    local zombie, npcData = getReviveTarget(uuid)
    if not zombie or not npcData then
        sendReviveResult(playerObj, {
            success = false,
            uuid = uuid,
            message = "They're no longer here.",
            reason = "missing_target",
        })
        return
    end

    if not isWithinReviveRange(playerObj, zombie) then
        sendReviveResult(playerObj, {
            success = false,
            uuid = uuid,
            message = "Move closer before trying to help.",
            reason = "out_of_range",
        })
        return
    end

    local canRevive = false
    local info = nil
    if DTNPCHealth and DTNPCHealth.CanPlayerRevive then
        canRevive, info = DTNPCHealth.CanPlayerRevive(playerObj, npcData, {
            requiredFullType = requiredFullType,
        })
    end
    if not canRevive then
        local reason = info and info.reason or "revive_rejected"
        local message = "You can't help them right now."
        if reason == "need_supplies" then
            local itemLabel = formatReviveItemLabel(requiredFullType)
            message = "You need " .. tostring(info.requiredCount or "?") .. " " .. tostring(itemLabel) .. " to revive them."
        elseif reason == "already_helped" then
            message = "Someone is already helping them."
        elseif reason == "excluded_target" then
            message = "They won't accept your help."
        elseif reason == "not_incapacitated" then
            message = "They are no longer incapacitated."
        end
        sendReviveResult(playerObj, {
            success = false,
            uuid = uuid,
            message = message,
            reason = reason,
            requiredCount = info and info.requiredCount or nil,
            availableCount = info and info.availableCount or nil,
            requiredFullType = requiredFullType,
        })
        return
    end

    local revived, result = DTNPCHealth.TryReviveNPC(zombie, npcData, playerObj, {
        deferSync = true,
        requiredFullType = requiredFullType,
    })
    if not revived then
        clearPlayerReviveLease(npcData, playerObj)
        sendReviveResult(playerObj, {
            success = false,
            uuid = uuid,
            message = "The revive failed.",
            reason = result and result.reason or "revive_failed",
            requiredCount = result and result.requiredCount or nil,
            availableCount = result and result.availableCount or nil,
            requiredFullType = requiredFullType,
        })
        return
    end

    awardReviveReputation(playerObj, npcData)
    local departed, departureMode = startReviveDeparture(uuid, zombie, npcData)
    if not departed and DTNPCHealth and DTNPCHealth.RequestSync then
        DTNPCHealth.RequestSync(zombie, npcData, true)
    end

    sendReviveResult(playerObj, {
        success = true,
        uuid = uuid,
        message = "They should make it home from here.",
        reason = "revive_success",
        requiredCount = result and result.requiredCount or nil,
        consumedCount = result and result.consumedCount or nil,
        reputationAwarded = tonumber(DTNPCHealth and DTNPCHealth.REVIVE_REPUTATION_REWARD) or 5,
        departureMode = departureMode,
        requiredFullType = requiredFullType,
    })
end

Handlers.ReviveStart = function(playerObj, args)
    local uuid = args and args.uuid or nil
    if not playerObj or not uuid then
        return
    end

    local zombie, npcData = getReviveTarget(uuid)
    if not zombie or not npcData or not isWithinReviveRange(playerObj, zombie) then
        return
    end

    local canRevive = DTNPCHealth and DTNPCHealth.CanPlayerRevive and DTNPCHealth.CanPlayerRevive(playerObj, npcData, {
        ignoreItems = true,
    }) or false
    if canRevive then
        setPlayerReviveLease(npcData, playerObj, tonumber(args.durationMs) or 8000)
        if DTNPCHealth.RequestSync then
            DTNPCHealth.RequestSync(zombie, npcData, false)
        end
    end
end

Handlers.ReviveCancel = function(playerObj, args)
    local uuid = args and args.uuid or nil
    if not playerObj or not uuid then
        return
    end

    local zombie, npcData = getReviveTarget(uuid)
    if not npcData then
        return
    end

    if clearPlayerReviveLease(npcData, playerObj) and zombie and DTNPCHealth and DTNPCHealth.RequestSync then
        DTNPCHealth.RequestSync(zombie, npcData, false)
    end
end
