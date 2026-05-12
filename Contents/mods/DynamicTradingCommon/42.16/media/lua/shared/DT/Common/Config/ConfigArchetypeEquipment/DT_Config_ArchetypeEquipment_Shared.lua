-- =============================================================================
-- ARCHETYPE EQUIPMENT: SHARED
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeEquipment = DynamicTrading.ArchetypeEquipment or {}
DynamicTrading.ArchetypeEquipmentInternal = DynamicTrading.ArchetypeEquipmentInternal or {}

local internal = DynamicTrading.ArchetypeEquipmentInternal

internal.fallbackProfileCache = internal.fallbackProfileCache or {
    masterCount = -1,
    profile = nil,
}

function internal.deepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, entry in pairs(value) do
        copy[key] = internal.deepCopy(entry)
    end
    return copy
end

function internal.clampNumber(value, minimum, maximum)
    local number = tonumber(value) or minimum or 0
    if minimum ~= nil and number < minimum then
        number = minimum
    end
    if maximum ~= nil and number > maximum then
        number = maximum
    end
    return number
end

function internal.lower(value)
    return string.lower(tostring(value or ""))
end
