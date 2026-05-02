local Types = require "DT/Common/Abstract/Normalization/DT_AbstractTypes"
local Buckets = require "DT/Common/Abstract/Normalization/DT_AbstractBuckets"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Abstract = DynamicTrading.Abstract or {}
DynamicTrading.Abstract.Normalization = DynamicTrading.Abstract.Normalization or {}

local Heuristics = DynamicTrading.Abstract.Normalization.Heuristics or {}
DynamicTrading.Abstract.Normalization.Heuristics = Heuristics

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

local function joinContext(fullType, displayName, scriptItem)
    local parts = {
        Types.NormalizeSearchText(fullType),
        Types.NormalizeSearchText(displayName),
        Types.NormalizeSearchText(Types.ShortType(fullType)),
        Types.NormalizeSearchText(safeCall(scriptItem, "getDisplayCategory") or ""),
        Types.NormalizeSearchText(safeCall(scriptItem, "getTypeString") or ""),
        Types.NormalizeSearchText(safeCall(scriptItem, "getCategory") or ""),
    }
    return table.concat(parts, " ")
end

local function matchesAny(text, tokens)
    for _, token in ipairs(tokens or {}) do
        if string.find(text, token, 1, true) then
            return true, token
        end
    end
    return false, nil
end

local function buildResult(bucketID, source, reason)
    if not Buckets.IsValid(bucketID) then
        return nil
    end
    return {
        primaryBucket = bucketID,
        secondaryBuckets = {},
        source = source,
        reasons = { reason },
    }
end

local NAME_TOKENS = {
    { bucket = "water_clean", reason = "Resolved from water/container keywords.", tokens = { "canteen", "flask", "hydration", "sportsbottle", "water", "waterskin" } },
    { bucket = "medical_supplies", reason = "Resolved from medical keywords.", tokens = { "alcohol", "antibiotic", "bandage", "disinfect", "medical", "medicine", "painkiller", "pill", "suture", "vitamin" } },
    { bucket = "fuel", reason = "Resolved from fuel keywords.", tokens = { "charcoal", "fuel", "gas", "gasoline", "lighterfluid", "petrol", "propane", "starterfluid" } },
    { bucket = "ammo_components", reason = "Resolved from ammunition component keywords.", tokens = { "casing", "clip", "mag", "magazine", "pellet", "powder", "primer", "wad" } },
    { bucket = "ammo_ready", reason = "Resolved from ammunition keywords.", tokens = { "ammo", "bullet", "cartridge", "round", "shell", "shot", "slug" } },
    { bucket = "weapon_parts", reason = "Resolved from weapon-part keywords.", tokens = { "barrel", "blade", "brake", "choke", "head", "laser", "pad", "scope", "sight", "strap" } },
    { bucket = "tools", reason = "Resolved from tool keywords.", tokens = { "awl", "drill", "hammer", "knife", "needle", "pliers", "saw", "screwdriver", "shovel", "trowel", "wrench" } },
    { bucket = "bindings", reason = "Resolved from binding keywords.", tokens = { "binding", "floss", "rope", "sheetrope", "string", "strip", "tape", "thread", "twine", "yarn" } },
    { bucket = "electronics", reason = "Resolved from electronics keywords.", tokens = { "battery", "electronic", "flashlight", "generator", "radio", "walkie" } },
    { bucket = "chemicals", reason = "Resolved from chemical keywords.", tokens = { "acid", "adhesive", "bleach", "cleaning", "cologne", "epoxy", "glue", "perfume", "resin", "solvent" } },
    { bucket = "leather", reason = "Resolved from leather keywords.", tokens = { "hide", "leather", "pelt", "sinew" } },
    { bucket = "metal", reason = "Resolved from metal keywords.", tokens = { "aluminum", "anvil", "bar", "brass", "copper", "gold", "ingot", "iron", "metal", "rod", "scrap", "sheet", "silver", "steel" } },
    { bucket = "hardware", reason = "Resolved from hardware keywords.", tokens = { "bolt", "buckle", "button", "chain", "hinge", "hook", "latch", "nail", "nut", "pipe", "sawblade", "screw", "wire" } },
    { bucket = "wood", reason = "Resolved from wood keywords.", tokens = { "branch", "handle", "log", "plank", "stick", "wood" } },
    { bucket = "textiles", reason = "Resolved from textile keywords.", tokens = { "burlap", "cloth", "cotton", "denim", "fabric", "flax", "sheet", "textile", "wool" } },
    { bucket = "meals", reason = "Resolved from prepared-meal keywords.", tokens = { "bowl", "burger", "burrito", "dinner", "dumpling", "fries", "hotdog", "macandcheese", "omelette", "pizza", "ramen", "salad", "sandwich", "soup", "stew", "sushi", "taco", "toast", "waffles" } },
    { bucket = "food_raw_preserved", reason = "Resolved from preserved-food keywords.", tokens = { "beans", "canned", "cereal", "coffee", "cracker", "dried", "dry", "flour", "jar", "pasta", "preserve", "rice", "sugar", "tea" } },
    { bucket = "food_raw_fresh", reason = "Resolved from fresh-food keywords.", tokens = { "berry", "cheese", "egg", "fish", "fruit", "ham", "meat", "milk", "tofu", "tomato", "turkey", "vegetable", "venison", "yoghurt" } },
}

