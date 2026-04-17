function DT_RadioScannerWindow:startTracking(uuid, name)
    self.trackingUUID = uuid
    self.trackingName = name
    getSpecificPlayer(0):Say("Tracking signal: " .. tostring(name))
end

function DT_RadioScannerWindow:stopTracking()
    self.trackingUUID = nil
    self.trackingName = nil
    if EventMarkerHandler then
        EventMarkerHandler.remove(self.MARKER_ID)
    end

    if self.listPanel and self.listPanel.listbox then
        local selected = self.listPanel.listbox.selected
        if selected and self.listPanel.listbox.items[selected] then
            local itemData = self.listPanel.listbox.items[selected].item
            if itemData then
                self.actionPanel:updateButtonState(itemData.uuid)
            end
        end
    end
end

function DT_RadioScannerWindow:updateTrackingMarker()
    if not self.trackingUUID or not EventMarkerHandler or not DT_RadioScannerManager then
        return
    end

    local tx, ty = DT_RadioScannerManager.GetTraderCoords(self.trackingUUID)
    if not tx or not ty then
        return
    end

    local player = getSpecificPlayer(0)
    local dist = IsoUtils.DistanceTo(tx, ty, player:getX(), player:getY())
    local color = { r = 0, g = 1, b = 1 }

    if dist < 300 then
        color = { r = 0.1, g = 1, b = 0.1 }
    elseif dist < 1500 then
        color = { r = 1, g = 0.9, b = 0.2 }
    else
        color = { r = 1, g = 0.4, b = 0.1 }
    end

    EventMarkerHandler.set(
        self.MARKER_ID,
        "friend.png",
        60,
        tx,
        ty,
        color,
        "SIGNAL: " .. tostring(self.trackingName)
    )
end