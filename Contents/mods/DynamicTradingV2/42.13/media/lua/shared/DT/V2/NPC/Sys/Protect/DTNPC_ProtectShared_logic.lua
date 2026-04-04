-- ==============================================================================
-- DTNPC_ProtectShared_logic.lua
-- Shared constants and internal helper functions for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal

DTNPCProtect.CONFIG = DTNPCProtect.CONFIG or {
    ScanRadius = 12,
    FloorTolerance = 1,
    StickyRadiusBonus = 1.75,
    NoticeCooldownMs = 12000,
    DiagnosticCooldownMs = 4000,
    HostilePlayerRepThreshold = -40,
    StationaryPostResetDistance = 4,
}

DTNPCProtect.LOADOUT_WEIGHTS = DTNPCProtect.LOADOUT_WEIGHTS or {
    melee = 45,
    ranged = 45,
    hybrid = 10,
}

DTNPCProtect.LOADOUT_PRESETS = DTNPCProtect.LOADOUT_PRESETS or {
    melee = {
        rangedWeapon = nil,
        rangedAmmoType = nil,
        ammoCount = 0,
        meleeWeapon = "Base.BaseballBat",
        bag = nil,
    },
    ranged = {
        rangedWeapon = "Base.Pistol",
        rangedAmmoType = "Base.Bullets9mm",
        ammoCount = 24,
        meleeWeapon = nil,
        bag = nil,
    },
    hybrid = {
        rangedWeapon = "Base.Pistol",
        rangedAmmoType = "Base.Bullets9mm",
        ammoCount = 24,
        meleeWeapon = "Base.BaseballBat",
        bag = nil,
    },
}

DTNPCProtect.SKILL_XP_PER_LEVEL = DTNPCProtect.SKILL_XP_PER_LEVEL or {
    Melee = 80,
    Shooting = 100,
}

DTNPCProtect.COMBAT_SKILL_XP = DTNPCProtect.COMBAT_SKILL_XP or {
    MeleeHit = 4,
    MeleeKillBonus = 18,
    ShootingHit = 4,
    ShootingKillBonus = 16,
}

local function nowMillis()
    if getTimeInMillis then
        return getTimeInMillis()
    end
    return 0
end

local function protectLog(message)
    local line = "[DTNPC Protect] " .. tostring(message or "")
    print(line)

    if DynamicTrading and DynamicTrading.Log then
        pcall(function()
            DynamicTrading.Log("DTV2", "NPC", "Protect", tostring(message or ""))
        end)
    end
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function clamp(value, minValue, maxValue)
    local numeric = tonumber(value) or minValue
    if numeric < minValue then
        return minValue
    end
    if numeric > maxValue then
        return maxValue
    end
    return numeric
end

local function getScriptItem(fullType)
    if not fullType or fullType == "" or not getScriptManager then
        return nil
    end

    local manager = getScriptManager()
    if manager and manager.FindItem then
        return manager:FindItem(fullType)
    end

    return nil
end

local function getConditionMax(fullType)
    local scriptItem = getScriptItem(fullType)
    if scriptItem and scriptItem.getConditionMax then
        local maxCondition = tonumber(scriptItem:getConditionMax()) or 0
        if maxCondition > 0 then
            return math.floor(maxCondition)
        end
    end
    return nil
end

local function createConditionProbeItem(fullType)
    if not fullType or fullType == "" then
        return nil
    end

    if instanceItem then
        return instanceItem(fullType)
    end

    if InventoryItemFactory and InventoryItemFactory.CreateItem then
        return InventoryItemFactory.CreateItem(fullType)
    end

    return nil
end

local function normalizeWeaponCondition(loadout, weaponKey, conditionKey, trackCondition)
    local weapon = loadout[weaponKey]
    if not weapon or weapon == "" then
        loadout[conditionKey] = nil
        return
    end

    if not trackCondition then
        loadout[conditionKey] = nil
        return
    end

    local maxCondition = getConditionMax(weapon)
    if not maxCondition then
        loadout[conditionKey] = nil
        return
    end

    local currentCondition = tonumber(loadout[conditionKey])
    if currentCondition == nil then
        currentCondition = maxCondition
    end

    currentCondition = math.max(0, math.min(maxCondition, math.floor(currentCondition)))
    loadout[conditionKey] = currentCondition
