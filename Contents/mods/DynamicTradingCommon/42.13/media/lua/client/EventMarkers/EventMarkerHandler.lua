EventMarkerHandler = {}
EventMarkerHandler.markers = {}

-- Create or update a marker
function EventMarkerHandler.set(markerID, icon, duration, posX, posY, color, desc)
    local player = getSpecificPlayer(0)
    local marker = EventMarkerHandler.markers[markerID]

    if not marker and duration > 0 then
        local oldX
        local oldY
        local pModData = player:getModData()["EventMarkerPlacement"]
        if pModData then
            oldX = pModData[1]
            oldY = pModData[2]
        end
        
        local screenX = oldX or (getCore():getScreenWidth() / 2) - (EventMarker.iconSize / 2)
        local screenY = oldY or (EventMarker.iconSize / 2)

        marker = EventMarker:new(markerID, icon, duration, posX, posY, player, screenX, screenY, color, desc)
        EventMarkerHandler.markers[markerID] = marker
    end

    if marker then
        marker.textureIcon = getTexture("media/ui/EventMarkers/" .. icon)
        marker:setDuration(duration)
        
        -- [UPDATED] Allow updating color and description dynamically
        if color then marker.markerColor = color end
        if desc then marker.desc = desc end
        
        marker:update(posX, posY)
    end
end

-- Remove a specific marker by ID
function EventMarkerHandler.remove(markerID)
    local marker = EventMarkerHandler.markers[markerID]
    if marker then
        marker:setDuration(0)
        marker:setVisible(false) -- Force hide immediately
        marker:removeFromUIManager() -- Ensure it's removed from UI
        EventMarkerHandler.markers[markerID] = nil
    end
end

-- Remove all markers
function EventMarkerHandler.removeAll()
    for markerID, marker in pairs(EventMarkerHandler.markers) do
        marker:setDuration(0)
        marker:setVisible(false)
        marker:removeFromUIManager()
        EventMarkerHandler.markers[markerID] = nil
    end
end

-- Cleanup old markers
function EventMarkerHandler.RemoveOldMarkers()
    local markers = EventMarkerHandler.markers
    for markerID, marker in pairs(markers) do
        if marker.start + marker.duration < getGametimeTimestamp() then
            marker:setDuration(0)
            EventMarkerHandler.markers[markerID] = nil
        end
    end
end

Events.EveryTenMinutes.Add(EventMarkerHandler.RemoveOldMarkers)
