local PriceConfig = DynamicTrading.PriceConfig
local Internal = DT_PriceConfigInternal

function PriceConfig.SanitizePresetPayload(payload)
    local sanitized = {
        tagMultipliers = {},
        itemOverrides = {}
    }
    local warnings = {}

    for tag, value in pairs(payload and payload.tagMultipliers or {}) do
        local normalizedTag = PriceConfig.NormalizeTag(tag)
        local normalizedValue = Internal.NormalizeMultiplier(value)

        if normalizedTag and normalizedValue ~= nil and PriceConfig.HasKnownTag(normalizedTag) then
            if math.abs(normalizedValue - 1.0) > 0.0001 then
                sanitized.tagMultipliers[normalizedTag] = normalizedValue
            end
        else
            warnings[#warnings + 1] = "Skipped tag override: " .. tostring(tag)
        end
    end

    for itemKey, value in pairs(payload and payload.itemOverrides or {}) do
        local normalizedKey = Internal.Trim(itemKey)
        local normalizedValue = Internal.RoundPrice(value)

        if normalizedKey ~= "" and normalizedValue ~= nil and PriceConfig.HasKnownItem(normalizedKey) then
            sanitized.itemOverrides[normalizedKey] = normalizedValue
        else
            warnings[#warnings + 1] = "Skipped item override: " .. tostring(itemKey)
        end
    end

    return sanitized, warnings
end