end

local function getZombieRuntimeID(zombie)
    if not zombie then
        return nil
    end

    local outfitID = zombie.getPersistentOutfitID and zombie:getPersistentOutfitID() or nil
    if outfitID and outfitID ~= 0 then
        return "outfit:" .. tostring(outfitID)
    end

    local objectID = zombie.getID and zombie:getID() or nil
    if objectID then
        return "id:" .. tostring(objectID)
    end

    return tostring(zombie)
end

local function getPlayerRuntimeID(player)
    if not player then
        return nil
    end

    local onlineID = player.getOnlineID and player:getOnlineID() or nil
    if onlineID and onlineID ~= 0 then
        return "online:" .. tostring(onlineID)
    end

    local username = player.getUsername and player:getUsername() or nil
    if username and username ~= "" then
        return "user:" .. tostring(username)
    end

    return "player:" .. tostring(player)
end

local function syncProtectNotice(zombie, npcData)
    if not zombie or not npcData or not npcData.uuid then
        return false
    end
    if not DTNPCServerCore or not DTNPCServerCore.SyncToAllClients then
        return false
    end

    local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
    if ownedZombie ~= zombie then
        return false
    end

    DTNPCServerCore.SyncToAllClients(zombie, npcData)
    if DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, npcData)
    end
    return true
end

local function buildProtectDebugSummary(npcData)
    npcData = type(npcData) == "table" and npcData or {}
    local loadout = type(npcData.loadout) == "table" and npcData.loadout or {}

    return table.concat({
        "uuid=" .. tostring(npcData.uuid or "?"),
        "state=" .. tostring(npcData.state or "nil"),
        "order=" .. tostring(npcData.combatOrder or "nil"),
        "melee=" .. tostring(loadout.meleeWeapon or "nil"),
        "ranged=" .. tostring(loadout.rangedWeapon or "nil"),
        "ammo=" .. tostring(loadout.ammoCount or 0),
    }, " | ")
end

local function isPlayerOwnedTraderRaw(npcData)
    if not npcData then
        return false
    end

    if npcData.isPlayerFactionTrader == true then
        return true
    end

    if npcData.masterID ~= nil then
        return true
    end
    if npcData.master and tostring(npcData.master) ~= "" then
        return true
    end

    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local faction = DynamicTrading_Factions.GetFaction(npcData.factionID)
        if faction and faction.playerOwned == true then
            return true
        end
    end

    return npcData.linkedWorkerID ~= nil
end

local function isWeaponDurabilitySandboxEnabled()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    if sandbox and sandbox.NPCWeaponDurability ~= nil then
        return sandbox.NPCWeaponDurability ~= false
    end
    return true
end

local function shouldConsumeWeaponDurabilityRaw(npcData)
    return isPlayerOwnedTraderRaw(npcData) and isWeaponDurabilitySandboxEnabled()
end

Internal.nowMillis = nowMillis
Internal.protectLog = protectLog
Internal.lower = lower
Internal.clamp = clamp
Internal.getScriptItem = getScriptItem
Internal.getConditionMax = getConditionMax
Internal.createConditionProbeItem = createConditionProbeItem
Internal.normalizeWeaponCondition = normalizeWeaponCondition
Internal.getZombieRuntimeID = getZombieRuntimeID
Internal.getPlayerRuntimeID = getPlayerRuntimeID
Internal.syncProtectNotice = syncProtectNotice
Internal.buildProtectDebugSummary = buildProtectDebugSummary
Internal.isPlayerOwnedTraderRaw = isPlayerOwnedTraderRaw
Internal.isWeaponDurabilitySandboxEnabled = isWeaponDurabilitySandboxEnabled
Internal.shouldConsumeWeaponDurabilityRaw = shouldConsumeWeaponDurabilityRaw

DTNPCProtect.GetPlayerRuntimeID = getPlayerRuntimeID
