-- ==============================================================================
-- INTERACTION HANDLERS
-- ==============================================================================
function DT_FactionInfoWindow:applyFactionSelection(f, requestRoster)
    if not f then return end

    requestRoster = (requestRoster ~= false)

    -- Cache selected faction for updates (if needed)
    DT_FactionInfoWindow.selectedFaction = f
    self.selectedFaction = f

    -- Update All Tabs
    if DT_FactionInfoWindow.instance then
        local win = DT_FactionInfoWindow.instance
        if win.headerPanel and win.headerPanel.updateOwnedFactionStatus then
            win.headerPanel:updateOwnedFactionStatus(DT_FactionInfoWindow.cachedOwnedFactionStatus, f)
        end
        if win.tabInfo then win.tabInfo:updateData(f) end
        local rosterData = DT_FactionInfoWindow.resolveRosterData()
        if win.tabReputation then win.tabReputation:updateData(f, rosterData) end
        if win.tabEconomics then win.tabEconomics:updateData(f) end
        if win.tabStockpiles then win.tabStockpiles:updateData(f) end

        -- Population Tab needs roster data too
        if win.tabPopulation then win.tabPopulation:updateData(f, rosterData) end
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
