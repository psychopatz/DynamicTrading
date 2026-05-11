-- ==============================================================================
-- DTNPC_ProtectLoadout_Validation.lua
-- Loadout validation helpers for DTNPC protect behavior.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getScriptItem = Internal.getScriptItem
local normalizeAmmoTypeIdentifier = Internal.normalizeAmmoTypeIdentifier
local isRangedWeapon = Internal.isRangedWeapon
local isMeleeWeapon = Internal.isMeleeWeapon

function DTNPCProtect.AreAmmoTypesEquivalent(left, right)
    local leftText = tostring(left or "")
    local rightText = tostring(right or "")
    if leftText == "" or rightText == "" then
        return false
    end
    if leftText == rightText then
        return true
    end
    return normalizeAmmoTypeIdentifier(leftText) == normalizeAmmoTypeIdentifier(rightText)
end

function DTNPCProtect.GetRangedLoadoutIssue(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local loadout = npcData.loadout
    local weapon = loadout.rangedWeapon
    if not weapon then
        return "no_weapon"
    end

    local scriptItem = getScriptItem(weapon)
    if not isRangedWeapon(weapon, scriptItem) then
        return "invalid_weapon"
    end

    local ammoType = DTNPCProtect.GetRangedAmmoType(npcData)
    if not ammoType or ammoType == "" then
        return "no_ammo_type"
    end

    if scriptItem and scriptItem.getAmmoType then
        local expectedAmmoType = scriptItem:getAmmoType()
        if expectedAmmoType and expectedAmmoType ~= "" and not DTNPCProtect.AreAmmoTypesEquivalent(ammoType, expectedAmmoType) then
            return "ammo_mismatch"
        end
    end

    local ammoCount = tonumber(loadout.ammoCount) or 0
    if DTNPCProtect.IsFiniteAmmoTrader(npcData) and ammoCount <= 0 then
        return "no_ammo"
    end
    if loadout.rangedCondition ~= nil and tonumber(loadout.rangedCondition) <= 0 then
        return "broken_weapon"
    end

    return nil
end

function DTNPCProtect.HasUsableRangedLoadout(npcData)
    return DTNPCProtect.GetRangedLoadoutIssue(npcData) == nil
end

function DTNPCProtect.HasUsableMeleeLoadout(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local weapon = npcData.loadout.meleeWeapon
    if not weapon then
        return false
    end

    if npcData.loadout.meleeCondition ~= nil and tonumber(npcData.loadout.meleeCondition) <= 0 then
        return false
    end

    return isMeleeWeapon(weapon, getScriptItem(weapon))
end
