-- ==============================================================================
-- NETWORKING & INSTANCE MANAGEMENT
-- ==============================================================================

-- Handle server response
local function onServerCommand(module, command, args)
    if module ~= "DynamicTrading_V2" then return end
    
    if command == "SyncFactionDebugData" then
        if DT_FactionInfoWindow.instance and DT_FactionInfoWindow.instance:getIsVisible() then
            -- Cache data
            DT_FactionInfoWindow.cachedFactionData = args.factions
            DT_FactionInfoWindow.cachedRosterData = args.roster
            DT_FactionInfoWindow.cachedOwnedFactionStatus = args.ownedStatus or DT_FactionInfoWindow.cachedOwnedFactionStatus
            
            -- [V1 PARITY] Sink roster souls into ModData for legacy V1 logic (Signal Panel, etc)
            if args.roster then
                local localRoster = ModData.getOrCreate("DynamicTrading_Roster")
                localRoster.Souls = DT_FactionInfoWindow.shallowCopy(args.roster.Souls)
                localRoster.FactionMembers = DT_FactionInfoWindow.shallowCopy(args.roster.FactionMembers)
                localRoster.Traders = DT_FactionInfoWindow.shallowCopy(args.roster.Traders)
            end

            -- Populate
            DT_FactionInfoWindow.instance:populateList(args.factions, args.roster)
            if DT_FactionInfoWindow.instance.refreshSelectedFactionView then
                DT_FactionInfoWindow.instance:refreshSelectedFactionView(false)
            end
        end
    elseif command == "SyncFactionRoster" then
        -- Detailed souls for a specific faction arrived
        local factionID = args.factionID
        local souls = args.souls or {}
        local members = args.members or {}
        
        DT_FactionInfoWindow.cachedRosterData = DT_FactionInfoWindow.cachedRosterData or {}
        DT_FactionInfoWindow.cachedRosterData.Souls = DT_FactionInfoWindow.cachedRosterData.Souls or {}
        DT_FactionInfoWindow.cachedRosterData.FactionMembers = DT_FactionInfoWindow.cachedRosterData.FactionMembers or {}

        DT_FactionInfoWindow.clearFactionSoulCache(DT_FactionInfoWindow.cachedRosterData, factionID)
        DT_FactionInfoWindow.cachedRosterData.FactionMembers[factionID] = members
        
        -- Replace this faction's soul subset in our cache
        for uuid, soul in pairs(souls) do
            DT_FactionInfoWindow.cachedRosterData.Souls[uuid] = soul
        end

        local localRoster = ModData.getOrCreate("DynamicTrading_Roster")
        local localSouls = localRoster.Souls or {}
        local localMembers = localRoster.FactionMembers or {}
        DT_FactionInfoWindow.clearFactionSoulCache({
            Souls = localSouls,
            FactionMembers = localMembers
        }, factionID)
        localMembers[factionID] = members
        for uuid, soul in pairs(souls) do
            localSouls[uuid] = soul
        end
        localRoster.Souls = localSouls
        localRoster.FactionMembers = localMembers
        
        -- If this is the currently selected faction, refresh the population tab
        if args.ownedStatus then
            DT_FactionInfoWindow.cachedOwnedFactionStatus = args.ownedStatus
        end

        if DT_FactionInfoWindow.selectedFaction and DT_FactionInfoWindow.selectedFaction.id == factionID then
            if DT_FactionInfoWindow.instance then
                if DT_FactionInfoWindow.instance.tabPopulation then
                    DT_FactionInfoWindow.instance.tabPopulation:updateData(DT_FactionInfoWindow.selectedFaction, DT_FactionInfoWindow.cachedRosterData)
                end
                if DT_FactionInfoWindow.instance.tabReputation then
                    DT_FactionInfoWindow.instance.tabReputation:updateData(DT_FactionInfoWindow.selectedFaction, DT_FactionInfoWindow.cachedRosterData)
                end
                if DT_FactionInfoWindow.instance.tabCalendar then
                    DT_FactionInfoWindow.instance.tabCalendar:updateData(DT_FactionInfoWindow.selectedFaction, DT_FactionInfoWindow.cachedRosterData)
                end
                if DT_FactionInfoWindow.instance.refreshSelectedFactionView then
                    DT_FactionInfoWindow.instance:refreshSelectedFactionView(false)
                end
            end
        end
    elseif command == "SyncOwnedFactionStatus" then
        local previousStatus = DT_FactionInfoWindow.cachedOwnedFactionStatus
        local previousFactionID = previousStatus and previousStatus.faction and previousStatus.faction.id or nil
        DT_FactionInfoWindow.cachedOwnedFactionStatus = args and args.status or nil
        local newStatus = DT_FactionInfoWindow.cachedOwnedFactionStatus
        local newFactionID = newStatus and newStatus.faction and newStatus.faction.id or nil
        local factionData = DT_FactionInfoWindow.resolveFactionData()
        local rosterData = DT_FactionInfoWindow.resolveRosterData()
        local selectedFaction = DT_FactionInfoWindow.selectedFaction
        local selectedFactionID = selectedFaction and selectedFaction.id or nil

        local shouldRefreshList = previousFactionID ~= newFactionID or selectedFaction == nil
        if DT_FactionInfoWindow.instance and DT_FactionInfoWindow.instance.populateList and shouldRefreshList then
            DT_FactionInfoWindow.instance:populateList(factionData, rosterData)
            selectedFaction = DT_FactionInfoWindow.selectedFaction
            selectedFactionID = selectedFaction and selectedFaction.id or nil
        elseif DT_FactionInfoWindow.instance and selectedFactionID and factionData and factionData[selectedFactionID] then
            selectedFaction = factionData[selectedFactionID]
            DT_FactionInfoWindow.selectedFaction = selectedFaction
            DT_FactionInfoWindow.instance.selectedFaction = selectedFaction
        end

        if DT_FactionInfoWindow.instance and DT_FactionInfoWindow.instance.updateOwnedFactionStatus then
            DT_FactionInfoWindow.instance:updateOwnedFactionStatus(
                DT_FactionInfoWindow.cachedOwnedFactionStatus,
                selectedFaction
            )
        end
        if selectedFaction
            and selectedFaction.playerOwned
            and DT_FactionInfoWindow.instance
            and DT_FactionInfoWindow.instance.tabPopulation then
            DT_FactionInfoWindow.instance.tabPopulation:updateData(
                selectedFaction,
                rosterData
            )
        end
        if selectedFaction
            and selectedFaction.playerOwned
            and DT_FactionInfoWindow.instance
            and DT_FactionInfoWindow.instance.tabInfo then
            DT_FactionInfoWindow.instance.tabInfo:updateData(
                selectedFaction,
                rosterData
            )
        end
        if selectedFaction
            and DT_FactionInfoWindow.instance
            and DT_FactionInfoWindow.instance.tabCalendar then
            DT_FactionInfoWindow.instance.tabCalendar:updateData(
                selectedFaction,
                rosterData
            )
        end
        if DT_PlayerFactionMembersModal
            and DT_PlayerFactionMembersModal.instance
            and DT_PlayerFactionMembersModal.instance:getIsVisible() then
            DT_PlayerFactionMembersModal.instance.status = DT_FactionInfoWindow.cachedOwnedFactionStatus
            DT_PlayerFactionMembersModal.instance:refresh()
        end
    elseif command == "OwnedFactionActionResult" then
        if args and args.success and args.discoverTrader and args.traderID
            and DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.DiscoverTrader then
            local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
            if player then
                DynamicTrading.Manager.DiscoverTrader(args.traderID, player)
            end
        end
        if DT_PlayerFactionMembersModal
            and DT_PlayerFactionMembersModal.instance
            and DT_PlayerFactionMembersModal.instance:getIsVisible()
            and args
            and args.message then
            DT_PlayerFactionMembersModal.instance:setStatus(args.message)
        end
        if DT_FactionInfoWindow.instance and args and args.success and DT_FactionInfoWindow.instance.pendingOpenOwnedFactionWindowAfterAction then
            DT_FactionInfoWindow.instance.pendingOpenOwnedFactionWindowAfterAction = nil
            DT_FactionInfoWindow.instance:openOwnedFactionManagementWindow()
        elseif DT_FactionInfoWindow.instance and args and not args.success then
            DT_FactionInfoWindow.instance.pendingOpenOwnedFactionWindowAfterAction = nil
        end
        if DT_FactionInfoWindow.instance
            and DT_FactionInfoWindow.instance:getIsVisible()
            and DT_FactionInfoWindow.selectedFaction then
            DT_FactionInfoWindow.instance:applyFactionSelection(DT_FactionInfoWindow.selectedFaction, false)
        end
    end
