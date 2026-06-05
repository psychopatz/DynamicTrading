-- ==============================================================================
-- DTNPC_Data_EngineState.lua
-- Character flag and zombie engine suppression helpers.
-- ==============================================================================

DTNPC = DTNPC or {}

local function isStationaryState(state)
    return state == "Stay"
        or state == "Guard"
        or state == "Idle"
        or state == "PlayerZone"
        or state == "Trading"
        or state == "Bandage"
end

local function isManualControlState(state)
    if isStationaryState(state) then
        return true
    end

    return state == "GoTo"
        or state == "Flee"
        or state == "Follow"
        or state == "ReturnHome"
        or state == "CorpseCleanup"
        or state == "LootNearby"
        or state == "Attack"
        or state == "AttackRange"
        or state == "TradingDefenseRanged"
        or state == "TradingDefenseMelee"
        or state == "ProtectRanged"
        or state == "ProtectMelee"
        or state == "ProtectAuto"
        or state == "Patrol"
        or state == "ColonyIdle"
        or state == "ColonyWork"
        or state == "ColonyCorpseRemoval"
        or state == "ColonyCower"
        or state == "ReviveAlly"
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

local function stopZombieVocals(zombie)
    local emitter = zombie and zombie.getEmitter and zombie:getEmitter() or nil
    if emitter and emitter.stopAll then
        emitter:stopAll()
    end
end

local function clearZombieTargetAggro(zombie)
    if not zombie then
        return
    end

    if zombie.setTarget then
        zombie:setTarget(nil)
    end
    if zombie.setAttackedBy then
        zombie:setAttackedBy(nil)
    end

    clearZombieEngineAggro(zombie)
    stopZombieVocals(zombie)
end

local function clearPlayerTargetAggro(zombie)
    if not zombie then
        return
    end

    local hadPlayerAggro = false
    local target = zombie.getTarget and zombie:getTarget() or nil
    if target and instanceof and instanceof(target, "IsoPlayer") then
        if zombie.setTarget then
            zombie:setTarget(nil)
        end
        hadPlayerAggro = true
    end

    local attackedBy = zombie.getAttackedBy and zombie:getAttackedBy() or nil
    if attackedBy and instanceof and instanceof(attackedBy, "IsoPlayer") then
        if zombie.setAttackedBy then
            zombie:setAttackedBy(nil)
        end
        hadPlayerAggro = true
    end

    if hadPlayerAggro then
        clearZombieEngineAggro(zombie)
        stopZombieVocals(zombie)
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

local function shouldClearVanillaTarget(npcData)
    if not npcData then
        return true
    end
    if npcData.incapState == "Active" or npcData.state == "Incapacitated" then
        return true
    end
    if npcData.isHostile ~= true then
        return true
    end

    local state = npcData.state
    if state == "Follow"
        or state == "ProtectRanged"
        or state == "ProtectMelee"
        or state == "ProtectAuto"
        or state == "Guard"
        or state == "Patrol"
        or state == "ColonyIdle"
        or state == "ColonyWork"
        or state == "ColonyCorpseRemoval"
        or state == "CorpseCleanup"
        or state == "ColonyCower"
        or state == "ReviveAlly"
        or state == "PlayerZone"
        or state == "LootNearby"
        or state == "Stay"
        or state == "Idle"
        or state == "Trading"
        or state == "GoTo"
        or state == "ReturnHome"
        or state == "Flee"
        or state == "Bandage" then
        return true
    end

    return npcData.dcCompanionJob == "TravelCompanion" or npcData.linkedWorkerID ~= nil
end

local function isCompanionControlled(npcData)
    if not npcData then
        return false
    end

    if npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits" then
        return false
    end

    return npcData.dcCompanionJob == "TravelCompanion"
        or npcData.linkedWorkerID ~= nil
        or (npcData.status == "Working" and (npcData.master ~= nil or npcData.masterID ~= nil))
end

local function normalizeCompanionHostility(npcData)
    if not isCompanionControlled(npcData) then
        return
    end

    npcData.isHostile = false
    npcData.combatTargetID = nil
    npcData.lastPlayerAttackerUsername = nil
    npcData.lastPlayerAttackerOnlineID = nil

    if npcData.state == "Attack" or npcData.state == "AttackRange" then
        local combatOrder = npcData.combatOrder
        if combatOrder == "ProtectRanged"
            or combatOrder == "ProtectMelee"
            or combatOrder == "ProtectAuto" then
            npcData.state = combatOrder
        elseif npcData.master ~= nil or npcData.masterID ~= nil then
            npcData.state = "Follow"
        elseif npcData.linkedWorkerID ~= nil then
            npcData.state = tostring(npcData.dcBehaviorState or "PlayerZone")
        else
            npcData.state = "Guard"
        end
    end
