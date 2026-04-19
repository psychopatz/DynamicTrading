-- =============================================================================
-- GEOLOCATOR SYSTEM: BUILDING LOGIC
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}

function DT_GeolocatorSystem.GetBuildingDetails(def)
    if not def then
        return {}
    end

    local details = {}
    details.roomCount = 0
    details.uniqueRooms = {}
    details.isAlarmed = def:isAlarmed()
    details.visited = def:isHasBeenVisited()
    details.id = def:getID()
    details.primaryRoom = "Building"

    local roomList = def:getRooms()
    if roomList then
        details.roomCount = roomList:size()
        local counts = {}
        local roomNames = {}

        for i = 0, roomList:size() - 1 do
            local room = roomList:get(i)
            local roomName = room:getName() or "unknown"
            counts[roomName] = (counts[roomName] or 0) + 1
            if not roomNames[roomName] then
                table.insert(details.uniqueRooms, roomName)
                roomNames[roomName] = true
            end
        end

        local maxCount = 0
        for name, count in pairs(counts) do
            if count > maxCount then
                maxCount = count
                details.primaryRoom = name
            end
        end

        for _, preferredRoom in ipairs(DT_GeolocatorSystem.Config.PreferredRooms) do
            if counts[preferredRoom] and counts[preferredRoom] > 0 then
                details.primaryRoom = preferredRoom
                break
            end
        end
    end

    return details
end