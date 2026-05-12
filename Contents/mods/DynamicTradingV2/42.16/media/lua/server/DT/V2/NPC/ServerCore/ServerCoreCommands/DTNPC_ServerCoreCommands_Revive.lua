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
local ControlInternal = DTNPCServerCoreControl.Internal

local function sendReviveResult(playerObj, payload)
    if not playerObj or not DynamicTrading or not DynamicTrading.ServerHelpers or not DynamicTrading.ServerHelpers.SendResponse then
        return false
    end

    DynamicTrading.ServerHelpers.SendResponse(playerObj, "DTNPC", "ReviveResult", payload)
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

local function startReviveDeparture(uuid, zombie, npcData)
    local nextStatus = "Resting"
    local walkHours = SandboxVars
        and SandboxVars.DynamicTrading
        and SandboxVars.DynamicTrading.NPCTradingWalkHours
        or 1.0
    local home = npcData and npcData.homeCoords or nil

    if home and DTNPCManager and DTNPCManager.TryStartLiveDeparture
        and DTNPCManager.TryStartLiveDeparture(uuid, nextStatus, walkHours, home.x, home.y, home.z or 0) then
        return true, "live_departure"
    end

    local currentHours = getGameTime() and getGameTime():getWorldAgeHours() or 0
    local returnTime = currentHours + walkHours
    if ControlInternal and ControlInternal.RemoveLiveNPCToStatus then
        ControlInternal.RemoveLiveNPCToStatus(uuid, zombie, npcData, "Away", returnTime, nextStatus)
        return true, "safe_remove"
    end

    return false, "departure_failed"
end

Handlers.ReviveRequest = function(playerObj, args)
    local uuid = args and args.uuid or nil
    if not playerObj or not uuid then
        return
    end

    local zombie = nil
    local npcData = nil
    if DTNPCServerCore.GetNPCDataByUUID then
        zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(uuid)
    end
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
        canRevive, info = DTNPCHealth.CanPlayerRevive(playerObj, npcData)
    end
    if not canRevive then
        local reason = info and info.reason or "revive_rejected"
        local message = "You can't help them right now."
        if reason == "need_supplies" then
            message = "You need " .. tostring(info.requiredCount or "?") .. " bandages or rags to revive them."
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
        })
        return
    end

    local revived, result = DTNPCHealth.TryReviveNPC(zombie, npcData, playerObj, {
        deferSync = true,
    })
    if not revived then
        sendReviveResult(playerObj, {
            success = false,
            uuid = uuid,
            message = "The revive failed.",
            reason = result and result.reason or "revive_failed",
            requiredCount = result and result.requiredCount or nil,
            availableCount = result and result.availableCount or nil,
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
    })
end
