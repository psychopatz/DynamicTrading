-- =============================================================================
-- 2. DRAINABLE & CHARGE HELPERS (B42 Compatible) & TAG HELPERS
-- =============================================================================

local Common = DynamicTrading.Economy.Common

local LEGACY_TAG_ALIASES = {
    ["Food.General"] = { prefix = "Food.", suffix = ".General" },
    ["Food.Spice"] = { prefix = "Food.", suffix = ".Spice" }
}
local LUA_PATTERN_MAGIC = "([%(%)%.%%%+%-%?%[%]%^%$])"

local function globToPattern(glob)
    local pattern = tostring(glob or ""):gsub(LUA_PATTERN_MAGIC, "%%%1")
    pattern = pattern:gsub("%*", ".*")
    return "^" .. pattern .. "$"
end

-- Building sub-type hierarchy (used by TagMatches hierarchy walk).
-- Querying "Building" matches Building.Moveable, Building.Material, etc.
-- Querying "Building.Material" matches only material items.
-- No legacy alias needed – the hierarchy walk in TagMatches handles prefix
-- matching automatically via the "queryTag .. '%.')" check.
-- Sub-types: Moveable | Material | Parts | Furniture | Fixture | Vehicle | Garden

function Common.TagMatches(itemTag, queryTag)
    if not itemTag or not queryTag then return false end

    if string.find(queryTag, "*", 1, true) then
        return string.match(itemTag, globToPattern(queryTag)) ~= nil
    end

    if itemTag == queryTag or string.find(itemTag, queryTag .. "%.") == 1 then
        return true
    end

    local alias = LEGACY_TAG_ALIASES[queryTag]
    if alias
        and string.find(itemTag, alias.prefix, 1, true) == 1
        and string.sub(itemTag, -string.len(alias.suffix)) == alias.suffix then
        return true
    end

    return false
end

function Common.HasMatchingTag(itemTags, queryTag)
    if not itemTags or not queryTag then return false end
    for _, itemTag in ipairs(itemTags) do
        if Common.TagMatches(itemTag, queryTag) then
            return true
        end
    end
    return false
end

function Common.ResolveMappedValue(itemTags, mapping)
    if not itemTags or not mapping then return nil end

    for _, itemTag in ipairs(itemTags) do
        local probe = itemTag
        while probe do
            if mapping[probe] then
                return mapping[probe]
            end
            probe = string.match(probe, "^(.*)%.")
        end

        for segment in string.gmatch(itemTag, "([^.]+)") do
            if mapping[segment] then
                return mapping[segment]
            end
        end
    end

    return nil
end

--- Checks if an item's tags satisfy all requirements.
-- @param itemTags (Table) The item's tags array.
-- @param requiredTags (Table) The tags that MUST be present (supports hierarchy).
-- @return (Boolean)
function Common.MatchesAllTags(itemTags, requiredTags)
    if not requiredTags or #requiredTags == 0 then return false end
    for _, req in ipairs(requiredTags) do
        if not Common.HasMatchingTag(itemTags, req) then return false end
    end
    return true
end

function Common.NormalizeFluidType(fluidType)
    if fluidType == nil then return nil end

    local value = fluidType
    if type(value) ~= "string" then
        if value.getFluidType then
            local ok, result = pcall(function() return value:getFluidType() end)
            if ok and result then
                value = result
            end
        elseif value.getName then
            local ok, result = pcall(function() return value:getName() end)
            if ok and result then
                value = result
            end
        end
    end

    value = tostring(value or "")
    local colonPos = string.find(value, ":", 1, true)
    if colonPos then
        value = string.sub(value, 1, colonPos - 1)
    end

    value = value:gsub("^%s+", ""):gsub("%s+$", "")
    if value == "" or string.lower(value) == "true" then
        return nil
    end

    return value
end

function Common.GetFluidData(fluidType)
    local normalized = Common.NormalizeFluidType(fluidType)
    if not normalized or not DynamicTrading or not DynamicTrading.Fluids then
        return nil, normalized
    end

    local direct = DynamicTrading.Fluids[normalized]
    if direct then
        return direct, normalized
    end

    if string.sub(normalized, 1, 5) == "Base." then
        return DynamicTrading.Fluids[string.sub(normalized, 6)], normalized
    end

    return DynamicTrading.Fluids["Base." .. normalized], normalized
