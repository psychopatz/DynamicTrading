-- ==============================================================================
-- DTNPC_Data_EngineState.lua
-- Character flag and zombie engine suppression helpers.
-- ==============================================================================

DTNPC = DTNPC or {}

local function isStationaryState(state)
    return state == "Stay" or state == "Guard" or state == "Idle" or state == "Trading" or state == "Bandage"
end

local function isManualControlState(state)
    if isStationaryState(state) then
        return true
    end

    return state == "GoTo"
        or state == "Flee"
        or state == "Follow"
        or state == "Attack"
        or state == "AttackRange"
        or state == "TradingDefenseRanged"
        or state == "TradingDefenseMelee"
        or state == "ProtectRanged"
        or state == "ProtectMelee"
        or state == "ProtectAuto"
        or state == "Departure"
        or state == "Incapacitated"
end

local function clearZombieEngineAggro(zombie)
    if not zombie then
        return
    end

    if zombie.setTargetSeenTime then
        zombie:setTargetSeenTime(0)
    end

    if zombie.clearAggroList then
        zombie:clearAggroList()
    end
end

local function clearZombiePathing(zombie)
    if not zombie then
        return
    end

    zombie:setPath2(nil)

    local pathBehavior = zombie.getPathFindBehavior2 and zombie:getPathFindBehavior2() or nil
    if pathBehavior then
        if pathBehavior.cancel then
            pathBehavior:cancel()
        end
        if pathBehavior.reset then
            pathBehavior:reset()
        end
    end
end

function DTNPC.ApplyCharacterFlags(zombie, npcData)
    if not zombie then return end

    local state = npcData and npcData.state or nil
    local allowZombieMelee = false

    zombie:setNoTeeth(not allowZombieMelee)
    zombie:setVariable("NoLungeAttack", not allowZombieMelee)
    zombie:setVariable("NoLungeTarget", true)
    zombie:setVariable("ZombieHitReaction", "Chainsaw")

    local desc = zombie:getDescriptor()
    if desc then
        desc:setVoicePrefix("NotAZombie")
    end
end

function DTNPC.SuppressZombieEngineState(zombie, npcData, options)
    if not zombie then
        return
    end

    options = options or {}

    local state = options.state or (npcData and npcData.state) or "Stay"
    local manualControl = options.manualControl
    if manualControl == nil then
        manualControl = isManualControlState(state)
    end

    DTNPC.ApplyCharacterFlags(zombie, npcData)

    if zombie.setTurnAlertedValues then
        zombie:setTurnAlertedValues(0, 0)
    end

    if zombie.setAnimatingBackwards then
        zombie:setAnimatingBackwards(false)
    end

    local actionState = zombie.getActionStateName and zombie:getActionStateName() or nil
    local needsIdleReset = manualControl
        and (actionState == "turnalerted" or actionState == "lunge" or actionState == "pathfind")

    if manualControl then
        clearZombieEngineAggro(zombie)
        clearZombiePathing(zombie)

        if not zombie:isUseless() then
            zombie:setUseless(true)
        end

        if zombie.setRunning then
            zombie:setRunning(false)
        end
    end

    if needsIdleReset and ZombieIdleState and ZombieIdleState.instance and zombie.changeState then
        zombie:changeState(ZombieIdleState.instance())
    end
end