end

function DTNPC.ApplyCharacterFlags(zombie, npcData)
    if not zombie then return end

    zombie:setNoTeeth(true)
    zombie:setVariable("NoTeeth", true)
    zombie:setVariable("CanBite", false)
    zombie:setVariable("CanLunge", false)
    zombie:setVariable("bLunger", false)
    zombie:setVariable("NoLungeAttack", true)
    zombie:setVariable("NoLungeTarget", true)
    zombie:setVariable("ZombieHitReaction", "Chainsaw")
    zombie:setVariable("DTNPCNoBite", true)
    zombie:setVariable("DTNPCNoMoan", true)

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

function DTNPC.RestoreNPCBodyState(zombie, npcData, options)
    if not zombie or not npcData then
        return
    end

    options = options or {}

    if options.normalizeCompanionHostility == true then
        normalizeCompanionHostility(npcData)
    end

    local modData = zombie:getModData()
    if modData then
        modData.IsDTNPC = true
        modData.DTNPC_Data = npcData
        if npcData.uuid then
            modData.DTNPC_UUID = npcData.uuid
        end
        if npcData.visualID then
            modData.DTNPCVisualID = npcData.visualID
        end
        modData.DTNPCPresenceRevision = math.max(0, math.floor(tonumber(npcData.presenceRevision) or 0))
    end

    zombie:setVariable("DTNPC", true)
    DTNPC.ApplyCharacterFlags(zombie, npcData)
    stopZombieVocals(zombie)

    local clearTarget = options.clearTarget
    if clearTarget == nil then
        clearTarget = shouldClearVanillaTarget(npcData)
    end
    if clearTarget ~= false then
        clearZombieTargetAggro(zombie)
    else
        clearZombieEngineAggro(zombie)
    end

    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
end

function DTNPC.IsMarkedBody(zombie)
    if not zombie or (zombie.isDead and zombie:isDead()) then
        return false
    end

    local modData = zombie.getModData and zombie:getModData() or nil
    if not modData then
        return false
    end

    return modData.IsDTNPC == true
        or modData.DTNPC_UUID ~= nil
        or modData.DTNPC_Data ~= nil
        or modData.DTNPCBrain ~= nil
        or (zombie.getVariableBoolean and zombie:getVariableBoolean("DTNPC") == true)
end

function DTNPC.ApplyMarkedBodySafety(zombie, npcData, options)
    if not DTNPC.IsMarkedBody or not DTNPC.IsMarkedBody(zombie) then
        return false
    end

    local modData = zombie:getModData()
    npcData = npcData or modData.DTNPC_Data or modData.DTNPCBrain
    options = options or {}

    DTNPC.ApplyCharacterFlags(zombie, npcData)

    local suppressEngineState = options.suppressEngineState
    if suppressEngineState == nil then
        suppressEngineState = (modData.IsDTNPC ~= true) or npcData == nil
    end

    local safetyState = options.state
        or (npcData and npcData.state)
        or "Stay"
    local clearPlayerTarget = options.clearPlayerTarget
    if clearPlayerTarget == nil then
        clearPlayerTarget = options.clearTarget ~= true
    end

    if suppressEngineState then
        DTNPC.SuppressZombieEngineState(zombie, npcData, {
            state = safetyState,
            manualControl = options.manualControl ~= false,
        })
        if zombie.DoZombieStats then
            zombie:DoZombieStats()
        end
    end

    DTNPC.ApplySafetyFlags(zombie, npcData, {
        clearTarget = options.clearTarget == true,
        clearPlayerTarget = clearPlayerTarget,
    })

    return true
end

function DTNPC.ApplySafetyFlags(zombie, npcData, options)
    if not zombie then
        return
    end

    options = options or {}
    DTNPC.ApplyCharacterFlags(zombie, npcData)

    if options.clearTarget == true then
        clearZombieTargetAggro(zombie)
    elseif options.clearPlayerTarget ~= false then
        clearPlayerTargetAggro(zombie)
    else
        clearZombieEngineAggro(zombie)
    end
end
