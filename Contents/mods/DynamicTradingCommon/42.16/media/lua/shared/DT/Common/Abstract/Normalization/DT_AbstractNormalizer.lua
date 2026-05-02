require "DT/Common/Config"

local Types = require "DT/Common/Abstract/Normalization/DT_AbstractTypes"
local Buckets = require "DT/Common/Abstract/Normalization/DT_AbstractBuckets"
local TagRules = require "DT/Common/Abstract/Normalization/DT_AbstractTagRules"
local Heuristics = require "DT/Common/Abstract/Normalization/DT_AbstractHeuristics"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Abstract = DynamicTrading.Abstract or {}
DynamicTrading.Abstract.Normalization = DynamicTrading.Abstract.Normalization or {}

local Normalizer = DynamicTrading.Abstract.Normalization.Normalizer or {}
DynamicTrading.Abstract.Normalization.Normalizer = Normalizer

local UNIT_MULTIPLIERS = {
    food_raw_fresh = 0.8,
    food_raw_preserved = 0.95,
    meals = 1.0,
    water_clean = 0.35,
    medical_supplies = 1.2,
    tools = 1.1,
    weapon_parts = 1.0,
    ammo_ready = 0.7,
    ammo_components = 0.75,
    fuel = 0.75,
    wood = 0.8,
    metal = 0.95,
    hardware = 0.85,
    textiles = 0.7,
    leather = 0.85,
    electronics = 1.15,
    chemicals = 0.95,
    bindings = 0.65,
}

local function safeCall(target, methodName, ...)
    if not target or type(target[methodName]) ~= "function" then
        return nil
    end
    local ok, result = pcall(target[methodName], target, ...)
    if ok then
        return result
    end
    return nil
end

local function getScriptItem(fullType)
    local manager = (getScriptManager and getScriptManager()) or (ScriptManager and ScriptManager.instance) or nil
    if not manager or not fullType or fullType == "" then
        return nil
    end
    if manager.getItem then
        local item = manager:getItem(fullType)
        if item then
            return item
        end
    end
    return nil
end

local function resolveDisplayName(fullType, itemData, scriptItem)
    local displayName = safeCall(scriptItem, "getDisplayName")
    if displayName and tostring(displayName) ~= "" then
        return tostring(displayName)
    end
    if itemData and itemData.displayName and tostring(itemData.displayName) ~= "" then
        return tostring(itemData.displayName)
    end
    return Types.ShortType(fullType)
end

local function extractTags(itemData)
    local tags = {}
    for _, tag in ipairs(itemData and itemData.tags or {}) do
        if tag ~= nil then
            tags[#tags + 1] = tostring(tag)
        end
    end
    return tags
end

local function buildQualityFlags(tags)
    local flags = {}
    if not tags then
        return flags
    end

    local function push(flag)
        flags[#flags + 1] = flag
    end

    for _, tag in ipairs(tags) do
        local text = tostring(tag or "")
        if text == "Rarity.Rare" then push("rare") end
        if text == "Quality.Luxury" then push("luxury") end
        if text == "Quality.Waste" then push("waste") end
        if text == "Food.LowQuality" then push("low_quality") end
        if text == "Food.HighQuality" then push("high_quality") end
        if text == "Tool.Fragile" then push("fragile") end
        if text == "Resource.Craftable" then push("craftable") end
    end

    return Types.UniqueSortedArray(flags)
end

local function resolveConfidence(source)
    if source == Types.SOURCE.explicit then
        return Types.CONFIDENCE.explicit
    end
    if source == Types.SOURCE.tagRule then
        return Types.CONFIDENCE.tagRule
    end
    if source == Types.SOURCE.scriptHint then
        return Types.CONFIDENCE.scriptHint
    end
    if source == Types.SOURCE.heuristic then
        return Types.CONFIDENCE.heuristic
    end
    return Types.CONFIDENCE.fallback
end

local function calculateBaseUnits(basePrice)
    local price = math.max(0, math.floor(tonumber(basePrice) or 0))
    if price <= 40 then return 1 end
    if price <= 75 then return 2 end
    if price <= 125 then return 3 end
    if price <= 200 then return 4 end
    if price <= 325 then return 6 end
    if price <= 500 then return 8 end
    return 10
end

local function hasFlag(flags, query)
    for _, flag in ipairs(flags or {}) do
        if flag == query then
            return true
        end
    end
    return false
end

local function calculateNormalizedUnits(primaryBucket, basePrice, qualityFlags)
    local units = calculateBaseUnits(basePrice)
    local multiplier = tonumber(UNIT_MULTIPLIERS[primaryBucket]) or 1.0
    units = math.max(1, math.floor(units * multiplier + 0.5))

    if hasFlag(qualityFlags, "luxury") then
        units = units + 2
    end
    if hasFlag(qualityFlags, "high_quality") then
        units = units + 1
    end
    if hasFlag(qualityFlags, "low_quality") then
        units = math.max(1, units - 1)
    end
    if hasFlag(qualityFlags, "waste") then
        units = math.max(1, units - 1)
    end

    return math.max(1, units)
end

function Normalizer.NormalizeItem(fullType, itemData)
    if type(itemData) ~= "table" then
        return nil
    end

    local resolvedFullType = tostring(fullType or itemData.item or "")
    if resolvedFullType == "" then
        return nil
    end

    local scriptItem = getScriptItem(resolvedFullType)
    local tags = extractTags(itemData)
    local displayName = resolveDisplayName(resolvedFullType, itemData, scriptItem)
    local context = {
        fullType = resolvedFullType,
        displayName = displayName,
        shortType = Types.ShortType(resolvedFullType),
        scriptItem = scriptItem,
    }

    local resolution = TagRules.ResolveFromTags(resolvedFullType, tags, context)
    if not resolution then
        resolution = Heuristics.ResolveFromScriptHints(resolvedFullType, itemData, scriptItem)
    end
    if not resolution then
        resolution = Heuristics.ResolveFromNameHeuristics(resolvedFullType, displayName, scriptItem)
    end
    if not resolution then
        return nil
    end

    local qualityFlags = buildQualityFlags(tags)
    local primaryBucket = resolution.primaryBucket
    local basePrice = math.max(0, math.floor(tonumber(itemData.basePrice) or 0))

    return {
        fullType = resolvedFullType,
        displayName = displayName,
        module = Types.ParseModule(resolvedFullType),
        basePrice = basePrice,
        tags = tags,
        primaryBucket = primaryBucket,
        secondaryBuckets = Types.DeepCopyArray(resolution.secondaryBuckets or {}),
        normalizedUnits = calculateNormalizedUnits(primaryBucket, basePrice, qualityFlags),
        qualityFlags = qualityFlags,
        source = tostring(resolution.source or Types.SOURCE.heuristic),
        confidence = resolveConfidence(resolution.source),
        reasons = Types.DeepCopyArray(resolution.reasons or {}),
    }
end

return Normalizer
