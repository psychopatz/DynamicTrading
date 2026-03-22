local Utils = require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnership_Utils"

return function(Public, Internal)
    local getFactionData = Utils.getFactionData
    local getOwnerUsername = Utils.getOwnerUsername
    local findWorkerByID = Utils.findWorkerByID
    local isWorkerLiving = Utils.isWorkerLiving
    local getDeadState = Utils.getDeadState
    local getWorkerRegistry = Utils.getWorkerRegistry
    local appendUnique = Utils.appendUnique
    local removeValue = Utils.removeValue

    function Public.GetLivingWorkersForFaction(factionID)
        local faction = getFactionData()[factionID]
        if not Public.IsPlayerFaction(faction) then return {} end
        local owner = getOwnerUsername(faction.leaderUsername)
        local workers = {}
        for _, workerID in ipairs(faction.linkedWorkerIDs or {}) do
            local worker = findWorkerByID(owner, workerID)
            if isWorkerLiving(worker) then workers[#workers + 1] = worker end
        end
        return workers
    end

    function Public.ApplyCasualties(factionID, count, cause)
        local faction = Public.RefreshPlayerFaction(factionID)
        if not Public.IsPlayerFaction(faction) then return 0 end
        local livingWorkers = Public.GetLivingWorkersForFaction(factionID)
        local casualties = 0
        local target = math.max(0, math.floor(tonumber(count) or 0))
        while target > 0 and #livingWorkers > 0 do
            local index = ZombRand(#livingWorkers) + 1
            local worker = table.remove(livingWorkers, index)
            if worker then
                worker.state = getDeadState()
                worker.hp = 0
                worker.jobEnabled = false
                worker.presenceState = DT_Labour and DT_Labour.Config and DT_Labour.Config.PresenceStates and DT_Labour.Config.PresenceStates.Home or worker.presenceState
                worker.deathCause = tostring(cause or "Faction casualty")
                Internal.clearWorkerTradeLink(faction, worker.workerID, true)
                casualties = casualties + 1
                target = target - 1
            end
        end
        if getWorkerRegistry() and getWorkerRegistry().Save then getWorkerRegistry().Save() end
        Public.RefreshPlayerFaction(factionID)
        return casualties
    end

    function Public.OnLabourWorkerCreated(ownerUsername, worker)
        if not worker or not worker.workerID then return nil end
        local faction = Public.GetPlayerFaction(ownerUsername)
        if not Public.IsPlayerFaction(faction) then return nil end
        faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
        appendUnique(faction.linkedWorkerIDs, worker.workerID)
        faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
        faction.tradeEligibleWorkerIDs[worker.workerID] = faction.tradeEligibleWorkerIDs[worker.workerID] == true
        faction.activeTradeWorkerIDs[worker.workerID] = nil
        Public.RefreshPlayerFaction(faction.id)
        return faction
    end

    function Public.OnLabourWorkerRemoved(ownerUsername, workerID)
        local faction = Public.GetPlayerFaction(ownerUsername)
        if not Public.IsPlayerFaction(faction) then return nil end
        removeValue(faction.linkedWorkerIDs, workerID)
        Internal.clearWorkerTradeLink(faction, workerID, true)
        Public.RefreshPlayerFaction(faction.id)
        return faction
    end
end