function Heuristics.ResolveFromScriptHints(fullType, itemData, scriptItem)
    local combined = joinContext(fullType, itemData and itemData.displayName or "", scriptItem)
    if combined == "" then
        return nil
    end

    if string.find(combined, " food ", 1, true) or string.find(combined, "drink", 1, true) then
        local matchedMeal, mealToken = matchesAny(combined, { "burger", "pizza", "sandwich", "soup", "stew", "salad", "dinner", "meal" })
        if matchedMeal then
            return buildResult("meals", Types.SOURCE.scriptHint, "Resolved from script food category and prepared-food keyword '" .. tostring(mealToken) .. "'.")
        end

        local matchedWater = matchesAny(combined, { "water", "canteen", "flask" })
        if matchedWater then
            return buildResult("water_clean", Types.SOURCE.scriptHint, "Resolved from script drink/container hints.")
        end

        local matchedPreserved = matchesAny(combined, { "canned", "dry", "tea", "coffee", "crackers" })
        if matchedPreserved then
            return buildResult("food_raw_preserved", Types.SOURCE.scriptHint, "Resolved from script food category and preserved-food hint.")
        end

        return buildResult("food_raw_fresh", Types.SOURCE.scriptHint, "Resolved from script food category.")
    end

    if string.find(combined, " medical ", 1, true) or string.find(combined, "first aid", 1, true) then
        return buildResult("medical_supplies", Types.SOURCE.scriptHint, "Resolved from script medical category.")
    end

    if string.find(combined, " tool ", 1, true) or string.find(combined, " utensil ", 1, true) then
        return buildResult("tools", Types.SOURCE.scriptHint, "Resolved from script tool category.")
    end

    if string.find(combined, " electronics ", 1, true) or string.find(combined, "electronic", 1, true) then
        return buildResult("electronics", Types.SOURCE.scriptHint, "Resolved from script electronics category.")
    end

    if string.find(combined, " weapon ", 1, true) then
        local matchedAmmo = matchesAny(combined, { "ammo", "shell", "bullet" })
        if matchedAmmo then
            return buildResult("ammo_ready", Types.SOURCE.scriptHint, "Resolved from script weapon category and ammunition hint.")
        end
        return buildResult("weapon_parts", Types.SOURCE.scriptHint, "Resolved from script weapon category.")
    end

    return nil
end

function Heuristics.ResolveFromNameHeuristics(fullType, displayName, scriptItem)
    local combined = joinContext(fullType, displayName, scriptItem)
    if combined == "" then
        return nil
    end

    for _, entry in ipairs(NAME_TOKENS) do
        local matched, token = matchesAny(combined, entry.tokens)
        if matched then
            return buildResult(entry.bucket, Types.SOURCE.heuristic, entry.reason .. " Matched '" .. tostring(token) .. "'.")
        end
    end

    return buildResult("hardware", Types.SOURCE.heuristic, "Fell back to generic hardware salvage bucket.")
end

return Heuristics
