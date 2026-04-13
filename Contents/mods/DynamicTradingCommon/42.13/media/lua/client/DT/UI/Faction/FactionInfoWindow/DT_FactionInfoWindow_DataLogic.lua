function DT_FactionInfoWindow:refreshList()
    local player = getSpecificPlayer(0)
    if not player then return end

    local isV1 = (DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GetData) ~= nil

    -- Request Data
    if isClient() and not isServer() then
        if DT_FactionInfoWindow.cachedFactionData then
            self:populateList(DT_FactionInfoWindow.cachedFactionData, DT_FactionInfoWindow.cachedRosterData)
        end
        if self.headerPanel and self.headerPanel.updateOwnedFactionStatus then
            self.headerPanel:updateOwnedFactionStatus(DT_FactionInfoWindow.cachedOwnedFactionStatus, DT_FactionInfoWindow.selectedFaction)
        end
        sendClientCommand(player, "DynamicTrading_V2", "RequestFactionData", {})
        return
    end
    
    -- Singleplayer Direct Access
    local factionData = DT_FactionInfoWindow.resolveFactionData()
    local rosterData = DT_FactionInfoWindow.resolveRosterData()
    if DynamicTrading_Factions and DynamicTrading_Factions.GetOwnedFactionStatus then
        DT_FactionInfoWindow.cachedOwnedFactionStatus = DynamicTrading_Factions.GetOwnedFactionStatus(player)
    end
    
    self:populateList(factionData, rosterData)
end

function DT_FactionInfoWindow:populateList(factionData, rosterData)
    factionData = DT_FactionInfoWindow.InjectV1VirtualFaction(factionData)

    if not factionData then return end
    if not self.listbox then return end
    self.listbox:clear()
    
    -- If rosterData wasn't passed (e.g. from network callback old sig), try to get cached
    if not rosterData then
        rosterData = DT_FactionInfoWindow.cachedRosterData or {}
    end

    local ownedFactionID = DT_FactionInfoWindow.GetOwnedFactionID and DT_FactionInfoWindow.GetOwnedFactionID() or nil
    local keys = {}
    for id in pairs(factionData) do table.insert(keys, id) end
    table.sort(keys, function(a, b)
        local aID = tostring(a or "")
        local bID = tostring(b or "")
        if ownedFactionID then
            local aOwned = aID == ownedFactionID
            local bOwned = bID == ownedFactionID
            if aOwned ~= bOwned then
                return aOwned
            end
        end
        return aID < bID
    end)
    local preferredFactionID = (DT_FactionInfoWindow.selectedFaction and DT_FactionInfoWindow.selectedFaction.id) or ownedFactionID
    local selectedIndex = nil

    for _, id in ipairs(keys) do
        local f = factionData[id]
        if f and f.playerOwned and tostring(f.leadershipState or "") == "AdminReview" then
            f = nil
        end
        
        local isAlive = true
        if not f then
            isAlive = false
        elseif f.isV1 then
            -- Virtual faction is always alive
            isAlive = true
        elseif rosterData and rosterData.FactionMembers then
            local members = rosterData.FactionMembers[id]
            -- If we have members info, use it to determine life
            if members then
                isAlive = #members > 0
            else
                -- If we don't have members for this specific faction yet, 
                -- default to show it if f.memberCount > 0 (optimistic sync)
                isAlive = (f.memberCount or 0) > 0
            end
        else
            -- No roster data at all? Default to show based on faction's own count
            isAlive = (f.memberCount or 0) > 0
        end

        -- Always show if we have no reason to hide it (prevents UI flicker during sync)
        if isAlive then
            self.listbox:addItem(f.name or id, f)
            if preferredFactionID and preferredFactionID == id then
                selectedIndex = #self.listbox.items
            end
        end
    end
    
    -- Preserve existing selection when possible, otherwise select the first row.
    if self.listbox.items and #self.listbox.items > 0 then
        local targetIndex = selectedIndex or 1
        self.listbox.selected = targetIndex
        self:applyFactionSelection(self.listbox.items[targetIndex].item, false)
    else
        DT_FactionInfoWindow.selectedFaction = nil
    end
end
