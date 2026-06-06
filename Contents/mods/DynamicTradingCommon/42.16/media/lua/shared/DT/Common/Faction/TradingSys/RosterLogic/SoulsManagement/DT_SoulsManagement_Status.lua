local MOD_DATA_KEY = DynamicTrading_Roster.MOD_DATA_KEY

local function clearTradeCycleEncounterFields(npcData, registry)
    local target = npcData or registry
    if type(target) ~= "table" then
        return
    end

    target.tradeCycleMode = nil
    target.tradeCycleDemandEligible = nil
    target.tradeCycleAggroRadius = nil
    target.tradeCycleTargetPlayerUsername = nil
    target.tradeCycleTargetPlayerOnlineID = nil
end

local function clearBanditHouseRoamFields(npcData, registry)
    local target = npcData or registry
    if type(target) ~= "table" then
        return
    end

    target.banditRoamActive = nil
    target.banditRoamSite = nil
    target.banditRoamStartedAt = nil
    target.banditRoamEndsAt = nil
    target.banditRoamReturnStatus = nil
    target.banditRoamEncounterMode = nil
    target.banditRoamAggroRadius = nil
end

local function copyEncounterField(registry, npcData, fieldName)
    if type(registry) ~= "table" or fieldName == nil then
        return
    end
    if npcData ~= nil then
        registry[fieldName] = npcData[fieldName]
    end
end

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

local function isLivingSoulRecord(soul)
    if type(soul) ~= "table" then
        return false
    end

    local status = tostring(soul.status or "")
    local state = tostring(soul.state or "")
    if status == "Dead" or state == "Dead" or tonumber(soul.deathFinalizedAt) then
        return false
    end

    local combatHealth = tonumber(soul.combatHealthCurrent)
    if combatHealth ~= nil and combatHealth <= 0 and status ~= "Away" and status ~= "Trading" then
        return false
    end

    local health = tonumber(soul.health)
    if health ~= nil and health <= 0 and status ~= "Away" and status ~= "Trading" then
        return false
    end

    return true
end

