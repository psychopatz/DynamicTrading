-- ==============================================================================
-- DTNPC_ProtectState_Defaults.lua
-- Default state and shared helper setup for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal

local function nowMillis()
    if getTimeInMillis then
        local ms = tonumber(getTimeInMillis())
        if ms and ms > 0 then
            return math.floor(ms)
        end
    end

    local gt = getGameTime and getGameTime() or nil
    if gt and gt.getWorldAgeHours then
        return math.floor((tonumber(gt:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

local function buildPointTarget(x, y, z)
    if x == nil or y == nil then
        return nil
    end

    local px = tonumber(x)
    local py = tonumber(y)
    local pz = tonumber(z) or 0
    return {
        getX = function() return px end,
        getY = function() return py end,
        getZ = function() return pz end,
    }
end

function DTNPCProtect.EnsureDataDefaults(npcData)
    if not npcData then
        return nil
    end

    if npcData.enableRangedSightAnim == nil then npcData.enableRangedSightAnim = false end
    if npcData.enableMeleeCombatAnim == nil then npcData.enableMeleeCombatAnim = false end
    if npcData.combatResumeState == nil then npcData.combatResumeState = nil end
    if npcData.isPlayerFactionTrader == nil then npcData.isPlayerFactionTrader = false end
    if npcData.combatOrder == nil then npcData.combatOrder = nil end
    if npcData.guardCombatOrder == nil then npcData.guardCombatOrder = nil end
    if npcData.guardAttackMode == nil then npcData.guardAttackMode = nil end
    if npcData.combatTargetID == nil then npcData.combatTargetID = nil end
    if npcData.combatTargetType == nil then npcData.combatTargetType = nil end
    if npcData.combatFallbackAnnouncedAt == nil then npcData.combatFallbackAnnouncedAt = nil end
    if npcData.protectNoticeSerial == nil then npcData.protectNoticeSerial = 0 end
    if npcData.protectNoticeText == nil then npcData.protectNoticeText = nil end
    if npcData.protectNoticeSentiment == nil then npcData.protectNoticeSentiment = "neutral" end
    if npcData.protectNoticeDialogueStatus == nil then npcData.protectNoticeDialogueStatus = nil end
    if npcData.protectNoticeDialogueState == nil then npcData.protectNoticeDialogueState = nil end
    if npcData.companionAmbientMode == nil then npcData.companionAmbientMode = nil end
    if npcData.companionCombatActive == nil then npcData.companionCombatActive = false end
    if npcData.companionLastCombatTargetID == nil then npcData.companionLastCombatTargetID = nil end
    if npcData.companionLastRangedTargetID == nil then npcData.companionLastRangedTargetID = nil end
    if npcData.combatPursuitTargetID == nil then npcData.combatPursuitTargetID = nil end
    if npcData.combatPursuitStartedAt == nil then npcData.combatPursuitStartedAt = 0 end
    if npcData.combatPursuitLastProgressAt == nil then npcData.combatPursuitLastProgressAt = 0 end
    if npcData.combatPursuitLastAttackAt == nil then npcData.combatPursuitLastAttackAt = 0 end
    if npcData.combatPursuitLastDistance == nil then npcData.combatPursuitLastDistance = nil end
    if type(npcData.skillXP) ~= "table" then npcData.skillXP = {} end
    if npcData.loadout == nil or type(npcData.loadout) ~= "table" then
        npcData.loadout = {}
    end

    local loadout = npcData.loadout
    if loadout.rangedWeapon == nil then loadout.rangedWeapon = nil end
    if loadout.rangedAmmoType == nil then loadout.rangedAmmoType = nil end
    if loadout.ammoCount == nil then loadout.ammoCount = 0 end
    if loadout.meleeWeapon == nil then loadout.meleeWeapon = nil end
    if loadout.bag == nil then loadout.bag = nil end
    if loadout.rangedCondition == nil then loadout.rangedCondition = nil end
    if loadout.meleeCondition == nil then loadout.meleeCondition = nil end

    local trackCondition = Internal.isPlayerOwnedTraderRaw(npcData)
    Internal.normalizeWeaponCondition(loadout, "rangedWeapon", "rangedCondition", trackCondition)
    Internal.normalizeWeaponCondition(loadout, "meleeWeapon", "meleeCondition", trackCondition)

    if not trackCondition
        and (not loadout.meleeWeapon or loadout.meleeWeapon == "")
        and (not loadout.rangedWeapon or loadout.rangedWeapon == "") then
        local seededLoadout, loadoutType = Internal.buildSeededWorldLoadout(npcData)
        npcData.loadout = seededLoadout
        npcData.randomLoadoutType = loadoutType
        loadout = npcData.loadout
    end

    if npcData.skillXP.Melee == nil then npcData.skillXP.Melee = 0 end
    if npcData.skillXP.Shooting == nil then npcData.skillXP.Shooting = 0 end
    if DTNPCHealth and DTNPCHealth.EnsureDefaults then
        DTNPCHealth.EnsureDefaults(npcData)
    end

    return npcData
end

function DTNPCProtect.GetStationaryCombatLeashRadius(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    return math.max(1, tonumber(npcData and npcData.stationaryCombatLeashRadius) or tonumber(DTNPCProtect.CONFIG.StationaryCombatLeashRadius) or 10)
end

function DTNPCProtect.GetCombatUnreachableTimeoutMs(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    return math.max(1000, tonumber(npcData and npcData.combatUnreachableTimeoutMs) or tonumber(DTNPCProtect.CONFIG.CombatUnreachableTimeoutMs) or 6000)
end

Internal.ProtectStateNowMillis = nowMillis
Internal.ProtectStateBuildPointTarget = buildPointTarget
