-- ==============================================================================
-- DTNPC_ServerCoreArrival_Shared.lua
-- Shared helpers for DTNPC server arrival modules.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreArrival = DTNPCServerCoreArrival or {}
DTNPCServerCoreArrival.Internal = DTNPCServerCoreArrival.Internal or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreArrival.Internal

function Internal.GetCurrentHours()
    local gt = getGameTime and getGameTime() or nil
    return gt and gt:getWorldAgeHours() or 0
end

function Internal.CopyScalarOptions(source)
    local copy = {}
    local allowed = {
        "activationMode",
        "spawnPolicy",
        "targetUsername",
        "targetOnlineID",
        "targetX",
        "targetY",
        "targetZ",
        "minRadius",
        "maxRadius",
        "searchRadius",
        "status",
        "state",
        "returnTime",
        "returnStatus",
        "requestedReturnStatus",
        "combatOrder",
        "guardCombatOrder",
        "guardAttackMode",
        "invalidTargetBehavior",
    }
    local index = 1
    while index <= #allowed do
        local key = allowed[index]
        copy[key] = source[key]
        index = index + 1
    end
    copy.retryCount = math.max(0, tonumber(source.retryCount) or 0)
    return copy
end

function Internal.GetWalkHours()
    return tonumber(SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0) or 1.0
end

function Internal.SaveSoul(uuid, npcData)
    if uuid and npcData and DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end
end

function Internal.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
    if uuid and DynamicTrading_Roster and DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
    end
end

function Internal.ClearCombatAndTaskState(npcData)
    npcData.tasks = {}
    npcData.combatTargetID = nil
    npcData.combatOrder = nil
    npcData.guardCombatOrder = nil
    npcData.guardAttackMode = nil
    npcData.guardReturningToPost = nil
    npcData.anchorX = nil
    npcData.anchorY = nil
    npcData.anchorZ = nil
    npcData.stationaryPostX = nil
    npcData.stationaryPostY = nil
    npcData.stationaryPostZ = nil
    npcData.stationaryPostState = nil
end
