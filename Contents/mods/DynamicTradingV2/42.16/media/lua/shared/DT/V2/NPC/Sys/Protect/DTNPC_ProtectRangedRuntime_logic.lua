-- ==============================================================================
-- DTNPC_ProtectRangedRuntime_logic.lua
-- Shared ranged runtime, reload gating, and combat flavor helpers.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_Combat"

local Internal = DTNPCProtect.Internal
local lower = Internal.lower
local getScriptItem = Internal.getScriptItem
local nowMillis = Internal.nowMillis

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

local COMBAT_FLAVOR_FALLBACKS = {
    Reloading = {
        "Reloading.",
        "Cover me. Reloading.",
        "Need a second to reload.",
    },
    CrowdRefuse = {
        "Too many of them. Backing off.",
        "No. That's too many zeds.",
        "Need a better opening.",
    },
    HostileNPC = {
        "Hostile survivor spotted.",
        "Enemy survivor. Moving in.",
        "We've got hostile company.",
    },
    BanditsEncounter = {
        "Bandits. Weapons up.",
        "Bandit contact ahead.",
        "Raiders spotted. Stay sharp.",
    },
    StaminaSlow = {
        "Slowing down. Need a breath.",
        "Can't hold this pace much longer.",
        "Easy. Need to breathe.",
    },
    CatchBreath = {
        "Give me a second.",
        "Catching my breath.",
        "Need a breather.",
    },
    MeleeFatigue = {
        "Need a second before I swing again.",
        "Arms are burning. Backing off.",
        "Hold them a moment. Re-centering.",
    },
}

