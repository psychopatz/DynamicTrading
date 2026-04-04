-- ==============================================================================
-- DTNPC_ProtectLoadout_logic.lua
-- Loadout, ammo, and weapon classification logic for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local lower = Internal.lower
local getScriptItem = Internal.getScriptItem
local getResolvedSkillLevel = Internal.getResolvedSkillLevel

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

local function buildSeededWorldLoadout(npcData, forcedType)
    local profile = Internal.getEquipmentProfile(npcData) or {}
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

Internal.isRangedWeapon = isRangedWeapon
Internal.isMeleeWeapon = isMeleeWeapon
Internal.mixLoadoutSeed = mixLoadoutSeed
Internal.getDeterministicChanceRoll = getDeterministicChanceRoll
Internal.getPoolEntryItem = getPoolEntryItem
Internal.chooseWeightedEquipmentEntry = chooseWeightedEquipmentEntry
Internal.resolveAmmoCount = resolveAmmoCount
Internal.buildSeededWorldLoadout = buildSeededWorldLoadout

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
    return Internal.isPlayerOwnedTraderRaw(npcData)
end

function DTNPCProtect.IsFiniteAmmoTrader(npcData)
    return DTNPCProtect.IsPlayerOwnedTrader(npcData)
end

function DTNPCProtect.ShouldConsumeWeaponDurability(npcData)
    return Internal.shouldConsumeWeaponDurabilityRaw(npcData)
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
