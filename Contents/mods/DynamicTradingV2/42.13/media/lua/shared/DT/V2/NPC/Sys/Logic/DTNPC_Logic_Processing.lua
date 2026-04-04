-- ==============================================================================
-- DTNPC_Logic_Processing.lua
-- Core processing and behavior dispatch for NPC logic.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}

local HIGH_SPEED_STATES = {
    GoTo = true,
    Flee = true,
    AttackRange = true,
    Follow = true,
    TradingDefenseRanged = true,
    TradingDefenseMelee = true,
    ProtectRanged = true,
    ProtectMelee = true,
    ProtectAuto = true,
    Departure = true,
    Incapacitated = true,
}

function DTNPCLogic.ProcessNPC(zombie)
    local npcData = DTNPC.GetData(zombie)
    if not npcData then
        return
    end

    if DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(npcData)
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

    DTNPCLogic.UpdateIdleCycle(zombie, npcData, state)
    DTNPCLogic.ApplyAnchorStabilization(zombie, npcData, state)

    local currentHealth = zombie:getHealth()
    if not npcData.lastHealth then
        npcData.lastHealth = currentHealth
    end
    local wasDamaged = currentHealth < npcData.lastHealth
    npcData.lastHealth = currentHealth

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

end

function DTNPCLogic.ExecuteBehavior(zombie, npcData, state, wasDamaged)
    local master, dist = DTNPCLogic.GetClosestTarget(zombie)

    DTNPCLogic.CheckForCombatInitiation(zombie, npcData, master, wasDamaged)

    if npcData.state ~= state then
        state = npcData.state
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
