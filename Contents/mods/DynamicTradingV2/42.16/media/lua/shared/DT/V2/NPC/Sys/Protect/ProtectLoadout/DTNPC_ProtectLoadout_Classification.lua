-- ==============================================================================
-- DTNPC_ProtectLoadout_Classification.lua
-- Weapon classification helpers for DTNPC protect loadouts.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local lower = Internal.lower

local function isRangedWeapon(fullType, scriptItem)
    if not fullType or fullType == "" then
        return false
    end

    if scriptItem then
        if scriptItem.isRanged and scriptItem:isRanged() then
            return true
        end
        if scriptItem.isAimedFirearm and scriptItem:isAimedFirearm() then
            return true
        end
        if scriptItem.getAmmoType and scriptItem:getAmmoType() and scriptItem:getAmmoType() ~= "" then
            return true
        end

        local displayCategory = scriptItem.getDisplayCategory and scriptItem:getDisplayCategory() or nil
        if lower(displayCategory):find("firearm", 1, true) then
            return true
        end
    end

    local lowered = lower(fullType)
    return lowered:find("pistol", 1, true) ~= nil
        or lowered:find("revolver", 1, true) ~= nil
        or lowered:find("shotgun", 1, true) ~= nil
        or lowered:find("rifle", 1, true) ~= nil
        or lowered:find("smg", 1, true) ~= nil
        or lowered:find("firearm", 1, true) ~= nil
        or lowered:find("gun", 1, true) ~= nil
end

local function normalizeAmmoTypeIdentifier(value)
    local token = lower(value)
    if token == "" then
        return ""
    end

    token = token:match("([^%.:]+)$") or token
    token = token:gsub("_", "")
    token = token:gsub("box$", "")
    return token
end

local function isMeleeWeapon(fullType, scriptItem)
    if not fullType or fullType == "" then
        return false
    end

    if isRangedWeapon(fullType, scriptItem) then
        return false
    end

    if scriptItem then
        local swingAnim = scriptItem.getSwingAnim and scriptItem:getSwingAnim() or nil
        local displayCategory = scriptItem.getDisplayCategory and scriptItem:getDisplayCategory() or nil
        if swingAnim and lower(swingAnim) ~= "" then
            return true
        end
        if lower(displayCategory):find("melee", 1, true) then
            return true
        end
    end

    local lowered = lower(fullType)
    return lowered:find("bat", 1, true) ~= nil
        or lowered:find("axe", 1, true) ~= nil
        or lowered:find("knife", 1, true) ~= nil
        or lowered:find("machete", 1, true) ~= nil
        or lowered:find("club", 1, true) ~= nil
        or lowered:find("hammer", 1, true) ~= nil
        or lowered:find("spear", 1, true) ~= nil
        or lowered:find("crowbar", 1, true) ~= nil
end

Internal.normalizeAmmoTypeIdentifier = normalizeAmmoTypeIdentifier
Internal.isRangedWeapon = isRangedWeapon
Internal.isMeleeWeapon = isMeleeWeapon
