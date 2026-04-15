local MOD_DATA_KEY = DynamicTrading_Roster.MOD_DATA_KEY

local function isColonyRecruitmentAway(status, returnStatus, npcData)
    if status ~= "Away" then
        return false
    end

    if npcData and npcData.colonyRecruitmentPending == true then
        return true
    end

    if DTNPCManager and DTNPCManager.IsColonyRecruitmentReturnStatus then
        return DTNPCManager.IsColonyRecruitmentReturnStatus(returnStatus)
    end

    return tostring(returnStatus or "") == "ColonyRecruitment"
end

function DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
    local npcData = DynamicTrading_Roster.GetSoul(uuid)
    if npcData then
        local wasIncapacitated = npcData.incapState == "Active"
        local isRecruitmentAway = isColonyRecruitmentAway(status, returnStatus, npcData)
        if npcData.status == "Away" and status ~= "Away" then
            DynamicTrading.Log("DTCommons", "Roster", "Sync", "Resetting state and master for " .. (npcData.name or uuid) .. " on return.")
            if status == "Trading" then
                npcData.state = "Trading"
            elseif status == "Working" then
                npcData.state = "Guard"
            else
                npcData.state = "Idle"
            end

            npcData.master = nil
            npcData.masterID = nil
            npcData.requestedReturnStatus = nil
            npcData.departureTargetX = nil
            npcData.departureTargetY = nil
            npcData.departureTargetZ = nil
            npcData.departureTravelHours = nil

            if wasIncapacitated then
                npcData.incapState = nil
                npcData.preIncapStatus = nil
                npcData.incapStrugglePauseUntil = nil
                npcData.incapNextPauseAt = nil
                npcData.lastFleeX = nil
                npcData.lastFleeY = nil
            end
        end

        if status == "Away" and not isRecruitmentAway then
            npcData.state = "Idle"
            npcData.master = nil
            npcData.masterID = nil
            npcData.requestedReturnStatus = nil
            npcData.departureTargetX = nil
            npcData.departureTargetY = nil
            npcData.departureTargetZ = nil
            npcData.departureTravelHours = nil
            npcData.departureBlockedTicks = nil
            npcData.departureStuckLastX = nil
            npcData.departureStuckLastY = nil
            npcData.departureLastDirX = nil
            npcData.departureLastDirY = nil
            npcData.departureStartedAt = nil
            npcData.departureForceDespawnAt = nil
        end

        if status == "Dead" then
            npcData.incapState = nil
            npcData.preIncapStatus = nil
            npcData.incapStrugglePauseUntil = nil
            npcData.incapNextPauseAt = nil
        end

        if status ~= nil then npcData.status = status end
        if returnTime ~= nil then npcData.returnTime = returnTime end
        if returnStatus ~= nil then npcData.returnStatus = returnStatus end

        DynamicTrading_Roster.SaveSoul(uuid, npcData)

        if DynamicTrading_Stock and DynamicTrading_Stock.OnSoulStatusChanged then
            DynamicTrading_Stock.OnSoulStatusChanged(uuid, status)
        end
    end

    local data = ModData.get(MOD_DATA_KEY)
    if data.Souls[uuid] then
        local registry = data.Souls[uuid]
        registry.status = status
        registry.state = npcData and npcData.state or registry.state
        registry.incapState = npcData and npcData.incapState or registry.incapState
        registry.returnTime = returnTime
        registry.returnStatus = returnStatus
        registry.linkedWorkerID = npcData and npcData.linkedWorkerID or registry.linkedWorkerID
        registry.ownerUsername = npcData and npcData.ownerUsername or registry.ownerUsername
        registry.isPlayerFactionTrader = npcData and (npcData.isPlayerFactionTrader == true) or registry.isPlayerFactionTrader
    end

    local linkedWorkerID = (npcData and npcData.linkedWorkerID) or (data.Souls[uuid] and data.Souls[uuid].linkedWorkerID) or nil
    local factionID = (npcData and npcData.factionID) or (data.Souls[uuid] and data.Souls[uuid].factionID) or nil
    if linkedWorkerID and factionID and DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local faction = DynamicTrading_Factions.GetFaction(factionID)
        if faction and faction.playerOwned then
            local changed = false
            faction.activeTradeWorkerIDs = type(faction.activeTradeWorkerIDs) == "table" and faction.activeTradeWorkerIDs or {}
            faction.tradeEligibleWorkerIDs = type(faction.tradeEligibleWorkerIDs) == "table" and faction.tradeEligibleWorkerIDs or {}
            faction.tradeWorkerSouls = type(faction.tradeWorkerSouls) == "table" and faction.tradeWorkerSouls or {}

            local shouldBeActive = (status == "Away" or status == "Trading")
            if shouldBeActive then
                if faction.activeTradeWorkerIDs[linkedWorkerID] ~= true then
                    changed = true
                end
                faction.activeTradeWorkerIDs[linkedWorkerID] = true
                if faction.tradeWorkerSouls[linkedWorkerID] ~= uuid then
                    faction.tradeWorkerSouls[linkedWorkerID] = uuid
                    changed = true
                end
            else
                if faction.activeTradeWorkerIDs[linkedWorkerID] ~= nil then
                    faction.activeTradeWorkerIDs[linkedWorkerID] = nil
                    changed = true
                end
            end

            if status == "Dead" then
                if faction.tradeEligibleWorkerIDs[linkedWorkerID] ~= nil then
                    faction.tradeEligibleWorkerIDs[linkedWorkerID] = nil
                    changed = true
                end
                if faction.tradeWorkerSouls[linkedWorkerID] == uuid then
                    faction.tradeWorkerSouls[linkedWorkerID] = nil
                    changed = true
                end
            end

            if changed then
                ModData.transmit("DynamicTrading_Factions")
            end
        end
    end

    local colony = rawget(_G, "DC_Colony")
    local companion = colony and colony.Companion or nil
    if companion and companion.OnSoulStatusChanged then
        local soulSnapshot = npcData or (data.Souls and data.Souls[uuid]) or nil
        companion.OnSoulStatusChanged(uuid, status, soulSnapshot)
    end

    DynamicTrading.Log("DTCommons", "Roster", "Status", "Updated status for " .. uuid .. " to " .. (status or "nil") .. " (Return in: " .. tostring(returnTime) .. " as " .. tostring(returnStatus) .. ")")
end
