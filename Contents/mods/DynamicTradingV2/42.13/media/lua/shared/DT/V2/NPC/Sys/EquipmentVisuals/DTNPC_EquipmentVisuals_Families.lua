-- ==============================================================================
-- DTNPC_EquipmentVisuals_Families.lua
-- Weapon family detection helpers for combat visuals.
-- ==============================================================================

DTNPCEquipmentVisuals = DTNPCEquipmentVisuals or {}

local EquipmentVisuals = DTNPCEquipmentVisuals
EquipmentVisuals.Helpers = EquipmentVisuals.Helpers or {}

local Helpers = EquipmentVisuals.Helpers

function EquipmentVisuals.GetMeleeWeaponFamily(npcData)
    local loadout = npcData and npcData.loadout or nil
    local weapon = loadout and loadout.meleeWeapon or nil
    if not weapon or weapon == "" then
        return "onehanded"
    end

    local lowered = Helpers.lower(weapon)
    local scriptItem = Helpers.getScriptItemDefinition(weapon)
    local swingAnim = scriptItem and scriptItem.getSwingAnim and Helpers.lower(scriptItem:getSwingAnim()) or ""
    local weaponItem = Helpers.createDisplayItem(weapon, Helpers.getStoredWeaponCondition(npcData, weapon))

    if lowered:find("knife", 1, true) or swingAnim:find("knife", 1, true) then
        return "knife"
    end

    if weaponItem and weaponItem.IsWeapon and weaponItem:IsWeapon() and WeaponType and WeaponType.getWeaponType then
        local weaponType = WeaponType.getWeaponType(weaponItem)
        if weaponType == WeaponType.ONE_HANDED then
            return "onehanded"
        end
        if weaponType == WeaponType.HEAVY
            or weaponType == WeaponType.SPEAR
            or weaponType == WeaponType.TWO_HANDED then
            return "twohanded"
        end
    end

    if lowered:find("spear", 1, true) or swingAnim:find("spear", 1, true) then
        return "twohanded"
    end

    if lowered:find("bat", 1, true)
        or lowered:find("axe", 1, true)
        or lowered:find("sledge", 1, true)
        or lowered:find("crowbar", 1, true)
        or lowered:find("pipe", 1, true)
        or lowered:find("bar", 1, true)
        or lowered:find("guitar", 1, true)
        or lowered:find("hammer", 1, true)
        or swingAnim:find("2h", 1, true)
        or swingAnim:find("heavy", 1, true)
        or swingAnim:find("bat", 1, true) then
        return "twohanded"
    end

    return "onehanded"
end

function EquipmentVisuals.GetRangedWeaponFamily(npcData)
    local loadout = npcData and npcData.loadout or nil
    local weapon = loadout and loadout.rangedWeapon or nil
    if not weapon or weapon == "" then
        return "handgun"
    end

    local weaponItem = Helpers.createDisplayItem(weapon, Helpers.getStoredWeaponCondition(npcData, weapon))
    local displayType = Helpers.getWeaponDisplayType(weaponItem)
    if displayType == "handgun" then
        return "handgun"
    end

    return "rifle"
end
