-- ==============================================================================
-- DTNPC_LootSearchShared_Core.lua
-- Core constants and generic helpers.
-- ==============================================================================

DTNPCLootSearch = DTNPCLootSearch or {}
DTNPCLootSearch.Internal = DTNPCLootSearch.Internal or {}
DTNPCLootSearch.Modules = DTNPCLootSearch.Modules or {}

if DTNPCLootSearch.Modules.Core then
    return
end

DTNPCLootSearch.Modules.Core = true

local Internal = DTNPCLootSearch.Internal

Internal.Constants = Internal.Constants or {
    SEARCH_STOP_DISTANCE = 1.55,
    SEARCH_WORLD_STOP_DISTANCE = 1.35,
    SEARCH_CORPSE_STOP_DISTANCE = 1.6,
    SEARCH_GROUND_STOP_DISTANCE = 1.4,
    SEARCH_VEHICLE_STOP_DISTANCE = 2.1,
    SEARCH_SOURCE_LIMIT = 24,
    SEARCH_ITEM_LIMIT = 48,
    SEARCH_SYNC_COOLDOWN_MS = 1000,
    SEARCH_RECENT_COLLECT_TTL_MS = 4000,
    SEARCH_VISUAL_COLLECT_MS = 2000,
    SEARCH_SCAN_CACHE_TTL_MS = 400,
    SEARCH_SCAN_BUCKET_SIZE = 2,
}

function Internal.lower(value)
    return string.lower(tostring(value or ""))
end

function Internal.clamp(value, minValue, maxValue)
    local numeric = tonumber(value) or minValue
    if numeric < minValue then
        return minValue
    end
    if numeric > maxValue then
        return maxValue
    end
    return numeric
end

function Internal.nowMillis()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end

    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor((tonumber(gameTime:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

function Internal.getDistance(ax, ay, bx, by)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dy = (tonumber(ay) or 0) - (tonumber(by) or 0)
    return math.sqrt((dx * dx) + (dy * dy))
end

function Internal.getItemDisplayName(invItem)
    if not invItem then
        return "Unknown"
    end
    if invItem.getDisplayName then
        return tostring(invItem:getDisplayName())
    end
    if invItem.getName then
        return tostring(invItem:getName())
    end
    if invItem.getFullType then
        return tostring(invItem:getFullType())
    end
    return tostring(invItem)
end

function Internal.getInventoryItemQuantity(invItem)
    local count = invItem and invItem.getCount and tonumber(invItem:getCount()) or 1
    if count and count > 1 then
        return math.max(1, math.floor(count))
    end
    return 1
end

function Internal.getInventoryItemID(invItem)
    if not invItem then
        return nil
    end
    if invItem.getID then
        return invItem:getID()
    end
    return nil
end

function Internal.isTableEmpty(value)
    if type(value) ~= "table" then
        return true
    end

    for _ in pairs(value) do
        return false
    end
    return true
end

function Internal.copyTableShallow(value)
    if type(value) ~= "table" then
        return value
    end

    local result = {}
    for key, entry in pairs(value) do
        result[key] = Internal.copyTableShallow(entry)
    end
    return result
end
