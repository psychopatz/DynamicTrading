-- ==============================================================================
-- DTNPC_Data_EquipmentBridge.lua
-- Bridge functions that delegate to DTNPCEquipmentVisuals.
-- ==============================================================================

DTNPC = DTNPC or {}

function DTNPC.GetMeleeWeaponFamily(npcData)
    if DTNPCEquipmentVisuals and DTNPCEquipmentVisuals.GetMeleeWeaponFamily then
        return DTNPCEquipmentVisuals.GetMeleeWeaponFamily(npcData)
    end

    return "onehanded"
end

function DTNPC.SetMeleeCombatIdleState(zombie, npcData)
    if DTNPCEquipmentVisuals and DTNPCEquipmentVisuals.SetMeleeCombatIdleState then
        DTNPCEquipmentVisuals.SetMeleeCombatIdleState(zombie, npcData)
    end
end

function DTNPC.SetRangedCombatIdleState(zombie, npcData)
    if DTNPCEquipmentVisuals and DTNPCEquipmentVisuals.SetRangedCombatIdleState then
        DTNPCEquipmentVisuals.SetRangedCombatIdleState(zombie, npcData)
    end
end

function DTNPC.TriggerMeleeCombatAnim(zombie, npcData)
    if DTNPCEquipmentVisuals and DTNPCEquipmentVisuals.TriggerMeleeCombatAnim then
        DTNPCEquipmentVisuals.TriggerMeleeCombatAnim(zombie, npcData)
    end
end

function DTNPC.TriggerRangedCombatAnim(zombie, npcData)
    if DTNPCEquipmentVisuals and DTNPCEquipmentVisuals.TriggerRangedCombatAnim then
        DTNPCEquipmentVisuals.TriggerRangedCombatAnim(zombie, npcData)
    end
end

function DTNPC.TriggerRangedReloadAnim(zombie, npcData)
    if DTNPCEquipmentVisuals and DTNPCEquipmentVisuals.TriggerRangedReloadAnim then
        DTNPCEquipmentVisuals.TriggerRangedReloadAnim(zombie, npcData)
    elseif DTNPCEquipmentVisuals and DTNPCEquipmentVisuals.SetRangedCombatIdleState then
        DTNPCEquipmentVisuals.SetRangedCombatIdleState(zombie, npcData)
    end
end

function DTNPC.SyncEquipmentVisuals(zombie, npcData, options)
    if DTNPCEquipmentVisuals and DTNPCEquipmentVisuals.Apply then
        return DTNPCEquipmentVisuals.Apply(zombie, npcData, options)
    end

    return false
end