end

function Common.GetFluidTags(fluidType)
    local fluidData = Common.GetFluidData(fluidType)
    return fluidData and fluidData.tags or nil
end

function Common.GetFluidUnitPrice(fluidType)
    local fluidData = Common.GetFluidData(fluidType)
    if not fluidData then
        return 0
    end

    return fluidData.basePricePerLiter or fluidData.basePrice or 0
end

function Common.ResolveContainerBasePrice(itemData, scriptItem)
    if scriptItem and scriptItem.getReplaceOnDeplete then
        local emptyID = scriptItem:getReplaceOnDeplete()
        if emptyID and DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.MasterList then
            local emptyData = DynamicTrading.Config.MasterList[emptyID]
            if emptyData then
                if DynamicTrading.PriceConfig and DynamicTrading.PriceConfig.GetEffectiveBasePrice then
                    return DynamicTrading.PriceConfig.GetEffectiveBasePrice(emptyID, emptyData), emptyID
                end
                if emptyData.basePrice then
                    return emptyData.basePrice, emptyID
                end
            end
        end
    end

    if itemData and DynamicTrading.PriceConfig and DynamicTrading.PriceConfig.GetEffectiveBasePrice then
        return DynamicTrading.PriceConfig.GetEffectiveBasePrice(itemData.item, itemData), nil
    end

    return itemData and itemData.basePrice or 0, nil
end

function Common.GetPrimaryTradeTag(itemData, fluidType, fluidAmount)
    if (tonumber(fluidAmount) or 0) > 0 then
        local fluidData = Common.GetFluidData(fluidType)
        if fluidData and fluidData.tags and fluidData.tags[1] then
            return fluidData.tags[1]
        end
    end

    return itemData and itemData.tags and itemData.tags[1] or "Misc"
end

function Common.GetTradeTags(itemData, fluidType, fluidAmount)
    if (tonumber(fluidAmount) or 0) > 0 then
        local fluidData = Common.GetFluidData(fluidType)
        if fluidData and fluidData.tags then
            return fluidData.tags
        end
    end

    return itemData and itemData.tags or {}
end

-- =============================================================================
function Common.GetItemCharge(itemObj)
    if not itemObj then return 0 end
    
    local d_maxUses = itemObj.getMaxUses and itemObj:getMaxUses() or 0
    local d_curUses = itemObj.getCurrentUses and itemObj:getCurrentUses() or nil
    local d_delta = itemObj.getDelta and itemObj:getDelta() or nil
    local d_usedDelta = itemObj.getUsedDelta and itemObj:getUsedDelta() or nil
    local d_drainUses = itemObj.getDrainableUsesFloat and itemObj:getDrainableUsesFloat() or nil

    -- 1. Try B42 Specific Getters found in diagnostic
    if d_curUses and d_maxUses > 0 then
        return d_curUses / d_maxUses
    end

    -- 2. Try Standard Float Getters
    if d_drainUses and d_drainUses > 0 then return d_drainUses end
    if d_delta and d_delta > 0 then return d_delta end
    if d_usedDelta and d_usedDelta > 0 then return d_usedDelta end
    
    -- 3. Try other potential Integer Uses / Max (B42 style)
    local d_drainInt = itemObj.getDrainableUsesInt and itemObj:getDrainableUsesInt() or nil
    local d_drainUsesRaw = itemObj.getDrainableUses and itemObj:getDrainableUses() or nil
    local d_remUsesInt = itemObj.getRemainingUsesInt and itemObj:getRemainingUsesInt() or nil
    
    if d_drainInt and d_maxUses > 0 then return d_drainInt / d_maxUses end
    if d_drainUsesRaw and d_maxUses > 0 then return d_drainUsesRaw / d_maxUses end
    if d_remUsesInt and d_maxUses > 0 then return d_remUsesInt / d_maxUses end
    
    -- Safe Fallback: If we detect no usage data but the item is considered drainable, assume full.
    -- This prevents pricing items like Twine at 0 if they haven't been used yet.
    if d_maxUses > 0 then
        return 1.0
    end
    
    return 0
end