end

local function onFactionWindowModDataUpdated(key)
    if not DT_FactionInfoWindow.instance or not DT_FactionInfoWindow.instance:getIsVisible() then
        return
    end

    local factionLogsKey = DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.GetStorageKey and DynamicTrading.GameplayLogs.GetStorageKey("Factions") or "DynamicTrading_GameplayLogs_Factions"

    if key == "DynamicTrading_Factions" or key == "DynamicTrading_Roster" then
        local factionData = DT_FactionInfoWindow.resolveFactionData()
        local rosterData = DT_FactionInfoWindow.resolveRosterData()
        DT_FactionInfoWindow.instance:populateList(factionData, rosterData)
        if DT_FactionInfoWindow.instance.refreshSelectedFactionView then
            DT_FactionInfoWindow.instance:refreshSelectedFactionView(false)
        end
        return
    end

    if key == "DynamicTrading_Engine_v2" or key == factionLogsKey or key == "DynamicTrading_Logs_Factions" then
        local panel = DT_FactionInfoWindow.instance.panel
        if panel then
            local activeView = DT_FactionInfoWindow.GetTabContentView and DT_FactionInfoWindow.GetTabContentView(panel:getActiveView()) or panel:getActiveView()
            if activeView and activeView.updateData then
                local rosterData = DT_FactionInfoWindow.resolveRosterData()
                activeView:updateData(DT_FactionInfoWindow.selectedFaction, rosterData)
            end
        end
    end
end

-- Reactive Refresh for Multiplayer (Static/Singleton level)
if not DT_FactionInfoWindow.EventsAdded then
    Events.OnReceiveGlobalModData.Add(function(key, data)
        onFactionWindowModDataUpdated(key)
    end)
    if Events.OnDynamicTradingLogsUpdated then
        Events.OnDynamicTradingLogsUpdated.Add(function(key)
            onFactionWindowModDataUpdated(key)
        end)
    end
    Events.OnServerCommand.Add(onServerCommand)
    DT_FactionInfoWindow.EventsAdded = true
end
