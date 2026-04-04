-- ==============================================================================
-- DTNPC_Protect.lua
-- Shared protect/loadout helpers for companion combat behaviors.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}

DTNPCProtect.CONFIG = DTNPCProtect.CONFIG or {
    ScanRadius = 12,
    FloorTolerance = 1,
    StickyRadiusBonus = 1.75,
    NoticeCooldownMs = 12000,
    DiagnosticCooldownMs = 4000,
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
    if not zombie then return nil end

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

local function getSkillSeed(npcData, skillID)
    local seed = tonumber(npcData and npcData.identitySeed) or 1
    local text = tostring(skillID or "Skill")

    for i = 1, #text do
        seed = ((seed * 33) + string.byte(text, i)) % 2147483647
    end

    return seed
end

local function getProfile(npcData)
    if not DynamicTrading or not DynamicTrading.GetArchetypeSkillProfile then
        return nil
    end

    return DynamicTrading.GetArchetypeSkillProfile(npcData and npcData.archetypeID or "General")
end

local function getEquipmentProfile(npcData)
    if not DynamicTrading or not DynamicTrading.GetArchetypeEquipmentProfile then
        return nil
    end

    return DynamicTrading.GetArchetypeEquipmentProfile(npcData and npcData.archetypeID or "General")
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

local function resolveSkillLevel(npcData, skillID)
    npcData._resolvedSkillLevels = npcData._resolvedSkillLevels or {}
    if npcData._resolvedSkillLevels[skillID] ~= nil then
        return npcData._resolvedSkillLevels[skillID]
    end

    local profile = getProfile(npcData)
    local baseRange = profile and profile.baseRanges and profile.baseRanges[skillID] or nil
    local masteryChance = profile and profile.masteryChances and profile.masteryChances[skillID] or 0
    local minValue = baseRange and tonumber(baseRange.min) or 0
    local maxValue = baseRange and tonumber(baseRange.max) or minValue
    if maxValue < minValue then
        maxValue = minValue
    end

    local seed = getSkillSeed(npcData, skillID)
    local level = minValue
    if maxValue > minValue then
        level = minValue + (seed % ((maxValue - minValue) + 1))
    end

    if tonumber(masteryChance) and masteryChance > 0 then
        local masteryRoll = math.floor(seed / 7) % 100
        if masteryRoll < masteryChance then
            level = 20
        end
    end

    npcData._resolvedSkillLevels[skillID] = level
    return level
end

local function getSkillXpBucket(npcData)
    if type(npcData.skillXP) ~= "table" then
        npcData.skillXP = {}
    end
    return npcData.skillXP
end

local function getSkillXpPerLevel(skillID)
    local perLevel = tonumber(DTNPCProtect.SKILL_XP_PER_LEVEL and DTNPCProtect.SKILL_XP_PER_LEVEL[skillID]) or 0
    if perLevel < 1 then
        return 0
    end
    return math.floor(perLevel)
end

local function getEarnedSkillLevelBonus(npcData, skillID)
    local perLevel = getSkillXpPerLevel(skillID)
    if perLevel <= 0 then
        return 0
    end

    local skillXP = getSkillXpBucket(npcData)
    local earnedXP = math.max(0, tonumber(skillXP[skillID]) or 0)
    return math.floor(earnedXP / perLevel)
end

local function rollWeaponDamage(item)
    local minDamage = item and item.getMinDamage and tonumber(item:getMinDamage()) or nil
    local maxDamage = item and item.getMaxDamage and tonumber(item:getMaxDamage()) or nil

    if not minDamage or minDamage <= 0 then
        minDamage = maxDamage or 0.35
    end
    if not maxDamage or maxDamage < minDamage then
        maxDamage = minDamage
    end

    if ZombRandFloat then
        return ZombRandFloat(minDamage, maxDamage)
    end

    return (minDamage + maxDamage) * 0.5
end

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

local function mixLoadoutSeed(npcData, salt)
    local seed = tonumber(npcData and npcData.identitySeed) or 1
    local text = tostring(npcData and npcData.archetypeID or "General") .. ":" .. tostring(salt or "Loadout")

    for i = 1, #text do
        seed = ((seed * 1103515245) + string.byte(text, i) + 12345) % 2147483647
    end

    if seed <= 0 then
        seed = 1
    end

    return seed
end

local function getDeterministicChanceRoll(npcData, salt)
    return (mixLoadoutSeed(npcData, salt) % 10000) / 10000
end

local function getPoolEntryItem(entry)
    if type(entry) == "string" then
        return entry
    end
    if type(entry) ~= "table" then
        return nil
    end
    return entry.item or entry.weapon or entry.bag
end

local function chooseWeightedEquipmentEntry(pool, npcData, salt)
    local totalWeight = 0
    local normalizedPool = {}

    for _, entry in ipairs(type(pool) == "table" and pool or {}) do
        local item = getPoolEntryItem(entry)
        local weight = type(entry) == "table" and math.max(0, tonumber(entry.weight) or 1) or 1
        if item and item ~= "" and weight > 0 then
            normalizedPool[#normalizedPool + 1] = entry
            totalWeight = totalWeight + weight
        end
    end

    if totalWeight <= 0 then
        return nil
    end

    local roll = mixLoadoutSeed(npcData, salt) % totalWeight
    for _, entry in ipairs(normalizedPool) do
        local weight = type(entry) == "table" and math.max(0, tonumber(entry.weight) or 1) or 1
        if roll < weight then
            return entry
        end
        roll = roll - weight
    end

    return normalizedPool[#normalizedPool]
end

local function resolveAmmoCount(entry, npcData, salt)
    if type(entry) ~= "table" then
        return 0
    end

    if entry.ammoCount ~= nil then
        return math.max(0, math.floor(tonumber(entry.ammoCount) or 0))
    end

    local minAmmo = math.max(0, math.floor(tonumber(entry.ammoMin or entry.minAmmo or 0) or 0))
    local maxAmmo = math.max(minAmmo, math.floor(tonumber(entry.ammoMax or entry.maxAmmo or minAmmo) or minAmmo))
    if maxAmmo <= minAmmo then
        return minAmmo
    end

    return minAmmo + (mixLoadoutSeed(npcData, salt) % ((maxAmmo - minAmmo) + 1))
end

local function getResolvedSkillLevel(npcData, skillID)
    return clamp(resolveSkillLevel(npcData, skillID) + getEarnedSkillLevelBonus(npcData, skillID), 0, 20)
end

local function buildSeededWorldLoadout(npcData, forcedType)
    local profile = getEquipmentProfile(npcData) or {}
    local meleeEntry = chooseWeightedEquipmentEntry(profile.meleeWeapons, npcData, "MeleeWeapon")
    local meleeWeapon = getPoolEntryItem(meleeEntry) or "Base.BaseballBat"
    local rangedEntry = nil
    local bagEntry = nil

    local bagChance = math.max(0, math.min(1, tonumber(profile.bagChance) or 0.55))
    if forcedType ~= "nobag" and getDeterministicChanceRoll(npcData, "BagChance") < bagChance then
        bagEntry = chooseWeightedEquipmentEntry(profile.bags, npcData, "Bag")
    end

    local shouldRollRanged = forcedType == "hybrid" or forcedType == "ranged"
    if not shouldRollRanged then
        local rangedChance = type(profile.rangedChance) == "table" and profile.rangedChance or {}
        local shootingLevel = getResolvedSkillLevel(npcData, "Shooting")
        local threshold = math.max(0, math.floor(tonumber(rangedChance.shootingThreshold or rangedChance.threshold) or 8))
        if shootingLevel >= threshold then
            local baseChance = math.max(0, tonumber(rangedChance.base) or 0)
            local perLevel = math.max(0, tonumber(rangedChance.perLevel) or 0)
            local maxChance = math.max(0, math.min(1, tonumber(rangedChance.max) or 0.65))
            local bonusLevels = math.max(0, shootingLevel - threshold + 1)
            local chance = math.max(0, math.min(maxChance, baseChance + (bonusLevels * perLevel)))
            shouldRollRanged = getDeterministicChanceRoll(npcData, "RangedChance") < chance
        end
    end

    if shouldRollRanged and forcedType ~= "melee" then
        rangedEntry = chooseWeightedEquipmentEntry(profile.rangedWeapons, npcData, "RangedWeapon")
    end

    local rangedWeapon = getPoolEntryItem(rangedEntry)
    local loadout = {
        rangedWeapon = rangedWeapon or nil,
        rangedAmmoType = type(rangedEntry) == "table" and (rangedEntry.ammoType or rangedEntry.rangedAmmoType) or nil,
        ammoCount = rangedWeapon and resolveAmmoCount(rangedEntry, npcData, "RangedAmmo") or 0,
        meleeWeapon = meleeWeapon,
        bag = getPoolEntryItem(bagEntry) or nil,
        rangedCondition = nil,
        meleeCondition = nil,
    }

    local loadoutType = "melee"
    if loadout.rangedWeapon and loadout.meleeWeapon then
        loadoutType = "hybrid"
    elseif loadout.rangedWeapon then
        loadoutType = "ranged"
    end

    return loadout, loadoutType
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
    if npcData.combatTargetID == nil then npcData.combatTargetID = nil end
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

    local trackCondition = isPlayerOwnedTraderRaw(npcData)
    normalizeWeaponCondition(loadout, "rangedWeapon", "rangedCondition", trackCondition)
    normalizeWeaponCondition(loadout, "meleeWeapon", "meleeCondition", trackCondition)

    if not trackCondition and (not loadout.meleeWeapon or loadout.meleeWeapon == "") and (not loadout.rangedWeapon or loadout.rangedWeapon == "") then
        local seededLoadout, loadoutType = buildSeededWorldLoadout(npcData)
        npcData.loadout = seededLoadout
        npcData.randomLoadoutType = loadoutType
        loadout = npcData.loadout
    end

    if npcData.skillXP.Melee == nil then npcData.skillXP.Melee = 0 end
    if npcData.skillXP.Shooting == nil then npcData.skillXP.Shooting = 0 end

    return npcData
end

function DTNPCProtect.PushCompanionNotice(zombie, npcData, text, sentiment)
    DTNPCProtect.EnsureDataDefaults(npcData)
    if not npcData or not text or text == "" then
        return false
    end

    npcData.protectNoticeSerial = (tonumber(npcData.protectNoticeSerial) or 0) + 1
    npcData.protectNoticeText = text
    npcData.protectNoticeSentiment = sentiment or "neutral"
    npcData.protectNoticeDialogueStatus = nil
    npcData.protectNoticeDialogueState = nil

    syncProtectNotice(zombie, npcData)

    return true
end

function DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, dialogueStatus, dialogueState)
    DTNPCProtect.EnsureDataDefaults(npcData)
    if not npcData or not dialogueStatus or dialogueStatus == "" or not dialogueState or dialogueState == "" then
        return false
    end

    npcData.protectNoticeSerial = (tonumber(npcData.protectNoticeSerial) or 0) + 1
    npcData.protectNoticeText = nil
    npcData.protectNoticeSentiment = "neutral"
    npcData.protectNoticeDialogueStatus = dialogueStatus
    npcData.protectNoticeDialogueState = dialogueState

    syncProtectNotice(zombie, npcData)

    return true
end

function DTNPCProtect.CopyLoadout(loadout)
    loadout = type(loadout) == "table" and loadout or {}
    return {
        rangedWeapon = loadout.rangedWeapon or nil,
        rangedAmmoType = loadout.rangedAmmoType or nil,
        ammoCount = math.max(0, tonumber(loadout.ammoCount) or 0),
        meleeWeapon = loadout.meleeWeapon or nil,
        bag = loadout.bag or nil,
        rangedCondition = loadout.rangedCondition ~= nil and math.max(0, math.floor(tonumber(loadout.rangedCondition) or 0)) or nil,
        meleeCondition = loadout.meleeCondition ~= nil and math.max(0, math.floor(tonumber(loadout.meleeCondition) or 0)) or nil,
    }
end

function DTNPCProtect.HasExplicitLoadout(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local loadout = npcData.loadout
    return (loadout.rangedWeapon and loadout.rangedWeapon ~= "")
        or (loadout.meleeWeapon and loadout.meleeWeapon ~= "")
end

function DTNPCProtect.IsPlayerOwnedTrader(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    return isPlayerOwnedTraderRaw(npcData)
end

function DTNPCProtect.IsFiniteAmmoTrader(npcData)
    return DTNPCProtect.IsPlayerOwnedTrader(npcData)
end

function DTNPCProtect.GetRandomWorldLoadoutType()
    local weights = DTNPCProtect.LOADOUT_WEIGHTS or {}
    local meleeWeight = math.max(0, tonumber(weights.melee) or 0)
    local rangedWeight = math.max(0, tonumber(weights.ranged) or 0)
    local hybridWeight = math.max(0, tonumber(weights.hybrid) or 0)
    local totalWeight = meleeWeight + rangedWeight + hybridWeight

    if totalWeight <= 0 then
        return "melee"
    end

    local roll = ZombRand(totalWeight)
    if roll < meleeWeight then
        return "melee"
    end
    roll = roll - meleeWeight
    if roll < rangedWeight then
        return "ranged"
    end
    return "hybrid"
end

function DTNPCProtect.GetWorldLoadoutPreset(loadoutType)
    local presets = DTNPCProtect.LOADOUT_PRESETS or {}
    local preset = presets[loadoutType] or presets.melee or {}
    return DTNPCProtect.CopyLoadout(preset)
end

function DTNPCProtect.AssignRandomWorldLoadout(npcData, forcedType)
    DTNPCProtect.EnsureDataDefaults(npcData)

    if DTNPCProtect.IsPlayerOwnedTrader(npcData) or DTNPCProtect.HasExplicitLoadout(npcData) then
        return npcData.loadout
    end

    local loadout, loadoutType = buildSeededWorldLoadout(npcData, forcedType)
    npcData.loadout = loadout
    npcData.randomLoadoutType = loadoutType
    return npcData.loadout
end

function DTNPCProtect.GetTradingDefenseState(npcData, targetDist)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local dist = tonumber(targetDist) or 9999

    if hasMelee and dist <= 2.0 then
        return "TradingDefenseMelee"
    end
    if hasRanged then
        return "TradingDefenseRanged"
    end
    if hasMelee then
        return "TradingDefenseMelee"
    end

    return nil
end

function DTNPCProtect.GetSkillLevel(npcData, skillID)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local baseLevel = resolveSkillLevel(npcData or {}, skillID)
    local earnedBonus = getEarnedSkillLevelBonus(npcData or {}, skillID)
    return clamp(baseLevel + earnedBonus, 0, 20)
end

function DTNPCProtect.GetSkillXP(npcData, skillID)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local skillXP = getSkillXpBucket(npcData)
    return math.max(0, tonumber(skillXP[skillID]) or 0)
end

function DTNPCProtect.AddSkillXP(npcData, skillID, amount)
    if not npcData or not skillID then
        return 0
    end

    DTNPCProtect.EnsureDataDefaults(npcData)
    local gain = math.max(0, tonumber(amount) or 0)
    if gain <= 0 then
        return DTNPCProtect.GetSkillXP(npcData, skillID)
    end

    local skillXP = getSkillXpBucket(npcData)
    skillXP[skillID] = math.max(0, tonumber(skillXP[skillID]) or 0) + gain
    return skillXP[skillID]
end

function DTNPCProtect.GetRangedAmmoType(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local loadout = npcData.loadout
    if loadout.rangedAmmoType and loadout.rangedAmmoType ~= "" then
        return loadout.rangedAmmoType
    end

    local scriptItem = getScriptItem(loadout.rangedWeapon)
    if scriptItem and scriptItem.getAmmoType then
        local ammoType = scriptItem:getAmmoType()
        if ammoType and ammoType ~= "" then
            return ammoType
        end
    end

    return nil
end

function DTNPCProtect.HasUsableRangedLoadout(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local loadout = npcData.loadout
    local weapon = loadout.rangedWeapon
    if not weapon then
        return false
    end

    local scriptItem = getScriptItem(weapon)
    if not isRangedWeapon(weapon, scriptItem) then
        return false
    end

    local ammoType = DTNPCProtect.GetRangedAmmoType(npcData)
    if scriptItem and scriptItem.getAmmoType then
        local expectedAmmoType = scriptItem:getAmmoType()
        if expectedAmmoType and expectedAmmoType ~= "" and ammoType ~= expectedAmmoType then
            return false
        end
    end

    local ammoCount = tonumber(loadout.ammoCount) or 0
    if not ammoType or ammoType == "" then
        return false
    end
    if DTNPCProtect.IsFiniteAmmoTrader(npcData) and ammoCount <= 0 then
        return false
    end
    if DTNPCProtect.IsPlayerOwnedTrader(npcData)
        and loadout.rangedCondition ~= nil
        and tonumber(loadout.rangedCondition) <= 0 then
        return false
    end

    return true
end

function DTNPCProtect.HasUsableMeleeLoadout(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local weapon = npcData.loadout.meleeWeapon
    if not weapon then
        return false
    end

    if DTNPCProtect.IsPlayerOwnedTrader(npcData)
        and npcData.loadout.meleeCondition ~= nil
        and tonumber(npcData.loadout.meleeCondition) <= 0 then
        return false
    end

    return isMeleeWeapon(weapon, getScriptItem(weapon))
end

function DTNPCProtect.GetRequestedProtectState(npcData, preferredState)
    DTNPCProtect.EnsureDataDefaults(npcData)
    if preferredState == "ProtectRanged" or preferredState == "ProtectMelee" or preferredState == "ProtectAuto" then
        return preferredState
    end
    if npcData.combatOrder == "ProtectRanged" or npcData.combatOrder == "ProtectMelee" or npcData.combatOrder == "ProtectAuto" then
        return npcData.combatOrder
    end
    if npcData.state == "ProtectRanged" or npcData.state == "ProtectMelee" or npcData.state == "ProtectAuto" then
        return npcData.state
    end
    return nil
end

function DTNPCProtect.GetAutoProtectState(npcData, targetDist)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    if not hasRanged and not hasMelee then
        return nil
    end

    local distance = tonumber(targetDist) or 9999
    if hasMelee and distance <= 1.85 then
        return "ProtectMelee"
    end
    if hasRanged then
        return "ProtectRanged"
    end
    if hasMelee then
        return "ProtectMelee"
    end

    return nil
end

function DTNPCProtect.BuildFallbackNotice(requestedState, resolvedState)
    if resolvedState == "ProtectMelee" and requestedState == "ProtectRanged" then
        return "No firearm ready. Switching to melee.", "warning"
    end
    if resolvedState == "ProtectRanged" and requestedState == "ProtectMelee" then
        return "No melee weapon ready. Switching to ranged.", "warning"
    end
    if requestedState == "ProtectRanged" then
        return "Can't cover you. No usable firearm.", "warning"
    end
    if requestedState == "ProtectMelee" then
        return "Can't protect up close. No melee weapon.", "warning"
    end
    return nil, nil
end

function DTNPCProtect.PushFallbackNotice(npcData, text, sentiment)
    DTNPCProtect.EnsureDataDefaults(npcData)
    if not text or text == "" then
        return false
    end

    local currentTime = nowMillis()
    local lastTime = tonumber(npcData.combatFallbackAnnouncedAt) or 0
    if currentTime > 0 and lastTime > 0 and (currentTime - lastTime) < DTNPCProtect.CONFIG.NoticeCooldownMs then
        return false
    end

    npcData.combatFallbackAnnouncedAt = currentTime
    npcData.protectNoticeSerial = (tonumber(npcData.protectNoticeSerial) or 0) + 1
    npcData.protectNoticeText = text
    npcData.protectNoticeSentiment = sentiment or "neutral"
    npcData.protectNoticeDialogueStatus = nil
    npcData.protectNoticeDialogueState = nil
    return true
end

function DTNPCProtect.LogProtectDebug(npcData, label, detail)
    local prefix = tostring(npcData and (npcData.name or npcData.uuid) or "Unknown NPC")
    local suffix = tostring(label or "debug")
    local extra = detail and (" | " .. tostring(detail)) or ""
    protectLog(prefix .. " | " .. suffix .. extra .. " | " .. buildProtectDebugSummary(npcData))
end

function DTNPCProtect.ReportCombatIssue(zombie, npcData, issueKey, text, sentiment, detail, cooldownMs)
    if not npcData then
        return false
    end

    DTNPCProtect.EnsureDataDefaults(npcData)

    local key = tostring(issueKey or "generic")
    local currentTime = nowMillis()
    local cooldown = math.max(0, tonumber(cooldownMs) or tonumber(DTNPCProtect.CONFIG.DiagnosticCooldownMs) or 4000)
    npcData._protectDiagnosticTimes = type(npcData._protectDiagnosticTimes) == "table" and npcData._protectDiagnosticTimes or {}

    local lastTime = tonumber(npcData._protectDiagnosticTimes[key]) or 0
    if currentTime > 0 and lastTime > 0 and (currentTime - lastTime) < cooldown then
        return false
    end
    npcData._protectDiagnosticTimes[key] = currentTime

    if text and text ~= "" then
        npcData.protectNoticeSerial = (tonumber(npcData.protectNoticeSerial) or 0) + 1
        npcData.protectNoticeText = text
        npcData.protectNoticeSentiment = sentiment or "warning"
        npcData.protectNoticeDialogueStatus = nil
        npcData.protectNoticeDialogueState = nil
        syncProtectNotice(zombie, npcData)
    end

    DTNPCProtect.LogProtectDebug(npcData, key, detail or text)
    return true
end

function DTNPCProtect.ResolveProtectState(npcData, preferredState)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local requestedState = DTNPCProtect.GetRequestedProtectState(npcData, preferredState)
    if requestedState ~= "ProtectRanged" and requestedState ~= "ProtectMelee" and requestedState ~= "ProtectAuto" then
        return nil
    end

    if requestedState == "ProtectAuto" then
        return DTNPCProtect.GetAutoProtectState(npcData)
    end

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local resolvedState = nil

    if requestedState == "ProtectRanged" then
        if hasRanged then
            resolvedState = "ProtectRanged"
        elseif hasMelee then
            resolvedState = "ProtectMelee"
        end
    elseif requestedState == "ProtectMelee" then
        if hasMelee then
            resolvedState = "ProtectMelee"
        elseif hasRanged then
            resolvedState = "ProtectRanged"
        end
    end

    if resolvedState ~= requestedState then
        local text, sentiment = DTNPCProtect.BuildFallbackNotice(requestedState, resolvedState)
        DTNPCProtect.PushFallbackNotice(npcData, text, sentiment)
    end

    return resolvedState
end

function DTNPCProtect.ClearCombatTarget(npcData)
    if npcData then
        npcData.combatTargetID = nil
    end
end

function DTNPCProtect.SelectNearestZombie(zombie, npcData, radius, anchorTarget, anchorRadius)
    if not zombie then return nil, 9999 end

    DTNPCProtect.EnsureDataDefaults(npcData)
    local searchRadius = tonumber(radius) or DTNPCProtect.CONFIG.ScanRadius
    local keepRadius = searchRadius + DTNPCProtect.CONFIG.StickyRadiusBonus
    local anchorSearchRadius = tonumber(anchorRadius)
    local anchorKeepRadius = anchorSearchRadius and (anchorSearchRadius + DTNPCProtect.CONFIG.StickyRadiusBonus) or nil
    local zombieList = getCell() and getCell():getZombieList() or nil
    if not zombieList then
        DTNPCProtect.ClearCombatTarget(npcData)
        return nil, 9999
    end

    local currentTarget = nil
    local currentDistance = 9999
    local nearestTarget = nil
    local nearestDistance = 9999
    local currentTargetID = npcData.combatTargetID
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    local ax = anchorTarget and anchorTarget.getX and anchorTarget:getX() or nil
    local ay = anchorTarget and anchorTarget.getY and anchorTarget:getY() or nil
    local az = anchorTarget and anchorTarget.getZ and anchorTarget:getZ() or nil

    for i = 0, zombieList:size() - 1 do
        local candidate = zombieList:get(i)
        if candidate and candidate ~= zombie and not candidate:isDead() then
            local modData = candidate:getModData()
            if not (modData and modData.IsDTNPC) and math.abs((candidate:getZ() or 0) - zz) <= DTNPCProtect.CONFIG.FloorTolerance then
                local dx = candidate:getX() - zx
                local dy = candidate:getY() - zy
                local dist = math.sqrt((dx * dx) + (dy * dy))
                local candidateID = getZombieRuntimeID(candidate)
                local anchorDist = nil

                if ax ~= nil and ay ~= nil then
                    if az ~= nil and math.abs((candidate:getZ() or 0) - az) > DTNPCProtect.CONFIG.FloorTolerance then
                        anchorDist = 9999
                    else
                        local adx = candidate:getX() - ax
                        local ady = candidate:getY() - ay
                        anchorDist = math.sqrt((adx * adx) + (ady * ady))
                    end
                end

                local withinAnchorAcquire = anchorSearchRadius == nil or (anchorDist ~= nil and anchorDist <= anchorSearchRadius)
                local withinAnchorKeep = anchorKeepRadius == nil or (anchorDist ~= nil and anchorDist <= anchorKeepRadius)

                if currentTargetID and candidateID == currentTargetID and dist <= keepRadius and withinAnchorKeep then
                    currentTarget = candidate
                    currentDistance = dist
                end

                if withinAnchorAcquire and dist <= searchRadius and dist < nearestDistance then
                    nearestTarget = candidate
                    nearestDistance = dist
                end
            end
        end
    end

    local chosen = currentTarget or nearestTarget
    local distance = currentTarget and currentDistance or nearestDistance
    if chosen then
        npcData.combatTargetID = getZombieRuntimeID(chosen)
        return chosen, distance
    end

    DTNPCProtect.ClearCombatTarget(npcData)
    return nil, 9999
end

function DTNPCProtect.ConsumeAmmo(npcData, amount)
    DTNPCProtect.EnsureDataDefaults(npcData)
    if not DTNPCProtect.IsFiniteAmmoTrader(npcData) then
        return tonumber(npcData.loadout.ammoCount) or 0
    end

    local spend = math.max(1, math.floor(tonumber(amount) or 1))
    local current = tonumber(npcData.loadout.ammoCount) or 0
    current = math.max(0, current - spend)
    npcData.loadout.ammoCount = current
    return current
end

function DTNPCProtect.GetWeaponCondition(npcData, slot)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local loadout = npcData.loadout
    if slot == "ranged" then
        return loadout.rangedCondition
    end
    if slot == "melee" then
        return loadout.meleeCondition
    end
    return nil
end

function DTNPCProtect.CreateLoadoutWeaponItem(npcData, slot)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local loadout = npcData.loadout
    local weaponKey = nil
    local conditionKey = nil
    if slot == "ranged" then
        weaponKey = "rangedWeapon"
        conditionKey = "rangedCondition"
    elseif slot == "melee" then
        weaponKey = "meleeWeapon"
        conditionKey = "meleeCondition"
    else
        return nil
    end

    local fullType = loadout[weaponKey]
    if not fullType or fullType == "" then
        return nil
    end

    local item = createConditionProbeItem(fullType)
    if not item then
        return nil
    end

    local currentCondition = tonumber(loadout[conditionKey])
    if currentCondition ~= nil and item.setCondition then
        local maxCondition = item.getConditionMax and tonumber(item:getConditionMax()) or nil
        local appliedCondition = math.max(0, math.floor(currentCondition))
        if maxCondition and appliedCondition > maxCondition then
            appliedCondition = maxCondition
        end
        item:setCondition(appliedCondition)
    end

    return item
end

function DTNPCProtect.ConsumeWeaponCondition(npcData, slot, amount)
    DTNPCProtect.EnsureDataDefaults(npcData)

    if not DTNPCProtect.IsPlayerOwnedTrader(npcData) then
        return nil
    end

    local loadout = npcData.loadout
    local weaponKey = nil
    local conditionKey = nil
    if slot == "ranged" then
        weaponKey = "rangedWeapon"
        conditionKey = "rangedCondition"
    elseif slot == "melee" then
        weaponKey = "meleeWeapon"
        conditionKey = "meleeCondition"
    else
        return nil
    end

    local weapon = loadout[weaponKey]
    if not weapon or weapon == "" then
        loadout[conditionKey] = nil
        return nil
    end

    local maxCondition = getConditionMax(weapon)
    if not maxCondition then
        loadout[conditionKey] = nil
        return nil
    end

    local currentCondition = tonumber(loadout[conditionKey])
    if currentCondition == nil then
        currentCondition = maxCondition
    end
    currentCondition = math.max(0, math.min(maxCondition, math.floor(currentCondition)))

    local spend = math.max(1, math.floor(tonumber(amount) or 1))
    local maintenanceLevel = DTNPCProtect.GetSkillLevel(npcData, "Maintenance")
    local probeItem = createConditionProbeItem(weapon)
    if probeItem and probeItem.setCondition then
        probeItem:setCondition(currentCondition)
    end

    if probeItem and probeItem.damageCheck and probeItem.getCondition then
        local ok = pcall(function()
            probeItem:damageCheck(maintenanceLevel, spend, true)
        end)
        if ok then
            local nextCondition = tonumber(probeItem:getCondition())
            if nextCondition ~= nil then
                currentCondition = math.max(0, math.min(maxCondition, math.floor(nextCondition)))
                loadout[conditionKey] = currentCondition
                return currentCondition
            end
        end
    end

    local lowerChance = probeItem and probeItem.getConditionLowerChance
        and tonumber(probeItem:getConditionLowerChance())
        or 1000000
    if not lowerChance or lowerChance < 1 then
        lowerChance = 1000000
    end

    local maintenanceBonus = 1 + (math.max(0, tonumber(maintenanceLevel) or 0) * 0.5)
    local rollMax = math.max(1, math.floor(lowerChance * maintenanceBonus * spend))
    if ZombRand(rollMax) ~= 0 then
        loadout[conditionKey] = currentCondition
        return currentCondition
    end

    currentCondition = math.max(0, currentCondition - spend)
    loadout[conditionKey] = currentCondition
    return currentCondition
end

function DTNPCProtect.GetRangedCombatStats(npcData)
    local shooting = DTNPCProtect.GetSkillLevel(npcData, "Shooting")
    local normalized = math.min(math.max(shooting, 0), 20) / 20
    local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "ranged")
    local avgDamage = rollWeaponDamage(weaponItem)
    local scaledDamage = avgDamage * (0.75 + (normalized * 0.75))

    return {
        hitStill = math.floor(22 + (normalized * 58)),
        hitMove = math.floor(10 + (normalized * 35)),
        fireRate = math.max(36, math.floor(96 - (normalized * 44))),
        damage = math.max(0.22 + (normalized * 0.5), scaledDamage),
    }
end

function DTNPCProtect.GetMeleeCombatStats(npcData)
    local melee = DTNPCProtect.GetSkillLevel(npcData, "Melee")
    local normalized = math.min(math.max(melee, 0), 20) / 20
    local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "melee")
    local weaponRange = weaponItem and weaponItem.getMaxRange and tonumber(weaponItem:getMaxRange()) or 1.0
    local avgDamage = rollWeaponDamage(weaponItem)
    local scaledDamage = avgDamage * (0.8 + (normalized * 0.9))

    return {
        hitChance = math.floor(55 + (normalized * 40)),
        attackRate = math.max(16, math.floor(34 - (normalized * 18))),
        damage = math.max(0.45, scaledDamage),
        chaseSpeed = 0.05 + (normalized * 0.025),
        reach = clamp(weaponRange + 0.15, 1.15, 1.9),
    }
end

function DTNPCProtect.ApplyCombatHit(zombie, npcData, target, options)
    if not zombie or not target or target:isDead() then
        return false, false
    end

    options = type(options) == "table" and options or {}
    local attackType = options.attackType or "generic"
    local damage = math.max(0.05, tonumber(options.damage) or 0.1)
    local applied = false

    if attackType == "ranged" then
        local shootingSkill = DTNPCProtect.GetSkillLevel(npcData, "Shooting")
        local normalized = math.min(math.max(shootingSkill, 0), 20) / 20
        local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "ranged")

        if weaponItem then
            damage = math.max(damage, rollWeaponDamage(weaponItem) * (0.75 + (normalized * 0.75)))

            if target.setBumpDone then
                target:setBumpDone(true)
            end
            if target.setPlayerAttackPosition and target.testDotSide then
                target:setPlayerAttackPosition(target:testDotSide(zombie))
            end
            if target.setHitFromBehind and zombie.isBehind then
                local ok, behind = pcall(function()
                    return zombie:isBehind(target)
                end)
                if ok then
                    target:setHitFromBehind(behind == true)
                end
            end
            if target.setHitReaction then
                target:setHitReaction("ShotBelly")
            end

            local cell = getCell()
            local fakeZombie = cell and cell.getFakeZombieForHit and cell:getFakeZombieForHit() or nil
            local didHit = pcall(function()
                target:Hit(weaponItem, fakeZombie or zombie, damage, false, 1, false)
            end)
            if didHit then
                applied = true
                if target.setAttackedBy then
                    target:setAttackedBy(zombie)
                end
            end
        end
    elseif attackType == "melee" then
        local meleeSkill = DTNPCProtect.GetSkillLevel(npcData, "Melee")
        local normalized = math.min(math.max(meleeSkill, 0), 20) / 20
        local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "melee")

        if weaponItem then
            damage = math.max(damage, rollWeaponDamage(weaponItem) * (0.8 + (normalized * 0.9)))

            if target.setPlayerAttackPosition and target.testDotSide then
                target:setPlayerAttackPosition(target:testDotSide(zombie))
            end
            if target.setHitHeadWhileOnFloor then
                target:setHitHeadWhileOnFloor(0)
            end
            if target.setHitLegsWhileOnFloor then
                target:setHitLegsWhileOnFloor(false)
            end
            if target.setAttackedBy then
                target:setAttackedBy(zombie)
            end
            if target.setHitFromBehind and zombie.isBehind then
                local ok, behind = pcall(function()
                    return zombie:isBehind(target)
                end)
                if ok then
                    target:setHitFromBehind(behind == true)
                end
            end

            local cell = getCell()
            local fakeZombie = cell and cell.getFakeZombieForHit and cell:getFakeZombieForHit() or nil
            local didHit = pcall(function()
                target:Hit(weaponItem, fakeZombie or zombie, damage, false, 1, false)
            end)
            if didHit then
                applied = true
                local hitSound = weaponItem.getZombieHitSound and weaponItem:getZombieHitSound() or nil
                if hitSound and hitSound ~= "" and target.playSound then
                    target:playSound(hitSound)
                elseif target.getEmitter then
                    target:getEmitter():playSound("ZombieImpact")
                end
            end
        end
    end

    if not applied then
        target:setHealth(target:getHealth() - damage)
        if target.getEmitter then
            target:getEmitter():playSound("ZombieImpact")
        end
        applied = true
    end

    local killed = target:isDead() or target:getHealth() <= 0
    if killed then
        if not target:isDead() then
            target:Kill(zombie)
        end
    elseif target.setHitReaction then
        target:setHitReaction(attackType == "ranged" and "ShotBelly" or "HitReaction")
    end

    if applied and (attackType == "melee" or attackType == "ranged") then
        local skillID = attackType == "ranged" and "Shooting" or "Melee"
        local xpGain = attackType == "ranged"
            and (DTNPCProtect.COMBAT_SKILL_XP.ShootingHit or 0)
            or (DTNPCProtect.COMBAT_SKILL_XP.MeleeHit or 0)
        if killed then
            xpGain = xpGain + (
                attackType == "ranged"
                    and (DTNPCProtect.COMBAT_SKILL_XP.ShootingKillBonus or 0)
                    or (DTNPCProtect.COMBAT_SKILL_XP.MeleeKillBonus or 0)
            )
        end
        DTNPCProtect.AddSkillXP(npcData, skillID, xpGain)
    end

    return applied, killed
end
