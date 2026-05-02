DynamicTrading = DynamicTrading or {}
DynamicTrading.ItemUsabilityRanker = DynamicTrading.ItemUsabilityRanker or {}
DynamicTrading.ItemUseabilityRanker = DynamicTrading.ItemUsabilityRanker

local Ranker = DynamicTrading.ItemUsabilityRanker

Ranker.VERSION = 1

local State = {
    dirty = true,
    dirtyReason = "initial",
    profilesByKey = {},
    profilesByType = {},
    order = {},
    itemCount = 0,
    registrySignature = "",
    priceSignature = "",
    buildCount = 0,
}

local unpackArgs = unpack or table.unpack

local function logRanker(level, message)
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "Items", level or "Info", "[Ranker] " .. tostring(message or ""))
    elseif print then
        print("[DynamicTrading][ItemUsabilityRanker] " .. tostring(message or ""))
    end
end

local function deepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, child in pairs(value) do
        copy[key] = deepCopy(child)
    end
    return copy
end

local function clamp(value, minValue, maxValue)
    local number = tonumber(value) or 0
    if number < minValue then
        return minValue
    end
    if number > maxValue then
        return maxValue
    end
    return number
end

local function trim(value)
    local text = tostring(value or "")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    return text
end

local function safeCall(object, methodName, ...)
    if not object or not methodName then
        return nil
    end

    local okMethod, method = pcall(function()
        return object[methodName]
    end)
    if not okMethod or type(method) ~= "function" then
        return nil
    end

    local args = { ... }
    local ok, result = pcall(function()
        return method(object, unpackArgs(args))
    end)
    if ok then
        return result
    end
    return nil
end

local function safeNumber(object, methodName, fallback)
    local value = safeCall(object, methodName)
    local number = tonumber(value)
    if number ~= nil then
        return number
    end
    return fallback
end

local function safeString(object, methodName, fallback)
    local value = safeCall(object, methodName)
    if value ~= nil then
        local text = tostring(value)
        if text ~= "" then
            return text
        end
    end
    return fallback
end

local function getScriptManagerSafe()
    if getScriptManager then
        local ok, manager = pcall(getScriptManager)
        if ok and manager then
            return manager
        end
    end
    if ScriptManager and ScriptManager.instance then
        return ScriptManager.instance
    end
    return nil
end

local function getScriptItem(itemType)
    local manager = getScriptManagerSafe()
    if not manager or not itemType or itemType == "" then
        return nil
    end

    local item = safeCall(manager, "getItem", itemType)
    if item then
        return item
    end

    local shortType = tostring(itemType):match("([^%.]+)$")
    if shortType and shortType ~= itemType then
        return safeCall(manager, "getItem", shortType)
    end
    return nil
end

