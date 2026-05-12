local PriceConfig = DynamicTrading.PriceConfig
local Internal = DT_PriceConfigInternal

PriceConfig.MOD_DATA_KEY = "DynamicTrading_PriceConfig"
PriceConfig.VERSION = 1

function Internal.Trim(value)
    local text = tostring(value or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

function Internal.RoundPrice(value)
    local number = tonumber(value)
    if not number then
        return nil
    end

    if number < 0 then
        number = 0
    end

    return math.floor(number + 0.5)
end

function Internal.NormalizeMultiplier(value)
    local number = tonumber(value)
    if not number then
        return nil
    end

    if number < 0 then
        number = 0
    elseif number > 100 then
        number = 100
    end

    return math.floor((number * 1000) + 0.5) / 1000
end

function Internal.CloneMap(source)
    local copy = {}

    for key, value in pairs(source or {}) do
        copy[key] = value
    end

    return copy
end

function Internal.TriggerPriceConfigUpdated()
    if LuaEventManager and LuaEventManager.OnDynamicTradingPriceConfigUpdated then
        triggerEvent("OnDynamicTradingPriceConfigUpdated")
    end
end
