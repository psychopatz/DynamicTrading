local Utils = require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnership_Utils"

return function(Public, Internal)
    local getFactionData = Utils.getFactionData
    local getOwnerUsername = Utils.getOwnerUsername
    local findWorkerByID = Utils.findWorkerByID
    local isWorkerLiving = Utils.isWorkerLiving
    local removeValue = Utils.removeValue
    local trimName = Utils.trimName
    local sanitizeID = Utils.sanitizeID
    local getWorkersForOwner = Utils.getWorkersForOwner
    local buildFactionHome = Utils.buildFactionHome
    local appendUnique = Utils.appendUnique
    local getWorkerSummary = Utils.getWorkerSummary

    local function syncLinkedWorkersFromOwner(faction, owner)
        if not faction then return end
        faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
        local ownerWorkers = getWorkersForOwner(owner)
        for _, worker in ipairs(ownerWorkers) do
            if worker and worker.workerID and isWorkerLiving(worker) then
                appendUnique(faction.linkedWorkerIDs, worker.workerID)
            end
        end
    end
    Internal.syncLinkedWorkersFromOwner = syncLinkedWorkersFromOwner

    local function buildFactionWorkerSummaries(faction)
        local summaries = {}
        if not faction or not faction.playerOwned then return summaries end
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
    Internal.buildFactionWorkerSummaries = buildFactionWorkerSummaries

    local function collapseFaction(factionID, reason)
        local data = getFactionData()
        local faction = data[factionID]
        if not faction then return false end
        if DynamicTrading_Roster and DynamicTrading_Roster.ClearSouls then
            DynamicTrading_Roster.ClearSouls(factionID)
        end
        data[factionID] = nil
        ModData.transmit(Utils.MOD_DATA_KEY)
        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Collapsed player faction [" .. tostring(factionID) .. "] reason=" .. tostring(reason or "unknown"))
        return true
    end
    Internal.collapseFaction = collapseFaction

    function Public.IsPlayerFaction(faction)
        return type(faction) == "table" and faction.playerOwned == true
    end

    function Public.GetPlayerFactionID(ownerUsername)
        local owner = getOwnerUsername(ownerUsername)
        local data = getFactionData()
        for factionID, faction in pairs(data) do
            if faction.playerOwned and getOwnerUsername(faction.leaderUsername) == owner then
                return factionID
            end
        end
        return nil
    end

    function Public.GetPlayerFaction(ownerUsername)
        local factionID = Public.GetPlayerFactionID(ownerUsername)
        if not factionID then return nil end
        return getFactionData()[factionID]
    end

    function Public.ValidateFactionName(rawName, ignoreFactionID)
        local name = trimName(rawName)
        if name == "" then return false, "Faction name cannot be empty." end
        if #name > 32 then return false, "Faction name must be 32 characters or less." end
        local lowerName = string.lower(name)
        for factionID, faction in pairs(getFactionData()) do
            if factionID ~= ignoreFactionID and string.lower(tostring(faction.name or "")) == lowerName then
                return false, "That faction name is already in use."
            end
        end
        return true, name
    end

    function Public.RefreshPlayerFaction(factionID)
        local data = getFactionData()
        local faction = data[factionID]
        if not Public.IsPlayerFaction(faction) then return faction end
        local owner = getOwnerUsername(faction.leaderUsername)
        faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
        faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
        faction.controlMode = faction.controlMode or "HybridManual"
        faction.leadershipState = faction.leadershipState or "Active"
        syncLinkedWorkersFromOwner(faction, owner)
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
            collapseFaction(factionID, "no_linked_workers")
            return nil
        end
        ModData.transmit(Utils.MOD_DATA_KEY)
        return faction
    end

    function Public.RefreshAllPlayerFactions()
        local data = getFactionData()
        local ids = {}
        for factionID, faction in pairs(data) do
            if faction.playerOwned then ids[#ids + 1] = factionID end
        end
        for _, factionID in ipairs(ids) do Public.RefreshPlayerFaction(factionID) end
    end

    function Public.BuildOwnedFactionStatus(ownerUsername)
        local owner = getOwnerUsername(ownerUsername)
        local workers = getWorkersForOwner(owner)
        local livingWorkers = {}
        for _, worker in ipairs(workers) do
            if isWorkerLiving(worker) then livingWorkers[#livingWorkers + 1] = worker end
        end
        local faction = Public.GetPlayerFaction(owner)
        if faction then faction = Public.RefreshPlayerFaction(faction.id) or nil end
        return {
            ownerUsername = owner,
            canCreate = faction == nil and #livingWorkers >= 1,
            workerCount = #livingWorkers,
            faction = faction,
            linkedWorkers = faction and buildFactionWorkerSummaries(faction) or {},
            createBlockedReason = faction and "already_has_faction" or (#livingWorkers < 1 and "needs_recruit" or nil)
        }
    end

    function Public.CreatePlayerFaction(player, rawName)
        local owner = getOwnerUsername(player)
        if Public.GetPlayerFaction(owner) then return false, "You already control a faction.", nil end
        local isValid, nameOrReason = Public.ValidateFactionName(rawName)
        if not isValid then return false, nameOrReason, nil end
        local workers = getWorkersForOwner(owner)
        local linkedWorkerIDs = {}
        for _, worker in ipairs(workers) do
            if isWorkerLiving(worker) then linkedWorkerIDs[#linkedWorkerIDs + 1] = worker.workerID end
        end
        if #linkedWorkerIDs < 1 then return false, "You need at least one living recruit before founding a faction.", nil end
        local factionID = "player_" .. sanitizeID(owner)
        local homeCoords = buildFactionHome(player, workers)
        DynamicTrading_Factions.CreateFaction(factionID, {
            playerOwned = true,
            leaderUsername = owner,
            leadershipState = "Active",
            regencyReason = nil,
            controlMode = "HybridManual",
            name = nameOrReason,
            town = homeCoords.town,
            homeCoords = homeCoords,
            memberCount = #linkedWorkerIDs,
            linkedWorkerIDs = linkedWorkerIDs,
            tradeEligibleWorkerIDs = {},
            activeTradeWorkerIDs = {},
            tradeWorkerSouls = {},
            createdDay = getGameTime() and getGameTime():getDaysSurvived() or 0
        })
        local faction = Public.RefreshPlayerFaction(factionID)
        return faction ~= nil, faction and "Faction founded." or "Faction creation failed.", faction
    end
end