local function getPriceSignature()
    local priceConfig = DynamicTrading and DynamicTrading.PriceConfig or nil
    if not priceConfig or not priceConfig.GetData then
        return "no_price_config"
    end

    local ok, data = pcall(priceConfig.GetData)
    if not ok or type(data) ~= "table" then
        return "price_config_unavailable"
    end

    local parts = {
        tostring(data.version or 0),
        tostring(data.updatedAt or 0),
    }

    local function appendMapSignature(label, map)
        local keys = {}
        for key in pairs(type(map) == "table" and map or {}) do
            keys[#keys + 1] = tostring(key)
        end
        table.sort(keys)
        parts[#parts + 1] = label .. "#" .. tostring(#keys)
        for _, key in ipairs(keys) do
            parts[#parts + 1] = label .. ":" .. key .. "=" .. tostring(map[key])
        end
    end

    appendMapSignature("tag", data.tagMultipliers)
    appendMapSignature("item", data.itemOverrides)
    return table.concat(parts, "|")
end

local function countMasterItems(masterList)
    local count = 0
    for _ in pairs(masterList or {}) do
        count = count + 1
    end
    return count
end

local function getRegistrySignature(masterList)
    local revision = DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.ItemRegistryRevision or nil
    if tonumber(revision) then
        return "rev:" .. tostring(revision), nil
    end
    local count = countMasterItems(masterList)
    return "count:" .. tostring(count), count
end

local function tagMatches(itemTag, queryTag)
    if not itemTag or not queryTag then
        return false
    end

    itemTag = tostring(itemTag)
    queryTag = tostring(queryTag)
    return itemTag == queryTag or string.sub(itemTag, 1, #queryTag + 1) == (queryTag .. ".")
end

local function hasTag(tags, queryTag)
    for _, tag in ipairs(tags or {}) do
        if tagMatches(tag, queryTag) then
            return true
        end
    end
    return false
end

local function countTagMatches(tags, queries)
    local count = 0
    for _, query in ipairs(queries or {}) do
        if hasTag(tags, query) then
            count = count + 1
        end
    end
    return count
end

local function normalizeAllowedCategoryMap(value)
    if type(value) ~= "table" then
        return nil
    end

    local map = {}
    for key, enabled in pairs(value) do
        if type(key) == "number" then
            map[tostring(enabled)] = true
        elseif enabled == true then
            map[tostring(key)] = true
        end
    end

    for _ in pairs(map) do
        return map
    end

    return nil
end

local function inferRewardCategory(tags)
    if hasTag(tags, "Weapon") then
        return "Weapons"
    end
    if hasTag(tags, "Medical") or hasTag(tags, "Tool.Medical") then
        return "Medicine"
    end
    if hasTag(tags, "Food") or hasTag(tags, "Fluid.Drink") or hasTag(tags, "Fluid.Water") then
        return "Foods"
    end
    if hasTag(tags, "Container.Bag") then
        return "Bags"
    end
    return nil
end

local function getEffectivePrice(itemKey, itemData)
    local priceConfig = DynamicTrading and DynamicTrading.PriceConfig or nil
    if priceConfig and priceConfig.GetEffectiveBasePrice then
        local ok, price = pcall(priceConfig.GetEffectiveBasePrice, itemKey, itemData)
        if ok and tonumber(price) then
            return math.max(0, math.floor(tonumber(price) + 0.5))
        end
    end
    return math.max(0, math.floor(tonumber(itemData and itemData.basePrice) or 0))
end

local function copyTags(itemData)
    local tags = {}
    for _, tag in ipairs(itemData and itemData.tags or {}) do
        if tag ~= nil then
            tags[#tags + 1] = tostring(tag)
        end
    end
    return tags
end

local function addFlag(profile, flag)
    if flag and flag ~= "" then
        profile.flags[flag] = true
    end
end

local function inferPrimaryUse(profile)
    local tags = profile.tags or {}
    if hasTag(tags, "Weapon.Ranged") then
        return "combat_ranged"
    end
    if hasTag(tags, "Weapon.Melee") then
        return "combat_melee"
    end
    if hasTag(tags, "Weapon") then
        return "combat"
    end
    if hasTag(tags, "Medical") or hasTag(tags, "Tool.Medical") then
        return "medical"
    end
    if hasTag(tags, "Food") or hasTag(tags, "Fluid.Drink") or hasTag(tags, "Fluid.Water") then
        return "food"
    end
    if hasTag(tags, "Container") then
        return "container"
    end
    if hasTag(tags, "Clothing") then
        return "clothing"
    end
    if hasTag(tags, "Literature") then
        return "literature"
    end
    if hasTag(tags, "Electronics") then
        return "electronics"
    end
    if hasTag(tags, "Tool") then
        return "tool"
    end
    if hasTag(tags, "Resource") then
        return "resource"
    end
    return "general"
end

local function extractScriptStats(scriptItem, itemData)
    local stats = {
        category = safeString(scriptItem, "getTypeString", nil)
            or safeString(scriptItem, "getType", nil)
            or safeString(scriptItem, "getCategory", nil),
        displayCategory = safeString(scriptItem, "getDisplayCategory", nil),
        weight = safeNumber(scriptItem, "getActualWeight", nil)
            or safeNumber(scriptItem, "getWeight", nil)
            or tonumber(itemData and itemData.weight),
        conditionMax = safeNumber(scriptItem, "getConditionMax", nil),
        conditionLowerChance = safeNumber(scriptItem, "getConditionLowerChance", nil),
        maxDamage = safeNumber(scriptItem, "getMaxDamage", nil),
        minDamage = safeNumber(scriptItem, "getMinDamage", nil),
        maxRange = safeNumber(scriptItem, "getMaxRange", nil),
        minRange = safeNumber(scriptItem, "getMinRange", nil),
        swingTime = safeNumber(scriptItem, "getSwingTime", nil),
        baseSpeed = safeNumber(scriptItem, "getBaseSpeed", nil),
        criticalChance = safeNumber(scriptItem, "getCriticalChance", nil),
        doorDamage = safeNumber(scriptItem, "getDoorDamage", nil),
        treeDamage = safeNumber(scriptItem, "getTreeDamage", nil),
        ammoType = safeString(scriptItem, "getAmmoType", nil),
        weaponSprite = safeString(scriptItem, "getWeaponSprite", nil),
        hungerChange = safeNumber(scriptItem, "getHungerChange", nil),
        thirstChange = safeNumber(scriptItem, "getThirstChange", nil),
        calories = safeNumber(scriptItem, "getCalories", nil),
        carbohydrates = safeNumber(scriptItem, "getCarbohydrates", nil),
        lipids = safeNumber(scriptItem, "getLipids", nil),
        proteins = safeNumber(scriptItem, "getProteins", nil),
        daysFresh = safeNumber(scriptItem, "getDaysFresh", nil),
        daysTotallyRotten = safeNumber(scriptItem, "getDaysTotallyRotten", nil),
        capacity = safeNumber(scriptItem, "getCapacity", nil),
        weightReduction = safeNumber(scriptItem, "getWeightReduction", nil),
        scratchDefense = safeNumber(scriptItem, "getScratchDefense", nil),
        biteDefense = safeNumber(scriptItem, "getBiteDefense", nil),
        bulletDefense = safeNumber(scriptItem, "getBulletDefense", nil),
        insulation = safeNumber(scriptItem, "getInsulation", nil),
        windResistance = safeNumber(scriptItem, "getWindresist", nil) or safeNumber(scriptItem, "getWindResistance", nil),
        waterResistance = safeNumber(scriptItem, "getWaterResistance", nil),
        bandagePower = safeNumber(scriptItem, "getBandagePower", nil),
        alcoholPower = safeNumber(scriptItem, "getAlcoholPower", nil),
        reduceInfectionPower = safeNumber(scriptItem, "getReduceInfectionPower", nil),
        painReduction = safeNumber(scriptItem, "getPainReduction", nil),
        numberOfPages = safeNumber(scriptItem, "getNumberOfPages", nil),
        skillTrained = safeString(scriptItem, "getSkillTrained", nil),
        lvlSkillTrained = safeNumber(scriptItem, "getLvlSkillTrained", nil),
    }

    local ranged = safeCall(scriptItem, "isRanged")
    if ranged ~= nil then
        stats.ranged = ranged == true
    end

    return stats
end

local function computeBaseUsability(profile)
    local stats = profile.stats or {}
    local tags = profile.tags or {}
    local components = {
        base = 1.0,
        combat = 0,
        durability = 0,
        food = 0,
        medical = 0,
        container = 0,
        clothing = 0,
        literature = 0,
        utility = 0,
        quality = 0,
        penalty = 0,
    }

    if hasTag(tags, "Rarity.Rare") then
        components.quality = components.quality + 0.5
    end
    if hasTag(tags, "Quality.Luxury") then
        components.quality = components.quality + 0.5
    end

    local avgDamage = ((tonumber(stats.maxDamage) or 0) + (tonumber(stats.minDamage) or 0)) / 2
    if avgDamage > 0 or hasTag(tags, "Weapon") then
        components.combat = components.combat
            + clamp(avgDamage * 8.0, 0, 12)
            + clamp((tonumber(stats.maxRange) or 0) * 0.35, 0, 5)
            + clamp((tonumber(stats.criticalChance) or 0) * 0.025, 0, 4)
            + clamp((tonumber(stats.doorDamage) or 0) * 0.01, 0, 3)
        if stats.ranged == true or hasTag(tags, "Weapon.Ranged") then
            components.combat = components.combat + 3.0
        end
        if hasTag(tags, "Weapon.Ranged.Ammo") then
            components.combat = components.combat + 2.5
        end
    end

    if tonumber(stats.conditionMax) then
        components.durability = components.durability + clamp(tonumber(stats.conditionMax) * 0.18, 0, 5)
    end
    if tonumber(stats.conditionLowerChance) and tonumber(stats.conditionLowerChance) > 0 then
        components.durability = components.durability + clamp(tonumber(stats.conditionLowerChance) * 0.03, 0, 3)
    end
    if hasTag(tags, "Tool.Fragile") then
        components.durability = components.durability - 0.75
    end

    local hunger = math.abs(tonumber(stats.hungerChange) or 0)
    local thirst = math.abs(tonumber(stats.thirstChange) or 0)
    if hunger > 0 or thirst > 0 or hasTag(tags, "Food") then
        components.food = components.food
            + clamp(hunger * 35.0, 0, 7)
            + clamp(thirst * 30.0, 0, 7)
            + clamp((tonumber(stats.calories) or 0) / 120.0, 0, 8)
        if hasTag(tags, "Food.NonPerishable") then
            components.food = components.food + 2.0
        end
        if hasTag(tags, "Food.LowQuality") then
            components.food = components.food - 1.0
        end
    end

    if hasTag(tags, "Medical") or hasTag(tags, "Tool.Medical") then
        components.medical = components.medical
            + 2.0
            + clamp((tonumber(stats.bandagePower) or 0) * 2.0, 0, 6)
            + clamp((tonumber(stats.alcoholPower) or 0) * 1.5, 0, 5)
            + clamp((tonumber(stats.reduceInfectionPower) or 0) * 1.5, 0, 5)
            + clamp((tonumber(stats.painReduction) or 0) * 0.4, 0, 4)
    end

    if tonumber(stats.capacity) or hasTag(tags, "Container") then
        components.container = components.container
            + clamp((tonumber(stats.capacity) or 0) * 0.35, 0, 10)
            + clamp((tonumber(stats.weightReduction) or 0) * 0.06, 0, 6)
        if hasTag(tags, "Container.Bag") then
            components.container = components.container + 1.5
        end
    end

    if hasTag(tags, "Clothing") then
        components.clothing = components.clothing
            + clamp(((tonumber(stats.scratchDefense) or 0) + (tonumber(stats.biteDefense) or 0)) * 0.035, 0, 7)
            + clamp((tonumber(stats.bulletDefense) or 0) * 0.03, 0, 4)
            + clamp((tonumber(stats.insulation) or 0) * 1.5, 0, 3)
            + clamp((tonumber(stats.windResistance) or 0) * 0.02, 0, 2)
            + clamp((tonumber(stats.waterResistance) or 0) * 0.02, 0, 2)
    end

    if hasTag(tags, "Literature") then
        components.literature = components.literature + 1.0 + clamp((tonumber(stats.numberOfPages) or 0) / 80.0, 0, 3)
        if stats.skillTrained and tostring(stats.skillTrained) ~= "" then
            components.literature = components.literature + 3.0
        end
    end

    if hasTag(tags, "Tool") then
        components.utility = components.utility + 2.0
    end
    if hasTag(tags, "Resource") then
        components.utility = components.utility + 1.4
    end
    if hasTag(tags, "Electronics") then
        components.utility = components.utility + 1.6
    end
    if hasTag(tags, "Resource.Craftable") then
        components.utility = components.utility + 1.2
    end

    if hasTag(tags, "Quality.Waste") then
        components.penalty = components.penalty - 5.0
    end
    local itemName = string.lower(tostring(profile.itemType or profile.itemKey or ""))
    if string.find(itemName, "broken", 1, true) then
        components.penalty = components.penalty - 2.5
    end

    local score = 0
    for _, value in pairs(components) do
        score = score + (tonumber(value) or 0)
    end

    return math.max(0.1, score), components
end

local function buildProfile(itemKey, itemData)
    if type(itemData) ~= "table" then
        return nil
    end

    local itemType = tostring(itemData.item or itemKey or "")
    if itemType == "" then
        return nil
    end

    local scriptItem = getScriptItem(itemType)
    local profile = {
        itemKey = tostring(itemKey or itemType),
        itemType = itemType,
        itemData = itemData,
        displayName = safeString(scriptItem, "getDisplayName", nil) or tostring(itemData.displayName or itemType:match("([^%.]+)$") or itemType),
        description = safeString(scriptItem, "getTooltip", nil)
            or safeString(scriptItem, "getDescription", nil)
            or tostring(itemData.description or ""),
        tags = copyTags(itemData),
        basePrice = math.max(0, math.floor(tonumber(itemData.basePrice) or 0)),
        effectivePrice = getEffectivePrice(itemKey, itemData),
        stockRange = deepCopy(itemData.stockRange or {}),
        flags = {},
        scriptAvailable = scriptItem ~= nil,
    }

    profile.stats = extractScriptStats(scriptItem, itemData)
    profile.scriptCategory = profile.stats.category
    profile.scriptType = safeString(scriptItem, "getType", nil) or profile.scriptCategory
    profile.displayCategory = profile.stats.displayCategory
    profile.weight = profile.stats.weight
    profile.conditionMax = profile.stats.conditionMax
    profile.conditionLowerChance = profile.stats.conditionLowerChance
    profile.weapon = {
        minDamage = profile.stats.minDamage,
        maxDamage = profile.stats.maxDamage,
        minRange = profile.stats.minRange,
        maxRange = profile.stats.maxRange,
        ranged = profile.stats.ranged,
        ammoType = profile.stats.ammoType,
        weaponSprite = profile.stats.weaponSprite,
    }

    if hasTag(profile.tags, "Quality.Waste") then
        addFlag(profile, "waste")
    end
    if string.find(string.lower(itemType), "broken", 1, true) then
        addFlag(profile, "broken")
    end
    if profile.stats.ranged == true or hasTag(profile.tags, "Weapon.Ranged") then
        addFlag(profile, "ranged")
    end
    if hasTag(profile.tags, "Weapon") then
        addFlag(profile, "weapon")
    end
    if hasTag(profile.tags, "Food") then
        addFlag(profile, "food")
    end
    if hasTag(profile.tags, "Medical") or hasTag(profile.tags, "Tool.Medical") then
        addFlag(profile, "medical")
    end

    profile.primaryUse = inferPrimaryUse(profile)
    profile.rewardCategory = inferRewardCategory(profile.tags)
    profile.usabilityScore, profile.scoreComponents = computeBaseUsability(profile)
    return profile
end

local function ensureBuilt()
    local masterList = DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.MasterList or nil
    if type(masterList) ~= "table" then
        return false
    end

    local registrySignature, countedItems = getRegistrySignature(masterList)
    local priceSignature = getPriceSignature()
    if not State.dirty and State.registrySignature == registrySignature and State.priceSignature == priceSignature then
        return true
    end

    local itemCount = countedItems or countMasterItems(masterList)
    State.profilesByKey = {}
    State.profilesByType = {}
    State.order = {}
    State.itemCount = itemCount
    State.registrySignature = registrySignature
    State.priceSignature = priceSignature
    State.buildCount = State.buildCount + 1

    local built = 0
    local scriptBacked = 0
    for itemKey, itemData in pairs(masterList) do
        local profile = buildProfile(itemKey, itemData)
        if profile then
            State.profilesByKey[tostring(itemKey)] = profile
            State.profilesByType[tostring(profile.itemType)] = profile
            State.order[#State.order + 1] = profile.itemKey
            built = built + 1
            if profile.scriptAvailable == true then
                scriptBacked = scriptBacked + 1
            end
        end
    end

    table.sort(State.order)
    State.dirty = false
    logRanker("Info", string.format(
        "Built item usability index #%d items=%d profiles=%d scriptBacked=%d priceState=%s reason=%s",
        State.buildCount,
        itemCount,
        built,
        scriptBacked,
        tostring(priceSignature):sub(1, 48),
        tostring(State.dirtyReason or "refresh")
    ))
    State.dirtyReason = nil
    return true
end

local function resolveProfile(itemTypeOrKey)
    if not ensureBuilt() then
        return nil
    end

    local key = tostring(itemTypeOrKey or "")
    if key == "" then
        return nil
    end
    return State.profilesByType[key] or State.profilesByKey[key]
end

local function itemAllowedForContext(profile, context)
    if type(profile) ~= "table" then
        return false
    end

    if profile.itemType == "Base.Money" or profile.itemType == "Base.MoneyBundle" then
        return false
    end

    if type(profile.tags) ~= "table" or #profile.tags == 0 then
        return false
    end

    context = type(context) == "table" and context or {}
    local allowedCategories = normalizeAllowedCategoryMap(context.allowedRewardCategories)
    if allowedCategories and not allowedCategories[tostring(profile.rewardCategory or "")] then
        return false
    end

    local categoryMinimums = type(context.categoryMinimumUsability) == "table" and context.categoryMinimumUsability or nil
    local minUsability = tonumber(context.minUsabilityScore)
        or (categoryMinimums and tonumber(categoryMinimums[tostring(profile.rewardCategory or "")]))
        or nil
    if minUsability and (tonumber(profile.usabilityScore) or 0) < minUsability then
        return false
    end

    if context.allowWaste ~= true and (profile.flags.waste == true or hasTag(profile.tags, "Quality.Waste")) then
        return false
    end
    if context.allowBroken ~= true and profile.flags.broken == true then
        return false
    end

    local archetype = type(context.archetype) == "table" and context.archetype or {}
    for _, forbid in ipairs(archetype.forbid or {}) do
        if hasTag(profile.tags, forbid) then
            return false
        end
    end

    local budget = tonumber(context.budget) or 0
    if budget > 0 then
        local maxMultiplier = tonumber(context.maxPriceMultiplier) or 1.1
        if profile.effectivePrice <= 0 or profile.effectivePrice > math.max(1, math.floor(budget * maxMultiplier)) then
            return false
        end
    elseif profile.effectivePrice <= 0 then
        return false
    end

    return true
end

function Ranker.Invalidate(reason)
    State.dirty = true
    State.dirtyReason = tostring(reason or "manual")
    return true
end

function Ranker.GetProfile(itemTypeOrKey)
    local profile = resolveProfile(itemTypeOrKey)
    return profile and deepCopy(profile) or nil
end

local function scoreProfile(profile, context)
    context = type(context) == "table" and context or {}
    local theme = type(context.theme) == "table" and context.theme or {}
    local rewardProfile = type(context.profile) == "table" and context.profile or {}
    local archetype = type(context.archetype) == "table" and context.archetype or {}
    local tags = profile.tags or {}

    local themeMatches = countTagMatches(tags, theme.preferredTags)
    local profileMatches = countTagMatches(tags, rewardProfile.preferredTags)
    local expertMatches = countTagMatches(tags, archetype.expertTags)
    local allocationMatches = 0
    for _, allocation in ipairs(archetype.allocations or {}) do
        allocationMatches = allocationMatches + countTagMatches(tags, allocation.tags)
    end

    local components = {
        base = 1.0,
        theme = themeMatches * 1.6,
        profile = profileMatches * 1.25,
        expert = expertMatches * 1.15,
        allocation = allocationMatches * 0.75,
        usability = clamp((tonumber(profile.usabilityScore) or 0) / 12.0, 0, 4),
        category = 0,
        penalty = 0,
    }

    local categoryWeights = type(context.categoryWeights) == "table" and context.categoryWeights or nil
    if categoryWeights and profile.rewardCategory then
        components.category = tonumber(categoryWeights[profile.rewardCategory]) or 0
    end

    if context.allowWaste ~= true and (profile.flags.waste == true or hasTag(tags, "Quality.Waste")) then
        components.penalty = components.penalty - 5.0
    end
    if context.allowBroken ~= true and profile.flags.broken == true then
        components.penalty = components.penalty - 2.0
    end

    local score = 0
    for _, value in pairs(components) do
        score = score + (tonumber(value) or 0)
    end

    components.themeMatches = themeMatches
    components.profileMatches = profileMatches
    components.expertMatches = expertMatches
    components.allocationMatches = allocationMatches
    components.baseUsabilityScore = profile.usabilityScore
    return math.max(0.1, score), components
end

function Ranker.ScoreItem(itemTypeOrKey, context)
    local profile = resolveProfile(itemTypeOrKey)
    if not profile then
        return 0, {}
    end

    return scoreProfile(profile, context)
end

function Ranker.FindCandidates(context)
    if not ensureBuilt() then
        return {}
    end

    context = type(context) == "table" and context or {}
    local results = {}
    local requireMatch = context.requireContextMatch ~= false

    for _, itemKey in ipairs(State.order) do
        local profile = State.profilesByKey[itemKey]
        if itemAllowedForContext(profile, context) then
            local score, components = scoreProfile(profile, context)
            local hasContextMatch = (tonumber(components.themeMatches) or 0) > 0
                or (tonumber(components.profileMatches) or 0) > 0
                or (tonumber(components.expertMatches) or 0) > 0
                or (tonumber(components.allocationMatches) or 0) > 0

            if hasContextMatch or requireMatch ~= true then
                results[#results + 1] = {
                    itemType = profile.itemType,
                    itemKey = profile.itemKey,
                    itemData = profile.itemData,
                    tags = deepCopy(profile.tags or {}),
                    price = profile.effectivePrice,
                    weight = math.max(0.1, score),
                    usabilityScore = profile.usabilityScore,
                    primaryUse = profile.primaryUse,
                    rewardCategory = profile.rewardCategory,
                    profile = profile,
                    scoreComponents = components,
                }
            end
        end
    end

    return results
end

function Ranker.GetStats()
    ensureBuilt()
    return {
        version = Ranker.VERSION,
        dirty = State.dirty,
        itemCount = State.itemCount,
        profileCount = #State.order,
        registrySignature = State.registrySignature,
        priceSignature = State.priceSignature,
        buildCount = State.buildCount,
    }
end

if Events and Events.OnDynamicTradingPriceConfigUpdated then
    Events.OnDynamicTradingPriceConfigUpdated.Add(function()
        Ranker.Invalidate("price_config_updated")
    end)
end

return Ranker
