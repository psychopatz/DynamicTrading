-- ==============================================================================
-- INTERACTION HANDLERS
-- ==============================================================================
function DT_FactionInfoWindow:applyFactionSelection(f, requestRoster)
    if not f then return end

    requestRoster = (requestRoster ~= false)

    -- Cache Data for Tabs
    DT_FactionInfoWindow.selectedFaction = f
    self.selectedFaction = f
    local rosterData = DT_FactionInfoWindow.resolveRosterData()
    DT_FactionInfoWindow.lastRosterData = rosterData

    -- Update Window Header & Active Tab Only
    if DT_FactionInfoWindow.instance then
        local win = DT_FactionInfoWindow.instance
        if win.updateOwnedFactionStatus then
            win:updateOwnedFactionStatus(DT_FactionInfoWindow.cachedOwnedFactionStatus, f)
        end
        
        -- Update the info header (title etc)
        if win.tabInfo then win.tabInfo:updateData(f) end

        -- Update ONLY the currently visible tab
        local activeView = win.panel:getActiveView()
        if activeView and activeView.updateData then
            activeView:updateData(f, rosterData)
            -- Sync dimensions immediately to prevent "needs resize" bug
            if activeView.onResize then activeView:onResize() end 
        end
    end

    -- [MP OPTIMIZATION] Request detailed soul data for this faction on-demand
    if requestRoster and isClient() and not isServer() and not f.isV1 and not f.playerOwned then
        DynamicTrading.Log("DTCommons", "Faction", "Sync", "Requesting detailed roster for faction: " .. tostring(f.id))
        sendClientCommand(getSpecificPlayer(0), "DynamicTrading_V2", "RequestFactionRoster", { factionID = f.id })
    end
end

function DT_FactionInfoWindow.onListMouseDown(target, item)
    local f = item
    if not f then return end
    local win = target or DT_FactionInfoWindow.instance
    if not win or not win.applyFactionSelection then return end
    win:applyFactionSelection(f, true)
end
