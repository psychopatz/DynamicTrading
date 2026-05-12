local PriceConfig = DynamicTrading.PriceConfig
local Internal = DT_PriceConfigInternal

function PriceConfig.SetTagMultiplier(tag, value)
    local normalizedTag = PriceConfig.NormalizeTag(tag)
    local normalizedValue = Internal.NormalizeMultiplier(value)
    local data

    if not normalizedTag or normalizedValue == nil then
        return false, "Invalid tag multiplier."
    end
    if not PriceConfig.HasKnownTag(normalizedTag) then
        return false, "Unknown tag."
    end

    data = PriceConfig.GetData()
    if math.abs(normalizedValue - 1.0) <= 0.0001 then
        data.tagMultipliers[normalizedTag] = nil
    else
        data.tagMultipliers[normalizedTag] = normalizedValue
    end

    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true
end

function PriceConfig.ResetTagMultiplier(tag)
    local normalizedTag = PriceConfig.NormalizeTag(tag)
    local data

    if not normalizedTag then
        return false, "Invalid tag."
    end

    data = PriceConfig.GetData()
    data.tagMultipliers[normalizedTag] = nil
    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true
end

function PriceConfig.SetItemOverride(itemKey, value)
    local normalizedKey = Internal.Trim(itemKey)
    local normalizedValue = Internal.RoundPrice(value)
    local data

    if normalizedKey == "" or normalizedValue == nil then
        return false, "Invalid item override."
    end
    if not PriceConfig.HasKnownItem(normalizedKey) then
        return false, "Unknown item."
    end

    data = PriceConfig.GetData()
    data.itemOverrides[normalizedKey] = normalizedValue
    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true
end

function PriceConfig.ResetItemOverride(itemKey)
    local normalizedKey = Internal.Trim(itemKey)
    local data

    if normalizedKey == "" then
        return false, "Invalid item."
    end

    data = PriceConfig.GetData()
    data.itemOverrides[normalizedKey] = nil
    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true
end

function PriceConfig.ResetAllOverrides()
    local data = PriceConfig.GetData()

    data.tagMultipliers = {}
    data.itemOverrides = {}
    if PriceConfig.SeedDefaults(data) then
        -- Keep defaults current when resetting after content updates.
    end
    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true
end

function PriceConfig.ReplaceFromPreset(payload)
    local sanitized
    local warnings
    local data

    sanitized, warnings = PriceConfig.SanitizePresetPayload(payload)
    data = PriceConfig.GetData()

    data.tagMultipliers = sanitized.tagMultipliers
    data.itemOverrides = sanitized.itemOverrides
    if PriceConfig.SeedDefaults(data) then
        -- Defaults are always server-owned.
    end

    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true, warnings
end
