-- ==============================================================================
-- DTNPC_EquipmentVisuals_Combat.lua
-- Idle-state and combat bump animation helpers.
-- ==============================================================================

DTNPCEquipmentVisuals = DTNPCEquipmentVisuals or {}

local EquipmentVisuals = DTNPCEquipmentVisuals
EquipmentVisuals.Constants = EquipmentVisuals.Constants or {}

local Constants = EquipmentVisuals.Constants

function EquipmentVisuals.SetMeleeCombatIdleState(zombie, npcData)
    if not zombie then
        return
    end

    if EquipmentVisuals.GetMeleeWeaponFamily(npcData) == "twohanded" then
        zombie:setVariable("DTIdleState", "10")
        return
    end

    zombie:setVariable("DTIdleState", "0")
end

function EquipmentVisuals.SetRangedCombatIdleState(zombie, npcData)
    if not zombie then
        return
    end

    local showSightIdle = npcData and npcData.enableRangedSightAnim == true
    local family = EquipmentVisuals.GetRangedWeaponFamily(npcData)
    if showSightIdle and family == "handgun" then
        zombie:setVariable("DTIdleState", "2")
        return
    end

    zombie:setVariable("DTIdleState", "0")
end

function EquipmentVisuals.TriggerMeleeCombatAnim(zombie, npcData)
    if not zombie then
        return
    end

    local family = EquipmentVisuals.GetMeleeWeaponFamily(npcData)
    local options = Constants.MELEE_BUMP_TYPES[family] or Constants.MELEE_BUMP_TYPES.onehanded
    if not options or #options == 0 then
        return
    end

    local index = ZombRand(#options) + 1
    zombie:setBumpType(options[index])
end

function EquipmentVisuals.TriggerRangedCombatAnim(zombie, npcData)
    if not zombie then
        return
    end

    local family = EquipmentVisuals.GetRangedWeaponFamily(npcData)
    local options = Constants.RANGED_BUMP_TYPES[family] or Constants.RANGED_BUMP_TYPES.handgun
    if not options or #options == 0 then
        return
    end

    local index = ZombRand(#options) + 1
    zombie:setBumpType(options[index])
end

function EquipmentVisuals.TriggerRangedReloadAnim(zombie, npcData)
    if not zombie then
        return
    end

    local reloadFamily = npcData and npcData._dtReloadFamily or nil
    local bumpType = Constants.RANGED_RELOAD_BUMP_TYPES[reloadFamily or ""] or nil
    if bumpType and bumpType ~= "" then
        zombie:setBumpType(bumpType)
        return
    end

    EquipmentVisuals.SetRangedCombatIdleState(zombie, npcData)
end
