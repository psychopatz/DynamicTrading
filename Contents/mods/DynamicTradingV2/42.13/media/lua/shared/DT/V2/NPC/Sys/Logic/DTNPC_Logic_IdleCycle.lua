-- ==============================================================================
-- DTNPC_Logic_IdleCycle.lua
-- Idle cycle state tracking for stationary NPC postures.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}

local Internal = DTNPCLogic.Internal

local function getVariableBooleanSafe(zombie, name)
    if not zombie or not name then
        return false
    end

    if zombie.getVariableBoolean then
        return zombie:getVariableBoolean(name) == true
    end

    local value = zombie.getVariableString and zombie:getVariableString(name) or ""
    value = string.lower(tostring(value or ""))
    return value == "true" or value == "1"
end

local function getVariableStringSafe(zombie, name)
    if not zombie or not name or not zombie.getVariableString then
        return ""
    end

    local value = zombie:getVariableString(name)
    if value == nil then
        return ""
    end

    return tostring(value)
end

local function resolveMovingState(zombie, npcData)
    local bMoving = getVariableStringSafe(zombie, "bMoving")
    if bMoving ~= "" then
        return getVariableBooleanSafe(zombie, "bMoving")
    end

    local isMoving = getVariableStringSafe(zombie, "isMoving")
    if isMoving ~= "" then
        return getVariableBooleanSafe(zombie, "isMoving")
    end

    return npcData.isMovingState == true
end

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
        or state == "Bandage"

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

    local moving = resolveMovingState(zombie, npcData)

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
