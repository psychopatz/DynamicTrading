-- ==============================================================================
-- DTNPC_ProtectLoadout_Seeded.lua
-- Seeded world-loadout generation for DTNPC protect loadouts.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getResolvedSkillLevel = Internal.getResolvedSkillLevel

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

Internal.mixLoadoutSeed = mixLoadoutSeed
Internal.getDeterministicChanceRoll = getDeterministicChanceRoll
Internal.getPoolEntryItem = getPoolEntryItem
Internal.chooseWeightedEquipmentEntry = chooseWeightedEquipmentEntry
Internal.resolveAmmoCount = resolveAmmoCount
Internal.buildSeededWorldLoadout = buildSeededWorldLoadout
