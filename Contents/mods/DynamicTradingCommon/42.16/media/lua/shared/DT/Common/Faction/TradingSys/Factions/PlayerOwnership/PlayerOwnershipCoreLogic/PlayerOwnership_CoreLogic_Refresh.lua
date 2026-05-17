return function(context)
    local Public = context.Public
    local Internal = context.Internal
    local Utils = context.Utils

    local getFactionData = context.getFactionData
    local getOwnerUsername = context.getOwnerUsername
    local findWorkerByID = context.findWorkerByID
    local isWorkerLiving = context.isWorkerLiving
    local removeValue = context.removeValue
    local appendUnique = context.appendUnique
    local getWorkerSummary = context.getWorkerSummary
    local getWorkersForOwner = context.getWorkersForOwner
    local isWorkerRegistryAvailable = context.isWorkerRegistryAvailable
    local isDynamicColoniesActive = context.isDynamicColoniesActive
    local isAdminReview = context.isAdminReview

    function context.syncLinkedWorkersFromOwner(faction, owner)
        if not faction or not isWorkerRegistryAvailable() then
            return false
        end

        faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
        local ownerWorkers = getWorkersForOwner(owner)
        for _, worker in ipairs(ownerWorkers) do
            if worker and worker.workerID and isWorkerLiving(worker) then
                appendUnique(faction.linkedWorkerIDs, worker.workerID)
            end
        end
        return true
    end
    Internal.syncLinkedWorkersFromOwner = context.syncLinkedWorkersFromOwner

    function context.buildFactionWorkerSummaries(faction)
        local summaries = {}
        if not faction or not faction.playerOwned then
            return summaries
        end

        local owner = getOwnerUsername(faction.leaderUsername)
        faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
        faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}

        for _, workerID in ipairs(faction.linkedWorkerIDs) do
            local worker = findWorkerByID(owner, workerID)
            if worker then
                local summary = getWorkerSummary(worker)
                local tradeSoulUUID = faction.tradeWorkerSouls[workerID]
                local tradeSoul = tradeSoulUUID and DynamicTrading_Roster.GetSoulRegistry(tradeSoulUUID) or nil
                local tradeActive = faction.activeTradeWorkerIDs[workerID] == true
                if tradeSoul then
                    tradeActive = tradeSoul.status == "Away" or tradeSoul.status == "Trading"
                end
                summary.tradeEligible = faction.tradeEligibleWorkerIDs[workerID] == true
                summary.tradeActive = tradeActive
                summary.tradeStatus = tradeSoul and tradeSoul.status or nil
                summary.tradeSoulUUID = tradeSoulUUID
                summary.isLinkedFactionMember = true
                summaries[#summaries + 1] = summary
            end
        end

        table.sort(summaries, function(a, b)
            return tostring(a.name or a.workerID) < tostring(b.name or b.workerID)
        end)
        return summaries
    end
    Internal.buildFactionWorkerSummaries = context.buildFactionWorkerSummaries

    function context.collapseFaction(factionID, reason)
        local data = getFactionData()
        local faction = data[factionID]
        if not faction then
            return false
        end
        if DynamicTrading_Roster and DynamicTrading_Roster.ClearSouls then
            DynamicTrading_Roster.ClearSouls(factionID)
        end
        data[factionID] = nil
        ModData.transmit(Utils.MOD_DATA_KEY)
        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Collapsed player faction [" .. tostring(factionID) .. "] reason=" .. tostring(reason or "unknown"))
        return true
    end
    Internal.collapseFaction = context.collapseFaction

    function Public.RefreshPlayerFaction(factionID)
        local data = getFactionData()
        local faction = data[factionID]
        if not Public.IsPlayerFaction(faction) then
            return faction
        end

        context.normalizeMembershipState(faction)
        if isAdminReview(faction) then
            context.syncFactionToColony(faction, { createIfMissing = false })
            return faction
        end
        if not isDynamicColoniesActive() then
            return faction
        end

        local owner = getOwnerUsername(faction.leaderUsername)
        local ownerWorkers = getWorkersForOwner(owner)
        faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
        faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
        faction.controlMode = faction.controlMode or "HybridManual"
        faction.leadershipState = faction.leadershipState or "Active"
        faction.homeCoords = context.buildFactionHome(owner, ownerWorkers, owner)
        faction.baseConfigured = faction.homeCoords and faction.homeCoords.baseConfigured == true or false
        faction.town = faction.homeCoords and faction.homeCoords.town or faction.town

        if not context.syncLinkedWorkersFromOwner(faction, owner) then
            faction.memberCount = math.max(tonumber(faction.memberCount) or 0, #(faction.linkedWorkerIDs or {}))
            context.syncFactionToColony(faction, { createIfMissing = false })
            return faction
        end

        local livingCount = 0
        local staleIDs = {}
        for _, workerID in ipairs(faction.linkedWorkerIDs) do
            local worker = findWorkerByID(owner, workerID)
            if not worker then
                staleIDs[#staleIDs + 1] = workerID
            elseif isWorkerLiving(worker) then
                livingCount = livingCount + 1
                local tradeUUID = faction.tradeWorkerSouls[workerID]
                if tradeUUID then
                    local soul = DynamicTrading_Roster.GetSoulRegistry(tradeUUID)
                    if soul then
                        Internal.updateSoulFromWorker(tradeUUID, worker, faction)
                        if soul.status == "Away" or soul.status == "Trading" then
                            faction.activeTradeWorkerIDs[workerID] = true
                        else
                            faction.activeTradeWorkerIDs[workerID] = nil
                        end
                    else
                        faction.tradeWorkerSouls[workerID] = nil
                        faction.activeTradeWorkerIDs[workerID] = nil
                    end
                else
                    faction.activeTradeWorkerIDs[workerID] = nil
                end
            else
                faction.activeTradeWorkerIDs[workerID] = nil
            end
        end

        for _, workerID in ipairs(staleIDs) do
            removeValue(faction.linkedWorkerIDs, workerID)
            Internal.clearWorkerTradeLink(faction, workerID, true)
        end

        faction.memberCount = livingCount
        if livingCount <= 0 then
            if faction.__dtAllowEmptyCollapse == true then
                context.markAdminReview(faction, "no_linked_workers")
            else
                faction.memberCount = math.max(tonumber(faction.memberCount) or 0, #(faction.linkedWorkerIDs or {}))
                faction.refreshPending = true
            end
            context.syncFactionToColony(faction, { createIfMissing = false })
            return faction
        end

        faction.refreshPending = nil
        context.syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return faction
    end

    function Public.RefreshAllPlayerFactions()
        local data = getFactionData()
        local ids = {}
        for factionID, faction in pairs(data) do
            if faction.playerOwned then
                ids[#ids + 1] = factionID
            end
        end
        for _, factionID in ipairs(ids) do
            Public.RefreshPlayerFaction(factionID)
        end
    end
end
