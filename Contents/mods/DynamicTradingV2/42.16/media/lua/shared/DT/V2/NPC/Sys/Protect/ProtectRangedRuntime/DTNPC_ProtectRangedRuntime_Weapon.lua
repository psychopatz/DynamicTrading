-- ==============================================================================
-- DTNPC_ProtectRangedRuntime_Weapon.lua
-- Weapon family and runtime descriptor helpers for DTNPC ranged runtime.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local lower = Internal.lower
local getScriptItem = Internal.getScriptItem

local RELOAD_ANIMS = {
    pistol = "DTNPCRackPistol",
    rifle = "DTNPCRackRifle",
    shotgun = "DTNPCRackShotgun",
    revolver = "DTNPCRackRevolver",
    dbshotgun = "DTNPCRackDBShotgun",
}

local RELOAD_DURATIONS_MS = {
    pistol = 1650,
    rifle = 2050,
    shotgun = 2350,
    revolver = 1850,
    dbshotgun = 2550,
}

local function resolveWeaponFamily(fullType, scriptItem)
    local lowered = lower(fullType)
    if lowered:find("revolver", 1, true) then
        return "handgun", "revolver"
    end
    if lowered:find("doublebarrel", 1, true) or lowered:find("dblshotgun", 1, true) then
        return "rifle", "dbshotgun"
    end
    if lowered:find("shotgun", 1, true) then
        return "rifle", "shotgun"
    end
    if lowered:find("pistol", 1, true) then
        return "handgun", "pistol"
    end
    if lowered:find("rifle", 1, true) or lowered:find("smg", 1, true) or lowered:find("carbine", 1, true) then
        return "rifle", "rifle"
    end

    local displayCategory = scriptItem and scriptItem.getDisplayCategory and lower(scriptItem:getDisplayCategory()) or ""
    if displayCategory:find("shotgun", 1, true) then
        return "rifle", "shotgun"
    end
    if displayCategory:find("revolver", 1, true) then
        return "handgun", "revolver"
    end

    return "handgun", "pistol"
end

local function resolveMagSize(fullType, scriptItem, reloadFamily)
    local size = nil

    if scriptItem and scriptItem.getClipSize then
        size = tonumber(scriptItem:getClipSize())
    end
    if (not size or size <= 0) and scriptItem and scriptItem.getMaxAmmo then
        size = tonumber(scriptItem:getMaxAmmo())
    end

    if size and size > 0 then
        return math.max(1, math.floor(size))
    end

    if reloadFamily == "revolver" then
        return 6
    end
    if reloadFamily == "dbshotgun" then
        return 2
    end
    if reloadFamily == "shotgun" then
        return 6
    end
    if reloadFamily == "rifle" then
        return 10
    end

    local lowered = lower(fullType)
    if lowered:find("38", 1, true) then
        return 6
    end
    return 8
end

local function resolveReloadDurationMs(npcData, scriptItem, reloadFamily)
    local reloadMs = nil
    if scriptItem and scriptItem.getReloadTime then
        reloadMs = tonumber(scriptItem:getReloadTime())
        if reloadMs and reloadMs > 0 and reloadMs < 100 then
            reloadMs = reloadMs * 100
        end
    end

    if not reloadMs or reloadMs <= 0 then
        reloadMs = RELOAD_DURATIONS_MS[reloadFamily] or 1850
    end

    local reloadSkill = DTNPCProtect.GetSkillLevel and DTNPCProtect.GetSkillLevel(npcData, "Shooting") or 0
    local skillScale = 1.0 - (math.min(math.max(reloadSkill, 0), 20) * 0.01)
    return math.max(900, math.floor(reloadMs * skillScale))
end

function DTNPCProtect.GetRangedWeaponRuntime(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local loadout = npcData.loadout or {}
    local weapon = loadout.rangedWeapon
    if not weapon or weapon == "" then
        if Internal.ClearRangedRuntime then
            Internal.ClearRangedRuntime(npcData)
        end
        return nil
    end

    local scriptItem = getScriptItem(weapon)
    local family, reloadFamily = resolveWeaponFamily(weapon, scriptItem)
    local magSize = resolveMagSize(weapon, scriptItem, reloadFamily)
    local reloadDurationMs = resolveReloadDurationMs(npcData, scriptItem, reloadFamily)

    return {
        weaponFamily = family,
        reloadFamily = reloadFamily,
        magSize = magSize,
        reloadDurationMs = reloadDurationMs,
        reloadAnim = RELOAD_ANIMS[reloadFamily] or nil,
        scriptItem = scriptItem,
    }
end
