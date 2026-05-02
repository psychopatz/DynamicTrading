local Types = require "DT/Common/Abstract/Normalization/DT_AbstractTypes"
local Buckets = require "DT/Common/Abstract/Normalization/DT_AbstractBuckets"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Abstract = DynamicTrading.Abstract or {}
DynamicTrading.Abstract.Normalization = DynamicTrading.Abstract.Normalization or {}

local TagRules = DynamicTrading.Abstract.Normalization.TagRules or {}
DynamicTrading.Abstract.Normalization.TagRules = TagRules

local EXPLICIT_BUCKET_OVERRIDES = {
    ["Base.DenimStrips"] = "bindings",
    ["Base.DenimStripsBundle"] = "bindings",
    ["Base.DenimStripsDirty"] = "bindings",
    ["Base.DenimStripsDirtyBundle"] = "bindings",
    ["Base.DentalFloss"] = "bindings",
    ["Base.LeatherStrips"] = "bindings",
    ["Base.LeatherStripsDirty"] = "bindings",
    ["Base.RippedSheets"] = "bindings",
    ["Base.RippedSheetsDirty"] = "bindings",
    ["Base.Rope"] = "bindings",
    ["Base.RopeStack"] = "bindings",
    ["Base.SheetRope"] = "bindings",
    ["Base.SheetRopeBundle"] = "bindings",
    ["Base.String"] = "bindings",
    ["Base.Thread"] = "bindings",
    ["Base.Thread_Aramid"] = "bindings",
    ["Base.Thread_Sinew"] = "bindings",
    ["Base.Twine"] = "bindings",
    ["Base.Wire"] = "hardware",
    ["Base.WireStack"] = "hardware",
    ["Base.Yarn"] = "bindings",
}

local PREFIX_RULES = {
    { prefix = "Weapon.Part.Ammo", primaryBucket = "ammo_components", reason = "Matched ammo component tag." },
    { prefix = "Weapon.Ammo", primaryBucket = "ammo_ready", reason = "Matched ready-ammo tag." },
    { prefix = "Resource.AmmoMaterial", primaryBucket = "ammo_components", reason = "Matched ammunition material tag." },
    { prefix = "Weapon.Part", primaryBucket = "weapon_parts", reason = "Matched weapon-part tag." },
    { prefix = "Resource.Parts", primaryBucket = "weapon_parts", reason = "Matched salvageable parts tag." },
    { prefix = "Tool.Medical", primaryBucket = "medical_supplies", reason = "Matched medical tool tag." },
    { prefix = "Medical", primaryBucket = "medical_supplies", reason = "Matched medical supply tag." },
    { prefix = "Fluid.Medical", primaryBucket = "medical_supplies", reason = "Matched medical fluid tag." },
    { prefix = "Fluid.Water", primaryBucket = "water_clean", reason = "Matched water fluid tag." },
    { prefix = "Resource.Fuel", primaryBucket = "fuel", reason = "Matched fuel resource tag." },
    { prefix = "Fluid.Fuel", primaryBucket = "fuel", reason = "Matched fuel fluid tag." },
    { prefix = "Electronics", primaryBucket = "electronics", reason = "Matched electronics tag." },
    { prefix = "Resource.Material.Wood", primaryBucket = "wood", reason = "Matched wood material tag." },
    { prefix = "Resource.Material.Metal", primaryBucket = "metal", reason = "Matched metal material tag." },
    { prefix = "Resource.Material.Hardware", primaryBucket = "hardware", reason = "Matched hardware material tag." },
    { prefix = "Resource.Material.Leather", primaryBucket = "leather", reason = "Matched leather material tag." },
    { prefix = "Resource.Material.Textile", primaryBucket = "textiles", reason = "Matched textile material tag." },
    { prefix = "Resource.Material.Paper", primaryBucket = "textiles", reason = "Mapped paper materials into textiles for v1." },
    { prefix = "Resource.Adhesive", primaryBucket = "chemicals", reason = "Matched adhesive resource tag." },
    { prefix = "Fluid.Cleaning", primaryBucket = "chemicals", reason = "Matched cleaning chemical tag." },
    { prefix = "Fluid.Appearance", primaryBucket = "chemicals", reason = "Matched cosmetic chemical tag." },
    { prefix = "Tool", primaryBucket = "tools", reason = "Matched tool tag." },
    { prefix = "Food.Canned", primaryBucket = "food_raw_preserved", reason = "Matched preserved-food tag." },
    { prefix = "Food.NonPerishable", primaryBucket = "food_raw_preserved", reason = "Matched non-perishable food tag." },
    { prefix = "Food.Grain", primaryBucket = "food_raw_preserved", reason = "Matched grain food tag." },
    { prefix = "Food.Spice", primaryBucket = "food_raw_preserved", reason = "Matched dry ingredient tag." },
    { prefix = "Food.Fruit", primaryBucket = "food_raw_fresh", reason = "Matched fresh produce tag." },
    { prefix = "Food.Vegetable", primaryBucket = "food_raw_fresh", reason = "Matched fresh produce tag." },
    { prefix = "Food.Meat", primaryBucket = "food_raw_fresh", reason = "Matched meat tag." },
    { prefix = "Food.Fish", primaryBucket = "food_raw_fresh", reason = "Matched fish tag." },
    { prefix = "Food.Perishable", primaryBucket = "food_raw_fresh", reason = "Matched perishable food tag." },
    { prefix = "Food.Cooking", primaryBucket = "food_raw_fresh", reason = "Matched cooking ingredient tag." },
    { prefix = "Food.Drink", primaryBucket = "food_raw_preserved", reason = "Matched drinkable food tag." },
}