local function refreshNonPlayerFactionPopulationFromRoster(factionID, data)
    if not factionID or not DynamicTrading_Factions or not DynamicTrading_Factions.GetFaction then
        return false
    end

    local faction = DynamicTrading_Factions.GetFaction(factionID)
    if not faction or faction.playerOwned == true then
        return false
    end

    local members = data and data.FactionMembers and data.FactionMembers[factionID] or nil
    local souls = data and data.Souls or nil
    local living = 0
    local dead = 0
    local index

    if type(members) == "table" and type(souls) == "table" then
        for index = 1, #members do
            local soul = souls[members[index]]
            if type(soul) == "table" then
                if isLivingSoulRecord(soul) then
                    living = living + 1
                else
                    dead = dead + 1
                end
            end
        end
    end

    local changed = false
    if tonumber(faction.memberCount) ~= living then
        faction.memberCount = living
        changed = true
    end

    if living <= 0
        and (dead > 0 or (type(members) == "table" and #members <= 0))
        and DynamicTrading_Factions.AuditFactionExtinction then
        if DynamicTrading_Factions.AuditFactionExtinction(factionID, { reason = "roster_extinction" }) then
            changed = true
        end
    end

    if changed and ModData and ModData.transmit then
        ModData.transmit("DynamicTrading_Factions")
    end

    return changed
end

function DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
    local npcData = DynamicTrading_Roster.GetSoul(uuid)
    if npcData then
        local wasIncapacitated = npcData.incapState == "Active"
        local isRecruitmentAway = isColonyRecruitmentAway(status, returnStatus, npcData)
        if npcData.status == "Away" and status ~= "Away" then
            DynamicTrading.Log("DTCommons", "Roster", "Sync", "Resetting state and master for " .. (npcData.name or uuid) .. " on return.")
            if status == "Trading" and npcData.banditRoamActive == true then
                npcData.state = "Stay"
            elseif status == "Trading" then
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
            npcData.currentBodyInstanceID = nil
            npcData.startupBodyInstanceHint = nil
        end

        if status == "Dead" then
            if DTNPCHealth and DTNPCHealth.Internal and DTNPCHealth.Internal.markTerminalDeathState then
                DTNPCHealth.Internal.markTerminalDeathState(npcData)
            else
                npcData.status = "Dead"
                npcData.state = "Dead"
                npcData.incapState = nil
                npcData.healthState = nil
                npcData.reviveData = nil
                npcData.preIncapStatus = nil
                npcData.incapStrugglePauseUntil = nil
                npcData.incapNextPauseAt = nil
                npcData.health = 0
                npcData.lastHealth = 0
                if type(npcData.combatHealth) == "table" then
                    npcData.combatHealth.current = 0
                    npcData.combatHealth.enabled = false
                    npcData.combatHealth.engineProtected = false
                    npcData.combatHealth.incapGraceUntil = 0
                    npcData.combatHealth.lastEngineHealth = 0
                end
            end
        end

        if status == "Dead" or (status ~= "Away" and status ~= "Trading") then
            clearTradeCycleEncounterFields(npcData, nil)
            clearBanditHouseRoamFields(npcData, nil)
        end

        if status ~= nil then npcData.status = status end
        if returnTime ~= nil then npcData.returnTime = returnTime end
        if returnStatus ~= nil then npcData.returnStatus = returnStatus end

        if DTNPCManager and DTNPCManager.EnsurePresenceRevision then
            DTNPCManager.EnsurePresenceRevision(npcData)
        end

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
        registry.health = npcData and ((npcData.combatHealth and npcData.combatHealth.current) or npcData.health) or registry.health
        registry.combatHealthCurrent = npcData and npcData.combatHealth and npcData.combatHealth.current or registry.combatHealthCurrent
        registry.returnTime = returnTime
        registry.returnStatus = returnStatus
        registry.presenceRevision = npcData and npcData.presenceRevision or registry.presenceRevision
        registry.linkedWorkerID = npcData and npcData.linkedWorkerID or registry.linkedWorkerID
        registry.ownerUsername = npcData and npcData.ownerUsername or registry.ownerUsername
        registry.isPlayerFactionTrader = npcData and (npcData.isPlayerFactionTrader == true) or registry.isPlayerFactionTrader
        copyEncounterField(registry, npcData, "tradeCycleMode")
        copyEncounterField(registry, npcData, "tradeCycleDemandEligible")
        copyEncounterField(registry, npcData, "tradeCycleAggroRadius")
        copyEncounterField(registry, npcData, "tradeCycleTargetPlayerUsername")
        copyEncounterField(registry, npcData, "tradeCycleTargetPlayerOnlineID")
        copyEncounterField(registry, npcData, "banditRoamActive")
        copyEncounterField(registry, npcData, "banditRoamSite")
        copyEncounterField(registry, npcData, "banditRoamStartedAt")
        copyEncounterField(registry, npcData, "banditRoamEndsAt")
        copyEncounterField(registry, npcData, "banditRoamReturnStatus")
        copyEncounterField(registry, npcData, "banditRoamEncounterMode")
        copyEncounterField(registry, npcData, "banditRoamAggroRadius")
        if status == "Dead" or (status ~= "Away" and status ~= "Trading") then
            clearTradeCycleEncounterFields(nil, registry)
            clearBanditHouseRoamFields(nil, registry)
        end
    end

    local linkedWorkerID = (npcData and npcData.linkedWorkerID) or (data.Souls[uuid] and data.Souls[uuid].linkedWorkerID) or nil
    local factionID = (npcData and npcData.factionID) or (data.Souls[uuid] and data.Souls[uuid].factionID) or nil
    if factionID then
        refreshNonPlayerFactionPopulationFromRoster(factionID, data)
    end
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
