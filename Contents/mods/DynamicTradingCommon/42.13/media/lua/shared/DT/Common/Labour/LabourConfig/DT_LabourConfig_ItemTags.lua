DT_Labour = DT_Labour or {}
DT_Labour.Config = DT_Labour.Config or {}

local Config = DT_Labour.Config

function Config.NormalizeUnitValue(value)
    if not value then return 0 end
    value = tonumber(value) or 0
    if math.abs(value) > 1.0 then
        return value / 100.0
    end
    return value
end

function Config.RandomRangeInclusive(minValue, maxValue)
    local minNumber = math.floor(tonumber(minValue) or 0)
    local maxNumber = math.floor(tonumber(maxValue) or minNumber)
    if maxNumber < minNumber then
        minNumber, maxNumber = maxNumber, minNumber
    end

    local span = (maxNumber - minNumber) + 1
    if span <= 1 then
        return minNumber
    end

    return minNumber + ZombRand(span)
end

function Config.TagMatches(itemTag, queryTag)
    if not itemTag or not queryTag then return false end
    if itemTag == queryTag then return true end
    return string.find(itemTag, queryTag .. "%.") == 1
end

function Config.HasMatchingTag(tagList, queryTag)
    if type(tagList) ~= "table" then return false end
    for _, itemTag in ipairs(tagList) do
        if Config.TagMatches(itemTag, queryTag) then
            return true
        end
    end
    return false
end

function Config.FindItemTags(fullType)
    local masterList = DynamicTrading
        and DynamicTrading.Config
        and DynamicTrading.Config.MasterList or nil

    local entry = masterList and masterList[fullType] or nil
    if entry and type(entry.tags) == "table" then
        return entry.tags
    end

    return {}
end

return Config
