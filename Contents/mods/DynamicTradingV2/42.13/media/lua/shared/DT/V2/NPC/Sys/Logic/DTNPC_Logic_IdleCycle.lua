-- ==============================================================================
-- DTNPC_Logic_IdleCycle.lua
-- Idle cycle state tracking for stationary NPC postures.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}

local Internal = DTNPCLogic.Internal

function DTNPCLogic.ResetIdleCycle(zombie, npcData)
    npcData.idleCycleCounter = 0
    npcData.idleCycleIndex = 0
    zombie:setVariable("DTIdleState", "0")
end

function DTNPCLogic.UpdateIdleCycle(zombie, npcData, state)
    local isIdleCycleState = state == "Idle"
        or state == "Stay"
        or state == "Guard"
        or state == "Trading"

    if not isIdleCycleState then
        DTNPCLogic.ResetIdleCycle(zombie, npcData)
        return
    end

    local forcedIdleState = DTNPCLogic.Stationary.GetDesiredIdleState(zombie, npcData)
    if forcedIdleState then
        npcData.idleCycleCounter = 0
        npcData.idleCycleIndex = tonumber(forcedIdleState) or 0
        zombie:setVariable("DTIdleState", forcedIdleState)
        return
    end

    if npcData.idleCycleIndex == nil then
        npcData.idleCycleIndex = 0
    end
    if not npcData.idleCycleCounter then
        npcData.idleCycleCounter = 0
    end

    local moving = zombie:isMoving() or (npcData.isMovingState == true)
    if moving then
        DTNPCLogic.ResetIdleCycle(zombie, npcData)
        return
    end

    npcData.idleCycleCounter = npcData.idleCycleCounter + 1
    if npcData.idleCycleCounter >= Internal.IDLE_CYCLE_TICKS then
        npcData.idleCycleCounter = 0
        npcData.idleCycleIndex = (npcData.idleCycleIndex + 1) % Internal.IDLE_STATE_COUNT
        zombie:setVariable("DTIdleState", tostring(npcData.idleCycleIndex))
    end
end
