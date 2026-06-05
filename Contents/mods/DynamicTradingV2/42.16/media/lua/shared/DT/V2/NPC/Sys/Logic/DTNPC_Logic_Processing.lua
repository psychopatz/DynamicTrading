-- ==============================================================================
-- DTNPC_Logic_Processing.lua
-- Core processing and behavior dispatch for NPC logic.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}

local HIGH_SPEED_STATES = {
    GoTo = true,
    Flee = true,
    Attack = true,
    AttackRange = true,
    Follow = true,
    ReturnHome = true,
    CorpseCleanup = true,
    TradingDefenseRanged = true,
    TradingDefenseMelee = true,
    ProtectRanged = true,
    ProtectMelee = true,
    ProtectAuto = true,
    Guard = true,
    Patrol = true,
    ColonyWork = true,
    ColonyCorpseRemoval = true,
    ColonyCower = true,
    ReviveAlly = true,
    LootNearby = true,
    Departure = true,
    Incapacitated = true,
}

function DTNPCLogic.ProcessNPC(zombie)
    local npcData = DTNPC.GetData(zombie)
    if not npcData then
        return
    end

    if zombie.isDead and zombie:isDead() then
        if DTNPCLifecycle and DTNPCLifecycle.HandleZombieDead then
            DTNPCLifecycle.HandleZombieDead(zombie)
        end
        return
    end

    if DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(npcData)
    end

    local combatHealth = DTNPCHealth and DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil

    if DTNPCHealth and DTNPCHealth.ProcessDeferredSpawnRestore then
        DTNPCHealth.ProcessDeferredSpawnRestore(zombie, npcData)
    end

    zombie:setVariable("DTNPC", true)
    if zombie:getVariableString("DTIdleState") == "" then
        zombie:setVariable("DTIdleState", "0")
    end

    local state = npcData.state or "Stay"

    if DTNPC and DTNPC.ApplyCharacterFlags then
        DTNPC.ApplyCharacterFlags(zombie, npcData)
    end
    if DTNPC and DTNPC.SyncEquipmentVisuals then
        DTNPC.SyncEquipmentVisuals(zombie, npcData)
    end

    if npcData.incapState == "Active" then
        npcData.state = "Incapacitated"
        npcData.isHostile = false
        zombie:setTarget(nil)
        zombie:setAttackedBy(nil)
        state = "Incapacitated"
    end

    if DTNPCStamina and DTNPCStamina.ProcessPassive then
        DTNPCStamina.ProcessPassive(zombie, npcData, state)
    end

    if state ~= "Incapacitated"
        and DTNPCMobility
        and DTNPCMobility.IsSpecialActionActive
        and DTNPCMobility.UpdateSpecialAction then
        local specialActive = DTNPCMobility.IsSpecialActionActive(npcData)
        if specialActive then
            DTNPCMobility.UpdateSpecialAction(zombie, npcData)
            if DTNPC and DTNPC.ApplySafetyFlags then
                DTNPC.ApplySafetyFlags(zombie, npcData, { clearPlayerTarget = true })
            end
            return
        end
    end

    DTNPCLogic.UpdateIdleCycle(zombie, npcData, state)
    DTNPCLogic.ApplyAnchorStabilization(zombie, npcData, state)

    state = npcData.state or state

    if DTNPCLogic.UpdateHostileGiveUpCooldown and DTNPCLogic.UpdateHostileGiveUpCooldown(zombie, npcData) then
        state = npcData.state or state
    end

    local fallbackDamaged = false
    if DTNPCHealth and DTNPCHealth.ProcessFallbackDamage then
        fallbackDamaged = DTNPCHealth.ProcessFallbackDamage(zombie, npcData) == true
    end

    local currentHealth = zombie:getHealth()
    if not npcData.lastHealth then
        npcData.lastHealth = currentHealth
    end
    local customDamageAt = combatHealth and tonumber(combatHealth.lastDamageAt) or 0
    local lastProcessedDamageAt = tonumber(npcData.lastCustomDamageHandledAt) or 0
    local customWasDamaged = customDamageAt > lastProcessedDamageAt
    if customWasDamaged then
        npcData.lastCustomDamageHandledAt = customDamageAt
    end
    local useEngineDelta = not (combatHealth and combatHealth.eventDrivenOnly == true)
    local wasDamaged = fallbackDamaged or (useEngineDelta and currentHealth < npcData.lastHealth) or customWasDamaged
    npcData.lastHealth = currentHealth

    if DTNPCHealth and DTNPCHealth.ProcessPassiveBandageRegen then
        DTNPCHealth.ProcessPassiveBandageRegen(zombie, npcData)
    end
    if DTNPCHealth and DTNPCHealth.ProcessPassiveRestRegen then
        DTNPCHealth.ProcessPassiveRestRegen(zombie, npcData)
    end
    if DTNPCHealth and DTNPCHealth.ProcessWeakenedRecovery then
        DTNPCHealth.ProcessWeakenedRecovery(zombie, npcData)
    end

    local customCurrent = tonumber(combatHealth and combatHealth.current) or nil
    local minDamage = tonumber(DTNPCHealth and DTNPCHealth.MIN_DAMAGE) or 0.01
    if customCurrent ~= nil
        and customCurrent <= minDamage
        and npcData.incapState ~= "Active"
        and tostring(npcData.state or "") ~= "Incapacitated"
        and tostring(npcData.status or "") ~= "Dead"
        and not tonumber(npcData.deathFinalizedAt)
        and DTNPCHealth
        and DTNPCHealth.ForceZeroHPTransition then
        local enteredIncap = DTNPCHealth.ForceZeroHPTransition(zombie, npcData, zombie.getAttackedBy and zombie:getAttackedBy() or nil, {
            source = "logic_zero_hp_guard",
        })
        if enteredIncap then
            state = "Incapacitated"
            combatHealth = DTNPCHealth and DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or combatHealth
        end
    end

    if DTNPCHealth and DTNPCHealth.ApplyHealthVisualPosture then
        DTNPCHealth.ApplyHealthVisualPosture(zombie, npcData)
    end

    if HIGH_SPEED_STATES[state] then
        DTNPCLogic.ExecuteBehavior(zombie, npcData, state, wasDamaged)
    else
        if not npcData.tickTimer then
            npcData.tickTimer = 0
        end
        npcData.tickTimer = npcData.tickTimer + 1

        if npcData.tickTimer >= 10 then
            npcData.tickTimer = 0
            DTNPCLogic.ExecuteBehavior(zombie, npcData, state, wasDamaged)
        end
    end

    if DTNPC and DTNPC.ApplySafetyFlags then
        DTNPC.ApplySafetyFlags(zombie, npcData, { clearPlayerTarget = true })
    end
