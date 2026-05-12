DT_GeolocatorSystem = DT_GeolocatorSystem or {}

DT_GeolocatorSystem.LoadState = DT_GeolocatorSystem.LoadState or {
    status = "idle",
    source = nil,
    startedAtMs = nil,
    lastDurationMs = nil,
    lastBuildingCount = 0,
}

local context = {
    INDEX_SCHEMA_VERSION = 1,
    SPATIAL_HASH_CELL_SIZE = 300,
}

function context.normalizeIndexKey(value)
    if DT_GeolocatorSystem.NormalizeLocationKey then
        return DT_GeolocatorSystem.NormalizeLocationKey(value)
    end

    if value == nil then
        return nil
    end

    local normalized = tostring(value):lower()
    normalized = normalized:gsub(",%s*ky$", "")
    normalized = normalized:gsub("%s+ky$", "")
    normalized = normalized:gsub("[^%w]", "")
    if normalized == "" then
        return nil
    end

    return normalized
end

function context.getClockMs()
    if getTimestampMs then
        return getTimestampMs()
    end

    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor(gameTime:getWorldAgeHours() * 3600000)
    end

    return nil
end

function context.resetMapTable(target)
    if type(target) ~= "table" then
        return
    end

    for key in pairs(target) do
        target[key] = nil
    end
end

function context.getBuildingModData()
    return ModData.getOrCreate(DT_GeolocatorSystem.MOD_DATA_KEY or "DT_Buildings")
end

return context
