-- ==============================================================================
-- Behavior_Departure_Completion.lua
-- Departure completion and live-removal handling.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.Departure = DTNPCLogic.Internal.Departure or {}

local internal = DTNPCLogic.Internal.Departure

function internal.completeDeparture(zombie, npcData, reason)
    if npcData.removalRequested then
        return true
    end

    local uuid = npcData.uuid
    local travelHours = npcData.departureTravelHours or 0
    local returnTime = npcData.returnTime
    local nextStatus = npcData.returnStatus or npcData.requestedReturnStatus or "Resting"

    if returnTime == nil or returnTime <= 0 then
        returnTime = getGameTime():getWorldAgeHours() + travelHours
    end

    internal.stopDepartureAnimation(zombie, npcData)

    if not isClient() and DTNPCManager and DTNPCManager.CompleteLiveDeparture then
        return DTNPCManager.CompleteLiveDeparture(uuid, npcData, zombie, reason)
    end

    internal.clearDepartureRuntime(npcData)
    npcData.status = "Away"
    npcData.returnTime = returnTime
    npcData.returnStatus = nextStatus
    npcData.state = "Idle"

    if DynamicTrading_Roster and uuid then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end

    if isClient() and not isServer() then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Client suppressed departure removal for "
                .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
                .. " reason=" .. tostring(reason or "unknown")
                .. " because removal must be server-authoritative"
        )
        return false
    elseif DTNPCManager then
        DTNPCManager.RemoveData(uuid, "Away", returnTime, nextStatus)
        zombie:removeFromWorld()
        zombie:removeFromSquare()
    end

    return true
end
