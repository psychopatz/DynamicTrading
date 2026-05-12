local PriceConfig = DynamicTrading.PriceConfig
local Internal = DT_PriceConfigInternal

function PriceConfig.NormalizeTag(tag)
    local normalized = Internal.Trim(tag)

    if normalized == "" then
        return nil
    end

    return normalized
end

function PriceConfig.HasKnownItem(itemKey)
    return itemKey and DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.MasterList
        and DynamicTrading.Config.MasterList[itemKey] ~= nil
end

function PriceConfig.GetKnownTags()
    local tags = {}

    for tag in pairs((DynamicTrading.Config and DynamicTrading.Config.Tags) or {}) do
        tags[tag] = true
    end

    for _, itemData in pairs((DynamicTrading.Config and DynamicTrading.Config.MasterList) or {}) do
        for _, tag in ipairs(itemData.tags or {}) do
            local probe = tag

            while probe do
                tags[probe] = true
                probe = string.match(probe, "^(.*)%.")
            end
        end
    end

    return tags
end

function PriceConfig.HasKnownTag(tag)
    local normalized = PriceConfig.NormalizeTag(tag)

    if not normalized then
        return false
    end

    return PriceConfig.GetKnownTags()[normalized] == true
end

function PriceConfig.TagMatches(itemTag, queryTag)
    if not itemTag or not queryTag then
        return false
    end

    return itemTag == queryTag or string.sub(itemTag, 1, #queryTag + 1) == (queryTag .. ".")
end

function PriceConfig.ItemMatchesTag(itemData, queryTag)
    for _, itemTag in ipairs(itemData and itemData.tags or {}) do
        if PriceConfig.TagMatches(itemTag, queryTag) then
            return true
        end
    end

    return false
end