end

function DTNPCLogic.ExecuteBehavior(zombie, npcData, state, wasDamaged)
    local master, dist = DTNPCLogic.GetClosestTarget(zombie)

    DTNPCLogic.CheckForCombatInitiation(zombie, npcData, master, wasDamaged)

    if npcData.state ~= state then
        state = npcData.state
        master, dist = DTNPCLogic.GetClosestTarget(zombie)
    end

    if DTNPCHealth and DTNPCHealth.TryEnterSelfBandage then
        local enteredBandage = DTNPCHealth.TryEnterSelfBandage(zombie, npcData, state)
        if enteredBandage then
            state = npcData.state or "Bandage"
            master = nil
            dist = 9999
        end
    end

    if state ~= "Bandage"
        and state ~= "Incapacitated"
        and state ~= "Departure"
        and DTNPCHealth
        and DTNPCHealth.TryEnterAllyRevive
        and DTNPCHealth.TryEnterAllyRevive(zombie, npcData, state) then
        state = npcData.state or "ReviveAlly"
        master = nil
        dist = 9999
    end

    if state ~= "ReturnHome"
        and state ~= "CorpseCleanup"
        and DTNPCNeeds
        and DTNPCNeeds.Evaluate then
        local maintenanceState = DTNPCNeeds.Evaluate(zombie, npcData, state)
        if maintenanceState then
            state = npcData.state or maintenanceState
            master = nil
            dist = 9999
        end
    end

    local behaviorFunc = DTNPCLogic.Behaviors[state]
    if behaviorFunc then
        behaviorFunc(zombie, npcData, master, dist)
        return
    end

    if DTNPCLogic.Behaviors["Stay"] then
        DTNPCLogic.Behaviors["Stay"](zombie, npcData, master, dist)
    end
end
