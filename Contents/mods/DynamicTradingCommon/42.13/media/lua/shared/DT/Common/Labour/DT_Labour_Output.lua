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

function Output.GenerateForJob(profile)
    local results = {}
    if not profile then return results end

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

function Output.GenerateForProfile(profile)
    return Output.GenerateForJob(profile)
end

return Output