local PREPARED_MEAL_TOKENS = {
    "bowl", "burrito", "burger", "calamari", "chips", "dinner", "dumpling", "fries",
    "fried", "hotdog", "macandcheese", "maki", "meal", "omelette", "onigiri", "pancake",
    "pie", "pizza", "pretzel", "ramen", "recipe", "salad", "sandwich", "smore", "soup",
    "stew", "sushi", "taco", "toast", "waffles",
}

local function tagMatches(itemTag, queryTag)
    if not itemTag or not queryTag then
        return false
    end
    local itemText = tostring(itemTag)
    local queryText = tostring(queryTag)
    return itemText == queryText or string.sub(itemText, 1, #queryText + 1) == (queryText .. ".")
end

local function anyTagMatches(tags, queryTag)
    for _, tag in ipairs(tags or {}) do
        if tagMatches(tag, queryTag) then
            return true
        end
    end
    return false
end

local function normalizeHaystack(context)
    local haystack = {
        Types.NormalizeSearchText(context and context.fullType or ""),
        Types.NormalizeSearchText(context and context.displayName or ""),
        Types.NormalizeSearchText(context and context.shortType or ""),
    }
    return table.concat(haystack, " ")
end

local function containsToken(haystack, token)
    return haystack ~= "" and string.find(haystack, token, 1, true) ~= nil
end

local function looksPreparedMeal(context)
    local haystack = normalizeHaystack(context)
    if haystack == "" then
        return false
    end
    for _, token in ipairs(PREPARED_MEAL_TOKENS) do
        if containsToken(haystack, token) then
            return true
        end
    end
    return false
end

local function finalize(bucketID, source, reasons)
    if not Buckets.IsValid(bucketID) then
        return nil
    end
    return {
        primaryBucket = bucketID,
        secondaryBuckets = {},
        source = source,
        reasons = Types.UniqueSortedArray(reasons or {}),
    }
end

local function resolveClothingBucket(tags, context)
    if not anyTagMatches(tags, "Clothing") then
        return nil
    end

    local haystack = normalizeHaystack(context)

    if anyTagMatches(tags, "Clothing.Accessory.Jewelry") then
        return finalize("metal", Types.SOURCE.tagRule, {
            "Mapped jewelry clothing accessory into metal abstraction.",
        })
    end

    if anyTagMatches(tags, "Clothing.Accessory.Wrist.Watch") then
        return finalize("electronics", Types.SOURCE.tagRule, {
            "Mapped watch accessory into electronics abstraction.",
        })
    end

    if anyTagMatches(tags, "Clothing.Accessory.Eyes") then
        return finalize("hardware", Types.SOURCE.tagRule, {
            "Mapped eyewear accessory into hardware abstraction.",
        })
    end

    if containsToken(haystack, "leather") or containsToken(haystack, "hide") or containsToken(haystack, "pelt") then
        return finalize("leather", Types.SOURCE.tagRule, {
            "Mapped clothing item into leather abstraction using clothing tags and material keywords.",
        })
    end

    if anyTagMatches(tags, "Clothing.Armor") then
        return finalize("metal", Types.SOURCE.tagRule, {
            "Mapped armored clothing into metal abstraction.",
        })
    end

    if anyTagMatches(tags, "Clothing.Accessory.Utility") then
        return finalize("leather", Types.SOURCE.tagRule, {
            "Mapped utility clothing accessory into leather abstraction.",
        })
    end

    return finalize("textiles", Types.SOURCE.tagRule, {
        "Mapped general clothing item into textiles abstraction.",
    })
end

function TagRules.GetExplicitBucketOverride(fullType)
    return EXPLICIT_BUCKET_OVERRIDES[tostring(fullType or "")]
end

function TagRules.ResolveFromTags(fullType, tags, context)
    local explicitBucket = TagRules.GetExplicitBucketOverride(fullType)
    if explicitBucket then
        return finalize(explicitBucket, Types.SOURCE.explicit, {
            "Matched explicit normalization override.",
        })
    end

    local clothingBucket = resolveClothingBucket(tags, context)
    if clothingBucket then
        return clothingBucket
    end

    if anyTagMatches(tags, "Food") and looksPreparedMeal(context) then
        return finalize("meals", Types.SOURCE.tagRule, {
            "Promoted food item into meals using prepared-food tag context.",
        })
    end

    for _, rule in ipairs(PREFIX_RULES) do
        if anyTagMatches(tags, rule.prefix) then
            return finalize(rule.primaryBucket, Types.SOURCE.tagRule, {
                rule.reason,
            })
        end
    end

    return nil
end

return TagRules