local function pickFallbackLine(kind)
    local lines = COMBAT_FLAVOR_FALLBACKS[kind]
    if not lines or #lines == 0 then
        return nil
    end
    return lines[ZombRand(#lines) + 1]
end

local function getFlavorLine(kind)
    local line = DynamicTrading
        and DynamicTrading.FlavorText
        and DynamicTrading.FlavorText.GetRandom
        and DynamicTrading.FlavorText.GetRandom("CompanionCombat", kind)
        or nil
    if line and line ~= "" then
        return line
    end
    return pickFallbackLine(kind)
end

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

local function clearRangedRuntime(npcData)
    if not npcData then
        return
    end

    npcData._dtMagAmmo = nil
    npcData._dtMagSize = nil
    npcData._dtReloadUntil = nil
    npcData._dtReloadFamily = nil
    npcData._dtReloadAnim = nil
    npcData._dtSpecialActionMode = nil
end

function DTNPCProtect.GetCombatFlavorLine(kind, fallbackKind)
    return getFlavorLine(kind or fallbackKind)
end

function DTNPCProtect.PushCombatFlavorNotice(zombie, npcData, kind, sentiment, dialogueStatus, dialogueState)
    if not npcData then
        return false
    end

    local line = getFlavorLine(kind)
    if line and line ~= "" and DTNPCProtect.PushCompanionNotice then
        return DTNPCProtect.PushCompanionNotice(zombie, npcData, line, sentiment or "warning")
    end

    if DTNPCProtect.PushCompanionAmbientCue and dialogueStatus and dialogueState then
        return DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, dialogueStatus, dialogueState)
    end

    return false
end

function DTNPCProtect.GetRangedWeaponRuntime(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local loadout = npcData.loadout or {}
    local weapon = loadout.rangedWeapon
    if not weapon or weapon == "" then
        clearRangedRuntime(npcData)
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

function DTNPCProtect.EnsureRangedRuntime(npcData)
    local runtime = DTNPCProtect.GetRangedWeaponRuntime(npcData)
    if not runtime then
        return nil
    end

    local finiteAmmo = DTNPCProtect.IsFiniteAmmoTrader and DTNPCProtect.IsFiniteAmmoTrader(npcData) or false
    local totalAmmo = math.max(0, math.floor(tonumber(npcData.loadout and npcData.loadout.ammoCount) or 0))
    local targetMagSize = math.max(1, tonumber(runtime.magSize) or 1)

    npcData._dtMagSize = targetMagSize
    npcData._dtReloadFamily = runtime.reloadFamily
    npcData._dtReloadAnim = runtime.reloadAnim

    local currentMag = tonumber(npcData._dtMagAmmo)
    if currentMag == nil then
        if finiteAmmo then
            currentMag = math.min(targetMagSize, totalAmmo)
        else
            currentMag = targetMagSize
        end
    end

    currentMag = math.max(0, math.min(targetMagSize, math.floor(currentMag)))
    if finiteAmmo and currentMag > totalAmmo then
        currentMag = totalAmmo
    end

    npcData._dtMagAmmo = currentMag
    return runtime
end

function DTNPCProtect.IsRangedReloading(npcData)
    if not npcData then
        return false
    end
    local reloadUntil = tonumber(npcData._dtReloadUntil) or 0
    if reloadUntil <= 0 then
        return false
    end
    return (nowMillis() or 0) < reloadUntil
end

function DTNPCProtect.NeedsRangedReload(npcData)
    if not npcData then
        return false
    end

    local runtime = DTNPCProtect.EnsureRangedRuntime(npcData)
    if not runtime then
        return false
    end

    local magAmmo = math.max(0, math.floor(tonumber(npcData._dtMagAmmo) or 0))
    if magAmmo > 0 then
        return false
    end

    if DTNPCProtect.IsFiniteAmmoTrader and DTNPCProtect.IsFiniteAmmoTrader(npcData) then
        return math.max(0, tonumber(npcData.loadout and npcData.loadout.ammoCount) or 0) > 0
    end

    return true
end

function DTNPCProtect.StartRangedReload(zombie, npcData, options)
    if not npcData then
        return false
    end

    local runtime = DTNPCProtect.EnsureRangedRuntime(npcData)
    if not runtime then
        return false
    end

    local currentTime = nowMillis()
    local reloadUntil = currentTime + math.max(900, tonumber(runtime.reloadDurationMs) or 1650)

    npcData._dtReloadUntil = reloadUntil
    npcData._dtReloadFamily = runtime.reloadFamily
    npcData._dtReloadAnim = runtime.reloadAnim
    npcData._dtReloadActionSeq = (tonumber(npcData._dtReloadActionSeq) or 0) + 1
    npcData._dtSpecialAction = "reload"
    npcData._dtSpecialActionMode = runtime.reloadFamily
    npcData._dtSpecialActionUntil = reloadUntil
    npcData._dtSpecialActionSeq = (tonumber(npcData._dtSpecialActionSeq) or 0) + 1
    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    npcData.isMovingState = false

    if DTNPC and DTNPC.TriggerRangedReloadAnim then
        DTNPC.TriggerRangedReloadAnim(zombie, npcData)
    elseif DTNPC and DTNPC.SetRangedCombatIdleState then
        DTNPC.SetRangedCombatIdleState(zombie, npcData)
    end

    if options and options.faceTarget and zombie and options.faceTarget.getX then
        zombie:faceLocation(options.faceTarget:getX(), options.faceTarget:getY())
    end

    DTNPCProtect.PushCombatFlavorNotice(zombie, npcData, "Reloading", "warning", "Companion", "Reloading")
    return true
end

function DTNPCProtect.CompleteRangedReload(zombie, npcData)
    if not npcData then
        return false
    end

    local runtime = DTNPCProtect.EnsureRangedRuntime(npcData)
    if not runtime then
        clearRangedRuntime(npcData)
        return false
    end

    local finiteAmmo = DTNPCProtect.IsFiniteAmmoTrader and DTNPCProtect.IsFiniteAmmoTrader(npcData) or false
    local totalAmmo = math.max(0, math.floor(tonumber(npcData.loadout and npcData.loadout.ammoCount) or 0))
    if finiteAmmo then
        npcData._dtMagAmmo = math.min(runtime.magSize, totalAmmo)
    else
        npcData._dtMagAmmo = runtime.magSize
    end

    npcData._dtReloadUntil = nil
    if npcData._dtSpecialAction == "reload" then
        npcData._dtSpecialAction = nil
        npcData._dtSpecialActionUntil = nil
        npcData._dtSpecialActionMode = nil
    end

    if DTNPC and DTNPC.SetRangedCombatIdleState then
        DTNPC.SetRangedCombatIdleState(zombie, npcData)
    end
    return true
end

function DTNPCProtect.UpdateRangedReloadAction(zombie, npcData, target)
    if not npcData then
        return false, nil
    end

    DTNPCProtect.EnsureRangedRuntime(npcData)

    local reloadUntil = tonumber(npcData._dtReloadUntil) or 0
    if reloadUntil > 0 then
        if (nowMillis() or 0) >= reloadUntil then
            DTNPCProtect.CompleteRangedReload(zombie, npcData)
            return false, "reloaded"
        end

        if target and zombie and target.getX then
            zombie:faceLocation(target:getX(), target:getY())
        end
        if DTNPC and DTNPC.SetRangedCombatIdleState then
            DTNPC.SetRangedCombatIdleState(zombie, npcData)
        end
        return true, "reloading"
    end

    if DTNPCProtect.NeedsRangedReload(npcData) then
        DTNPCProtect.StartRangedReload(zombie, npcData, { faceTarget = target })
        return true, "reload_start"
    end

    return false, nil
end

function DTNPCProtect.ConsumeRangedShot(npcData, amount)
    if not npcData then
        return 0, 0
    end

    local runtime = DTNPCProtect.EnsureRangedRuntime(npcData)
    local spend = math.max(1, math.floor(tonumber(amount) or 1))
    if runtime then
        npcData._dtMagAmmo = math.max(0, math.floor(tonumber(npcData._dtMagAmmo) or runtime.magSize) - spend)
    end

    local remaining = DTNPCProtect.ConsumeAmmo(npcData, spend)
    return math.max(0, tonumber(npcData._dtMagAmmo) or 0), math.max(0, tonumber(remaining) or 0)
end
