-- ==============================================================================
-- DT_V2_RadarWindow_Tracking.lua
-- Tracking state and marker updates for the Trader Radar window.
-- ==============================================================================

function DT_V2_RadarWindow:startTracking(uuid, name)
    self.trackingUUID = uuid
    self.trackingName = name
    getSpecificPlayer(0):Say("Tracking signal: " .. tostring(name))
end

function DT_V2_RadarWindow:stopTracking()
    self.trackingUUID = nil
    self.trackingName = nil
    if EventMarkerHandler then
        EventMarkerHandler.remove(self.MARKER_ID)
    end

    if self.listPanel and self.listPanel.listbox then
        local sel = self.listPanel.listbox.selected
        if sel and self.listPanel.listbox.items[sel] then
            local itemData = self.listPanel.listbox.items[sel].item
            if itemData then
                self.actionPanel:updateButtonState(itemData.uuid)
            end
        end
    end
end

function DT_V2_RadarWindow:updateTrackingMarker()
    if not self.trackingUUID or not EventMarkerHandler then
        return
    end

    local tx, ty, tz, isLive = DT_V2_RadarManager.GetTraderCoords(self.trackingUUID)

    if not tx or not ty then
        return
    end

    local player = getSpecificPlayer(0)
    local dist = IsoUtils.DistanceTo(tx, ty, player:getX(), player:getY())

    local color = {r = 0, g = 1, b = 1}

    if dist < 300 then
        color = {r = 0.1, g = 1, b = 0.1}
    elseif dist < 1500 then
        color = {r = 1, g = 0.9, b = 0.2}
    else
        color = {r = 1, g = 0.4, b = 0.1}
    end

    local description = "SIGNAL: " .. tostring(self.trackingName)

    EventMarkerHandler.set(
        self.MARKER_ID,
        "friend.png",
        60,
        tx,
        ty,
        color,
        description
    )
end
