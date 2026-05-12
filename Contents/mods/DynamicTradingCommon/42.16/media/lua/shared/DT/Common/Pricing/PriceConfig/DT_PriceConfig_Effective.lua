local PriceConfig = DynamicTrading.PriceConfig
local Internal = DT_PriceConfigInternal

function PriceConfig.GetDefaultBasePrice(itemKey, itemData)
    local data = PriceConfig.GetData()

    if itemKey and data.defaults[itemKey] ~= nil then
        return Internal.RoundPrice(data.defaults[itemKey]) or 0
    end

    return Internal.RoundPrice(itemData and itemData.basePrice) or 0
end

function PriceConfig.GetBranchMultiplierForTag(tag, data)
    local normalized = PriceConfig.NormalizeTag(tag)
    local source = PriceConfig.EnsureSchema(data or PriceConfig.GetData())
    local multiplier = 1.0
    local probe = normalized
    local found = false

    while probe do
        local override = source.tagMultipliers[probe]

        if override ~= nil then
            local normalizedValue = Internal.NormalizeMultiplier(override)

            if normalizedValue then
                multiplier = multiplier * normalizedValue
                found = true
            end
        end

        probe = string.match(probe, "^(.*)%.")
    end

    if not found then
        return 1.0, false
    end

    return multiplier, true
end

function PriceConfig.GetBestBranchMultiplier(itemTags, data)
    local best = 1.0
    local foundAny = false

    for _, tag in ipairs(itemTags or {}) do
        local branch
        local found

        branch, found = PriceConfig.GetBranchMultiplierForTag(tag, data)
        if found and (not foundAny or branch > best) then
            best = branch
            foundAny = true
        end
    end

    if not foundAny then
        return 1.0
    end

    return best
end

function PriceConfig.GetEffectiveBasePrice(itemKey, itemData, data)
    local source = PriceConfig.EnsureSchema(data or PriceConfig.GetData())
    local defaultBase = PriceConfig.GetDefaultBasePrice(itemKey, itemData)

    if itemKey and source.itemOverrides[itemKey] ~= nil then
        return Internal.RoundPrice(source.itemOverrides[itemKey]) or defaultBase
    end

    return math.max(0, math.floor((defaultBase * PriceConfig.GetBestBranchMultiplier(itemData and itemData.tags or nil, source)) + 0.5))
end
