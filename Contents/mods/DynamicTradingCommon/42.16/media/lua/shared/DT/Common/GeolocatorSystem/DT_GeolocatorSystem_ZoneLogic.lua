-- =============================================================================
-- GEOLOCATOR SYSTEM: ZONE LOGIC
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

function DT_GeolocatorSystem.GetZoneArea(zone)
    if not zone then
        return 0
    end

    local width = 0
    local height = 0

    if zone.getW and zone.getH then
        width = zone:getW()
        height = zone:getH()
    elseif zone.getWidth and zone.getHeight then
        width = zone:getWidth()
        height = zone:getHeight()
    elseif zone.w and zone.h then
        width = zone.w
        height = zone.h
    end

    return width * height
end