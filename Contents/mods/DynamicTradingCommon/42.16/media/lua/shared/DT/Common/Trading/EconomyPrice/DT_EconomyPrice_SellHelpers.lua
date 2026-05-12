local Internal = DT_EconomyPriceInternal
local Common = Internal.Common

function Internal.ApplyEventAndHeat(value, tags, getPriceMod, globalHeat, verbose, label)
    local result = value

    if getPriceMod then
        local eventMult = getPriceMod(tags or {})
        result = result * eventMult
        if verbose and eventMult ~= 1.0 then
            DynamicTrading.Log("DTCommons", "Trade", "Trace", "| " .. tostring(label or "Event") .. "EventMult: " .. eventMult)
        end
    end

    for _, tag in ipairs(tags or {}) do
        local heat = globalHeat[tag]
        if heat and heat ~= 0 then
            result = result * (1.0 + heat)
            if verbose then
                DynamicTrading.Log("DTCommons", "Trade", "Trace", "| " .. tostring(label or "") .. "Heat(" .. tag .. "): " .. heat)
            end
        end
    end

    return result
end

function Internal.FindWantMultiplier(tags, archetype)
    if not archetype or not archetype.wants then
        return 1.0
    end

    for _, t in ipairs(tags or {}) do
        for wantTag, bonus in pairs(archetype.wants) do
            if Common.TagMatches(t, wantTag) then
                return bonus, wantTag
            end
        end
    end

    return 1.0
end
