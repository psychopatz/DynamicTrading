-- =============================================================================
-- 2. DRAINABLE & CHARGE HELPERS (B42 Compatible) & TAG HELPERS
-- =============================================================================

local Common = DynamicTrading.Economy.Common

local LEGACY_TAG_ALIASES = {
    ["Food.General"] = { prefix = "Food.", suffix = ".General" },
    ["Food.Spice"] = { prefix = "Food.", suffix = ".Spice" }
}

-- Building sub-type hierarchy (used by TagMatches hierarchy walk).
-- Querying "Building" matches Building.Moveable, Building.Material, etc.
-- Querying "Building.Material" matches only material items.
-- No legacy alias needed – the hierarchy walk in TagMatches handles prefix
-- matching automatically via the "queryTag .. '%.')" check.
-- Sub-types: Moveable | Material | Parts | Furniture | Fixture | Vehicle | Garden

function Common.TagMatches(itemTag, queryTag)
    if not itemTag or not queryTag then return false end
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
