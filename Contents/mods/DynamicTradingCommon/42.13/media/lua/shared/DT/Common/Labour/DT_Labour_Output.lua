require "DT/Common/Labour/DT_Labour_Config"

DT_Labour = DT_Labour or {}
DT_Labour.Output = DT_Labour.Output or {}

local Config = DT_Labour.Config
local Output = DT_Labour.Output

Output.CandidateCache = Output.CandidateCache or {}

local function matchesAllTags(itemTags, requiredTags)
    if type(itemTags) ~= "table" then return false end
    for _, required in ipairs(requiredTags or {}) do
        if not Config.HasMatchingTag(itemTags, required) then
            return false
        end
    end
    return true
end

local function getCandidates(requiredTags)
    local cacheKey = table.concat(requiredTags or {}, "|")
    if Output.CandidateCache[cacheKey] and #Output.CandidateCache[cacheKey] > 0 then
        return Output.CandidateCache[cacheKey]
    end

    local pool = {}
    local masterList = DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.MasterList or {}
    for fullType, itemData in pairs(masterList) do
        if itemData and matchesAllTags(itemData.tags, requiredTags) then
            pool[#pool + 1] = fullType
        end
    end

    Output.CandidateCache[cacheKey] = pool
    return pool
end

local function applyWeightMultiplier(baseWeight, multiplier)
    local safeWeight = math.max(0, tonumber(baseWeight) or 0)
    local safeMultiplier = tonumber(multiplier)
    if safeWeight <= 0 then
        return 0
    end
    if safeMultiplier == nil then
        return safeWeight
    end
    if safeMultiplier <= 0 then
        return 0
    end
    return math.max(1, math.floor((safeWeight * safeMultiplier) + 0.5))
end

local function buildWeightedScavengeEntries(loadout, siteProfile)
    local entries = {}
    local totalWeight = 0

    local failureWeight = math.max(0, (tonumber(loadout and loadout.failureWeight) or 0)
        + (tonumber(siteProfile and siteProfile.failureWeightDelta) or 0))
    if failureWeight > 0 then
        totalWeight = totalWeight + failureWeight
        entries[#entries + 1] = {
            failure = true,
            weight = failureWeight
        }
    end

    for _, rule in ipairs(Config.ScavengeLootRules or {}) do
        local minTier = math.max(0, tonumber(rule.minTier) or 0)
        if minTier <= math.max(0, tonumber(loadout and loadout.tier) or 0) then
            local isEligible = true

            if rule.requiresAllCapabilities then
                for _, capability in ipairs(rule.requiresAllCapabilities) do
                    if not (loadout and loadout.capabilityMap and loadout.capabilityMap[capability]) then
                        isEligible = false
                        break
                    end
                end
            end

            if isEligible and rule.requiresAnyCapabilities and #rule.requiresAnyCapabilities > 0 then
                isEligible = false
                for _, capability in ipairs(rule.requiresAnyCapabilities) do
                    if loadout and loadout.capabilityMap and loadout.capabilityMap[capability] then
                        isEligible = true
                        break
                    end
                end
            end

            if isEligible then
                local pool = getCandidates(rule.tags)
                if #pool > 0 then
                    local ruleWeights = siteProfile and siteProfile.ruleWeights or nil
                    local weightMultiplier = ruleWeights and ruleWeights[rule.id] or nil
                    local weight = applyWeightMultiplier(rule.weight, weightMultiplier)
                    if weight > 0 then
                        totalWeight = totalWeight + weight
                        entries[#entries + 1] = {
                            rule = rule,
                            pool = pool,
                            weight = weight
                        }
                    end
                end
            end
        end
    end

    return entries, totalWeight
end

local function rollWeightedEntry(entries, totalWeight)
    if not entries or #entries <= 0 or totalWeight <= 0 then
        return nil
    end

    local roll = ZombRand(totalWeight) + 1
    local cursor = 0
    for _, entry in ipairs(entries) do
        cursor = cursor + math.max(0, tonumber(entry.weight) or 0)
        if roll <= cursor then
            return entry
        end
    end

    return entries[#entries]
end

local function getRuleQuantity(rule, loadout)
    local minQty = math.max(1, tonumber(rule and rule.minQty) or 1)
    local maxQty = math.max(minQty, tonumber(rule and rule.maxQty) or minQty)

    if loadout and loadout.bulkLoot then
        local bulkBonus = math.max(0, tonumber(rule and rule.bulkBonus) or 0)
        minQty = minQty + bulkBonus
        maxQty = maxQty + bulkBonus
    end

    if loadout and loadout.bundleLoot then
        local bundleBonus = math.max(0, tonumber(rule and rule.bundleBonus) or 0)
        minQty = minQty + bundleBonus
        maxQty = maxQty + bundleBonus
    end

    return Config.RandomRangeInclusive(minQty, maxQty)
end

local function hasKeys(value)
    if type(value) ~= "table" then
        return false
    end

    for _, _ in pairs(value) do
        return true
    end

    return false
end

function Output.GenerateScavengeLoot(worker)
    local results = {}
    local loadout = Config.GetScavengeLoadout and Config.GetScavengeLoadout(worker) or {}
    local siteProfile = Config.GetScavengeSiteProfile and Config.GetScavengeSiteProfile(worker and worker.scavengeSiteProfileID) or nil
    local poolRolls = math.max(1, tonumber(loadout and loadout.poolRolls) or 1)
        + math.max(0, tonumber(siteProfile and siteProfile.poolRollBonus) or 0)
    local maxPoolRolls = (Config.ScavengeLootDefaults and Config.ScavengeLootDefaults.maxPoolRolls) or poolRolls
    poolRolls = math.max(1, math.min(maxPoolRolls, poolRolls))
    local avoidDuplicates = loadout and loadout.hasRoutePlan == true
    local usedRuleIDs = {}
    local usedFullTypes = {}

    for _ = 1, poolRolls do
        local weightedEntries, totalWeight = buildWeightedScavengeEntries(loadout, siteProfile)
        if avoidDuplicates and hasKeys(usedRuleIDs) then
            local filteredEntries = {}
            local filteredWeight = 0
            for _, entry in ipairs(weightedEntries) do
                if entry.failure or not usedRuleIDs[entry.rule.id] then
                    filteredEntries[#filteredEntries + 1] = entry
                    filteredWeight = filteredWeight + math.max(0, tonumber(entry.weight) or 0)
                end
            end
            if #filteredEntries > 0 then
                weightedEntries = filteredEntries
                totalWeight = filteredWeight
            end
        end

        local selected = rollWeightedEntry(weightedEntries, totalWeight)
        if selected and not selected.failure and selected.pool then
            local pool = selected.pool
            local fullType = nil

            if avoidDuplicates and #pool > 1 then
                for _ = 1, #pool do
                    local candidate = pool[ZombRand(#pool) + 1]
                    if not usedFullTypes[candidate] then
                        fullType = candidate
                        break
                    end
                end
            end

            fullType = fullType or pool[ZombRand(#pool) + 1]
            if fullType then
                results[#results + 1] = {
                    fullType = fullType,
                    qty = getRuleQuantity(selected.rule, loadout)
                }
                if selected.rule and selected.rule.id then
                    usedRuleIDs[selected.rule.id] = true
                end
                usedFullTypes[fullType] = true
            end
        end
    end

    return results
end

function Output.GenerateForJob(profile, worker)
    local results = {}
    if not profile then return results end

    local normalizedJobType = Config.NormalizeJobType and Config.NormalizeJobType(profile.jobType) or profile.jobType
    if normalizedJobType == Config.JobTypes.Scavenge then
        return Output.GenerateScavengeLoot(worker)
    end

    for _, rule in ipairs(profile.outputRules or {}) do
        local pool = getCandidates(rule.tags)
        if #pool > 0 then
            local picks = math.max(1, rule.picks or 1)
            for _ = 1, picks do
                local fullType = pool[ZombRand(#pool) + 1]
                results[#results + 1] = {
                    fullType = fullType,
                    qty = ZombRand((rule.minQty or 1), (rule.maxQty or 1) + 1)
                }
            end
        end
    end

    return results
end

function Output.GenerateForProfile(profile, worker)
    return Output.GenerateForJob(profile, worker)
end

return Output
