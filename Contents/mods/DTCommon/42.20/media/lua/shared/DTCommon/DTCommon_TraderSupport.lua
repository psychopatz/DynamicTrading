DTCommon = DTCommon or {}
DTCommon.TraderSupport = DTCommon.TraderSupport or {}

local Support = DTCommon.TraderSupport

function Support.Bounded(value, maximum)
    value = tostring(value or "")
    maximum = tonumber(maximum) or 128
    if #value > maximum then return string.sub(value, 1, maximum) end
    return value
end

function Support.PositiveInteger(value, fallback, maximum)
    value = math.floor(tonumber(value) or fallback or 1)
    if value < 1 then value = 1 end
    if maximum and value > maximum then value = maximum end
    return value
end

return Support
