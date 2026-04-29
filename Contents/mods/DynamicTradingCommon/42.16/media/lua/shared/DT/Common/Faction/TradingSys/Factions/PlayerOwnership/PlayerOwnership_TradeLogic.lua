local Utils = require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnership_Utils"

return function(Public, Internal)
    local getOwnerUsername = Utils.getOwnerUsername
    local findWorkerByID = Utils.findWorkerByID
    local isWorkerLiving = Utils.isWorkerLiving
    local getCurrentHours = Utils.getCurrentHours
    local getWalkHours = Utils.getWalkHours
    local rollRadioStayHours = Utils.rollRadioStayHours

    local function updateSoulFromWorker(uuid, worker, faction)
        if not uuid or not worker then return nil end
        local soul = DynamicTrading_Roster.GetSoul(uuid)
        if not soul then return nil end
        soul.name = worker.name or soul.name
        soul.isFemale = worker.isFemale
        soul.identitySeed = worker.identitySeed or soul.identitySeed
        soul.archetypeID = worker.archetypeID or soul.archetypeID or worker.profession or "General"
        soul.factionID = faction and faction.id or soul.factionID
        soul.homeCoords = {
            x = worker.homeX or (faction and faction.homeCoords and faction.homeCoords.x) or 0,
            y = worker.homeY or (faction and faction.homeCoords and faction.homeCoords.y) or 0,
            z = worker.homeZ or (faction and faction.homeCoords and faction.homeCoords.z) or 0
        }
        soul.linkedWorkerID = worker.workerID
        soul.ownerUsername = worker.ownerUsername
        soul.isPlayerFactionTrader = true
        if soul.status == nil then soul.status = "Resting" end
        DynamicTrading_Roster.SaveSoul(uuid, soul)
        return soul
    end
    Internal.updateSoulFromWorker = updateSoulFromWorker

    local function isTradeSoulActive(uuid)
        if not uuid then return false end
        local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
        return soul and (soul.status == "Away" or soul.status == "Trading") or false
    end

    local function isV2TradeBackendActive()
        return DTNPCManager
            and DTNPCManager.StartTradeMission
            and DTNPCManager.SetNPCStatus
            and DTNPCManager.ProcessTradeCycles
    end

    local function startTradeMission(uuid)
        local soul = DynamicTrading_Roster.GetSoul(uuid)
        if isV2TradeBackendActive() then
            DTNPCManager.StartTradeMission(uuid, false, true)
            return { backend = "DynamicTradingV2", traderID = uuid, discoverTrader = false }
        end

        if soul and soul.factionID and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            local faction = DynamicTrading_Factions and DynamicTrading_Factions.GetFaction and (DynamicTrading_Factions.GetFaction(tostring(soul.factionID)) or DynamicTrading_Factions.GetFaction(soul.factionID)) or nil
            local factionName = faction and faction.name or "Independent"
            local traderName = soul.name or factionName
            DynamicTrading.GameplayLogs.AddFactionEvent(soul.factionID, DynamicTrading.GameplayEvents.TRADE_STARTED, {tostring(traderName)})
            DynamicTrading.GameplayLogs.AddRadioEvent(DynamicTrading.GameplayEvents.TRADE_STARTED, {tostring(factionName)})
        end

        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Trading", getCurrentHours() + rollRadioStayHours(), "Away")
        return { backend = "DynamicTradingV1", traderID = uuid, discoverTrader = true }
    end

    local function recallTradeMission(uuid)
        local travelHours = getWalkHours()
        if isV2TradeBackendActive() then
            DTNPCManager.SetNPCStatus(uuid, "Away", getCurrentHours() + travelHours, "Resting")
            return "DynamicTradingV2"
        end
        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Away", getCurrentHours() + travelHours, "Resting")
        return "DynamicTradingV1"
    end

    local function clearWorkerTradeLink(faction, workerID, removeSoul)
        if not faction or not workerID then return end
        faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
        faction.tradeEligibleWorkerIDs[workerID] = nil
        faction.activeTradeWorkerIDs[workerID] = nil
        local uuid = faction.tradeWorkerSouls[workerID]
        if removeSoul and uuid then
            if DTNPCManager and DTNPCManager.SetNPCStatus then
                pcall(DTNPCManager.SetNPCStatus, uuid, "Away", getGameTime():getWorldAgeHours() + 0.01, "Resting")
            end
            if DynamicTrading_Roster and DynamicTrading_Roster.RemoveSpecificSoul then
                DynamicTrading_Roster.RemoveSpecificSoul(uuid)
            end
        end
        faction.tradeWorkerSouls[workerID] = nil
    end
    Internal.clearWorkerTradeLink = clearWorkerTradeLink

    function Public.EnsureTradeSoul(factionID, workerID)
        local faction = Public.RefreshPlayerFaction(factionID)
        if not Public.IsPlayerFaction(faction) then return nil, "Faction not found." end
        local owner = getOwnerUsername(faction.leaderUsername)
        local worker = findWorkerByID(owner, workerID)
        if not worker then return nil, "Worker not found." end
        if not isWorkerLiving(worker) then return nil, "Worker is dead." end
        faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
        local uuid = faction.tradeWorkerSouls[workerID]
        if uuid then
            local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
            if soul then
                updateSoulFromWorker(uuid, worker, faction)
                return uuid, nil
            end
            faction.tradeWorkerSouls[workerID] = nil
        end
        uuid = DynamicTrading_Roster.AddSoul(factionID, worker.archetypeID or worker.profession or "General", {
            x = worker.homeX or (faction.homeCoords and faction.homeCoords.x) or 0,
            y = worker.homeY or (faction.homeCoords and faction.homeCoords.y) or 0,
            z = worker.homeZ or (faction.homeCoords and faction.homeCoords.z) or 0
        })
        faction.tradeWorkerSouls[workerID] = uuid
        updateSoulFromWorker(uuid, worker, faction)
        ModData.transmit(Utils.MOD_DATA_KEY)
        return uuid, nil
    end

    function Public.SetWorkerTradeEligibility(ownerUsername, workerID, enabled)
        local faction = Public.GetPlayerFaction(ownerUsername)
        if not Public.IsPlayerFaction(faction) then return false, "Player faction not found.", nil end
        if faction.leadershipState == "Regency" then return false, "Manual control is locked during regency.", faction end
        local owner = getOwnerUsername(ownerUsername)
        local worker = findWorkerByID(owner, workerID)
        if not worker then return false, "Worker not found.", faction end
        if not isWorkerLiving(worker) then return false, "Dead workers cannot trade.", faction end
        local linked = false
        for _, linkedWorkerID in ipairs(faction.linkedWorkerIDs or {}) do
            if linkedWorkerID == workerID then
                linked = true
                break
            end
        end
        if not linked then return false, "Worker is not linked to this faction.", faction end
        faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
        if enabled then
            faction.tradeEligibleWorkerIDs[workerID] = true
            Public.EnsureTradeSoul(faction.id, workerID)
        else
            clearWorkerTradeLink(faction, workerID, true)
        end
        Public.RefreshPlayerFaction(faction.id)
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, enabled and "Worker can now trade." or "Worker trade access revoked.", faction
    end

    function Public.DispatchTrade(ownerUsername, workerID, allowRegency)
        local faction = Public.GetPlayerFaction(ownerUsername)
        if not Public.IsPlayerFaction(faction) then return false, "Player faction not found.", nil, nil end
        if faction.leadershipState == "Regency" and allowRegency ~= true then return false, "Manual control is locked during regency.", faction, nil end
        if faction.tradeEligibleWorkerIDs[workerID] ~= true then return false, "That worker is not trade-approved.", faction, nil end
        local uuid, err = Public.EnsureTradeSoul(faction.id, workerID)
        if not uuid then return false, err or "Unable to prepare trader.", faction, nil end
        if isTradeSoulActive(uuid) then
            faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
            faction.activeTradeWorkerIDs[workerID] = true
            ModData.transmit(Utils.MOD_DATA_KEY)
            return false, "That trader is already active.", faction, { backend = isV2TradeBackendActive() and "DynamicTradingV2" or "DynamicTradingV1", traderID = uuid, discoverTrader = not isV2TradeBackendActive() }
        end
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        faction.activeTradeWorkerIDs[workerID] = true
        local details = startTradeMission(uuid)
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Trade mission dispatched.", faction, details
    end

    function Public.RecallTrade(ownerUsername, workerID, allowRegency)
        local faction = Public.GetPlayerFaction(ownerUsername)
        if not Public.IsPlayerFaction(faction) then return false, "Player faction not found.", nil, nil end
        if faction.leadershipState == "Regency" and allowRegency ~= true then return false, "Manual control is locked during regency.", faction, nil end
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        local uuid = faction.tradeWorkerSouls and faction.tradeWorkerSouls[workerID] or nil
        faction.activeTradeWorkerIDs[workerID] = nil
        if uuid then
            local backend = recallTradeMission(uuid)
            ModData.transmit(Utils.MOD_DATA_KEY)
            return true, "Trader recalled.", faction, { backend = backend, traderID = uuid, discoverTrader = false }
        end
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Trader recalled.", faction, nil
    end
end
