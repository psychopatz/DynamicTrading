-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion_Modes.lua
-- Combat mode and display helpers for companion commands.
-- ==============================================================================

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion
local modules = CompanionUI.Modules or {}

CompanionUI.Modules = modules

if modules.Modes then
    return
end

modules.Modes = true

function CompanionUI.NormalizeFollowSpacingMode(mode)
    local text = string.lower(tostring(mode or ""))
    if text == "far" then
        return "far"
    end
    if text == "near" then
        return "near"
    end
    return nil
end

function CompanionUI.GetFollowSpacingMode(npcData)
    return CompanionUI.NormalizeFollowSpacingMode(npcData and npcData.followSpacingMode or nil) or "near"
end

function CompanionUI.GetFollowSpacingLabel(npcData)
    return CompanionUI.GetFollowSpacingMode(npcData) == "far"
        and CompanionUI.T("DTNPC_UI_Far", nil, "Far")
        or CompanionUI.T("DTNPC_UI_Near", nil, "Near")
end

function CompanionUI.GetAttackTypeLabel(npcData)
    local combatOrder = npcData and npcData.combatOrder or nil
    if combatOrder ~= "ProtectAuto" and combatOrder ~= "ProtectRanged" and combatOrder ~= "ProtectMelee" then
        local state = npcData and npcData.state or nil
        if state == "ProtectAuto" or state == "ProtectRanged" or state == "ProtectMelee" then
            combatOrder = state
        end
    end
    if combatOrder == "ProtectAuto" then
        return CompanionUI.T("DTNPC_UI_Auto", nil, "Auto")
    end
    if combatOrder == "ProtectRanged" then
        return CompanionUI.T("DTNPC_UI_Ranged", nil, "Ranged")
    end
    if combatOrder == "ProtectMelee" then
        return CompanionUI.T("DTNPC_UI_Melee", nil, "Melee")
    end
    return CompanionUI.T("DTNPC_UI_Balanced", nil, "Balanced")
end

function CompanionUI.GetAttackTypeMode(npcData)
    local combatOrder = npcData and npcData.combatOrder or nil
    if combatOrder == "ProtectAuto" or combatOrder == "ProtectRanged" or combatOrder == "ProtectMelee" then
        return combatOrder
    end

    local state = npcData and npcData.state or nil
    if state == "ProtectAuto" or state == "ProtectRanged" or state == "ProtectMelee" then
        return state
    end

    return nil
end

function CompanionUI.GetGuardAttackTypeLabel(npcData)
    local guardOrder = npcData and (npcData.guardCombatOrder or npcData.guardAttackMode) or nil
    if guardOrder == "GuardAuto" then
        return CompanionUI.T("DTNPC_UI_Auto", nil, "Auto")
    end
    if guardOrder == "GuardRanged" then
        return CompanionUI.T("DTNPC_UI_Ranged", nil, "Ranged")
    end
    if guardOrder == "GuardMelee" then
        return CompanionUI.T("DTNPC_UI_Melee", nil, "Melee")
    end
    return CompanionUI.T("DTNPC_UI_Auto", nil, "Auto")
end

function CompanionUI.GetGuardAttackTypeMode(npcData)
    local guardOrder = npcData and (npcData.guardCombatOrder or npcData.guardAttackMode) or nil
    if guardOrder == "GuardAuto" or guardOrder == "GuardRanged" or guardOrder == "GuardMelee" then
        return guardOrder
    end
    return nil
end

function CompanionUI.GetLootCombatOrder(npcData)
    local combatOrder = npcData and npcData.combatOrder or nil
    if combatOrder == "ProtectAuto" or combatOrder == "ProtectRanged" or combatOrder == "ProtectMelee" then
        return combatOrder
    end
    return "ProtectAuto"
end

function CompanionUI.GetRangedAmmoSnapshot(npcData)
    local loadout = npcData and type(npcData.loadout) == "table" and npcData.loadout or nil
    local rangedWeapon = CompanionUI.NormalizeText(loadout and loadout.rangedWeapon or nil)
    if not rangedWeapon then
        return {
            hasRangedWeapon = false,
            ammoCount = 0,
            magAmmo = 0,
            ammoLabel = "0",
            finiteAmmo = false,
        }
    end

    local ammoCount = math.max(0, math.floor(tonumber(loadout and loadout.ammoCount) or 0))
    local finiteAmmo = DTNPCProtect and DTNPCProtect.IsFiniteAmmoTrader and DTNPCProtect.IsFiniteAmmoTrader(npcData) == true or false
    local magAmmo = nil
    if DTNPCProtect and DTNPCProtect.EnsureRangedRuntime then
        DTNPCProtect.EnsureRangedRuntime(npcData)
        magAmmo = math.max(0, math.floor(tonumber(npcData and npcData._dtMagAmmo) or 0))
    end

    return {
        hasRangedWeapon = true,
        ammoCount = ammoCount,
        magAmmo = magAmmo,
        finiteAmmo = finiteAmmo,
        ammoLabel = finiteAmmo and (tostring(magAmmo or 0) .. "/" .. tostring(ammoCount)) or tostring(ammoCount),
    }
end

function CompanionUI.BuildModeOptionLabel(baseLabel, isActive, includeAmmo, ammoInfo)
    local label = tostring(baseLabel or "")
    if not isActive then
        return label
    end

    if includeAmmo then
        local ammoLabel = nil
        if type(ammoInfo) == "table" then
            ammoLabel = ammoInfo.ammoLabel
        end
        if not ammoLabel then
            ammoLabel = tostring(math.max(0, tonumber(ammoInfo) or 0))
        end
        return CompanionUI.T(
            "DTNPC_UI_ModeActiveAmmo",
            {
                label = label,
                ammo = ammoLabel,
            },
            "{label} [ACTIVE] (Ammo: {ammo})"
        )
    end
    return CompanionUI.T("DTNPC_UI_ModeActive", {
        label = label,
    }, "{label} [ACTIVE]")
end

function CompanionUI.BuildModeOptionStyle(isActive, modeKey)
    if not isActive then
        return nil
    end

    if modeKey == "auto" then
        return {
            bgColor = { 0.16, 0.24, 0.36, 1.0 },
            borderColor = { 0.48, 0.70, 0.98, 1.0 },
            textColor = { 0.90, 0.96, 1.0, 1.0 },
        }
    end
    if modeKey == "ranged" then
        return {
            bgColor = { 0.17, 0.31, 0.20, 1.0 },
            borderColor = { 0.48, 0.86, 0.50, 1.0 },
            textColor = { 0.90, 1.0, 0.90, 1.0 },
        }
    end

    return {
        bgColor = { 0.36, 0.20, 0.18, 1.0 },
        borderColor = { 0.95, 0.50, 0.44, 1.0 },
        textColor = { 1.0, 0.92, 0.90, 1.0 },
    }
end
