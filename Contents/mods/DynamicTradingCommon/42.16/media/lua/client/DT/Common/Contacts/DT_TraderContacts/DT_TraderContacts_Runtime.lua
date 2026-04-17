local Internal = DT_TraderContacts.Internal

function Internal.GetVisitWalkHours()
    return tonumber(SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0) or 1.0
end

function Internal.FormatCountdownFromHours(hoursRemaining)
    local hours = tonumber(hoursRemaining)
    if not hours or hours <= 0 then
        return "now"
    end

    local totalSeconds = math.max(1, math.floor(hours * 3600))
    local totalMinutes = math.floor(totalSeconds / 60)
    local remainingSeconds = totalSeconds % 60
    local wholeHours = math.floor(totalMinutes / 60)
    local remainingMinutes = totalMinutes % 60

    if wholeHours > 0 then
        return string.format("%dh %02dm", wholeHours, remainingMinutes)
    end
    if totalMinutes > 0 then
        return string.format("%dm %02ds", totalMinutes, remainingSeconds)
    end

    return string.format("%ds", totalSeconds)
end

function DT_TraderContacts.GetVisitArrivalTime(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    if not current or current.contactVisitActive ~= true then
        return nil
    end

    local startedAt = tonumber(current.contactVisitStartedAt)
    if not startedAt then
        return nil
    end

    return startedAt + Internal.GetVisitWalkHours()
end

function DT_TraderContacts.GetArrivalCountdownText(contact)
    local arrivalTime = DT_TraderContacts.GetVisitArrivalTime(contact)
    if not arrivalTime then
        return nil
    end

    local remainingHours = arrivalTime - Internal.GetWorldAgeHours()
    if remainingHours <= 0 then
        return nil
    end

    return Internal.FormatCountdownFromHours(remainingHours)
end

function Internal.GetRosterSources()
    local sources = {}

    if DT_V2_RadarManager and DT_V2_RadarManager.ClientRoster and type(DT_V2_RadarManager.ClientRoster.Souls) == "table" then
        sources[#sources + 1] = DT_V2_RadarManager.ClientRoster.Souls
    end

    local roster = ModData.get and ModData.get("DynamicTrading_Roster") or nil
    if roster and type(roster.Souls) == "table" then
        sources[#sources + 1] = roster.Souls
    end

    return sources
end

function DT_TraderContacts.GetRosterSoul(traderOrID)
    local traderID = traderOrID
    if type(traderOrID) == "table" then
        traderID = DT_TraderContacts.GetTraderID(traderOrID)
    end

    if not traderID then
        return nil
    end

    local sources = Internal.GetRosterSources()
    for _, souls in ipairs(sources) do
        local soul = souls and souls[tostring(traderID)] or nil
        if type(soul) == "table" then
            return Internal.CloneContact(soul)
        end
    end

    return nil
end

function DT_TraderContacts.RefreshContactData(contact)
    local normalized = DT_TraderContacts.NormalizeTrader(contact)
    if not normalized then
        return nil
    end

    local soul = DT_TraderContacts.GetRosterSoul(normalized.id)
    normalized.missingFromRoster = soul == nil
    normalized.factionMissing = DT_TraderContacts.Internal.IsFactionMissing and DT_TraderContacts.Internal.IsFactionMissing(normalized.factionID) or false

    if soul then
        if soul.name ~= nil then normalized.name = soul.name end
        if soul.factionID ~= nil then normalized.factionID = soul.factionID end
        if soul.factionName ~= nil then normalized.factionName = soul.factionName end
        if soul.archetypeID ~= nil then normalized.archetype = soul.archetypeID end
        if soul.isFemale ~= nil then normalized.gender = soul.isFemale and "Female" or "Male" end
        if soul.identitySeed ~= nil then normalized.identitySeed = soul.identitySeed end
        if soul.status ~= nil then normalized.status = soul.status end
        if soul.state ~= nil then normalized.state = soul.state end
        if soul.returnTime ~= nil then normalized.returnTime = soul.returnTime end
        if soul.returnStatus ~= nil then normalized.returnStatus = soul.returnStatus end
        if soul.lastX ~= nil then normalized.lastX = soul.lastX end
        if soul.lastY ~= nil then normalized.lastY = soul.lastY end
        if soul.lastZ ~= nil then normalized.lastZ = soul.lastZ end
        if soul.contactVisitActive ~= nil then normalized.contactVisitActive = soul.contactVisitActive end
        if soul.contactVisitMode ~= nil then normalized.contactVisitMode = soul.contactVisitMode end
        if soul.contactVisitRequestedBy ~= nil then normalized.contactVisitRequestedBy = soul.contactVisitRequestedBy end
        if soul.contactVisitRequestedByID ~= nil then normalized.contactVisitRequestedByID = soul.contactVisitRequestedByID end
        if soul.contactVisitTargetX ~= nil then normalized.contactVisitTargetX = soul.contactVisitTargetX end
        if soul.contactVisitTargetY ~= nil then normalized.contactVisitTargetY = soul.contactVisitTargetY end
        if soul.contactVisitTargetZ ~= nil then normalized.contactVisitTargetZ = soul.contactVisitTargetZ end
        if soul.contactVisitStartedAt ~= nil then normalized.contactVisitStartedAt = soul.contactVisitStartedAt end
        if soul.contactVisitReturnStatus ~= nil then normalized.contactVisitReturnStatus = soul.contactVisitReturnStatus end

        normalized.missingFromRoster = false
        normalized.factionMissing = DT_TraderContacts.Internal.IsFactionMissing and DT_TraderContacts.Internal.IsFactionMissing(normalized.factionID) or false
    end

    if normalized.missingFromRoster and normalized.factionMissing then
        normalized.status = "Dead"
        normalized.state = "Dead"
        normalized.returnTime = nil
        normalized.returnStatus = nil
        normalized.contactVisitActive = false
        normalized.contactVisitMode = nil
        normalized.contactVisitRequestedBy = nil
        normalized.contactVisitRequestedByID = nil
        normalized.contactVisitTargetX = nil
        normalized.contactVisitTargetY = nil
        normalized.contactVisitTargetZ = nil
        normalized.contactVisitStartedAt = nil
        normalized.contactVisitReturnStatus = nil
    elseif normalized.missingFromRoster and (normalized.status == nil or normalized.status == "" or normalized.status == "Unknown") then
        normalized.status = "Unavailable"
        normalized.state = normalized.state or "Unavailable"
    end

    if tostring(normalized.status or "") == "Dead" then
        normalized.state = "Dead"
        normalized.returnTime = nil
        normalized.returnStatus = nil
        normalized.contactVisitActive = false
        normalized.contactVisitMode = nil
        normalized.contactVisitRequestedBy = nil
        normalized.contactVisitRequestedByID = nil
        normalized.contactVisitTargetX = nil
        normalized.contactVisitTargetY = nil
        normalized.contactVisitTargetZ = nil
        normalized.contactVisitStartedAt = nil
        normalized.contactVisitReturnStatus = nil
    end

    normalized.factionName = DT_TraderContacts.GetFactionDisplayName(normalized)
    normalized.reputation = DT_TraderContacts.GetEffectiveReputation(normalized)
    return normalized
end

function DT_TraderContacts.GetStatusText(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    if not current then
        return "Status unknown"
    end

    local status = tostring(current.status or "Unknown")
    local state = tostring(current.state or "")
    local returnStatus = tostring(current.returnStatus or "")
    local visitMode = tostring(current.contactVisitMode or "")
    local visitActive = current.contactVisitActive == true
    local arrivalCountdown = DT_TraderContacts.GetArrivalCountdownText(current)

    if status == "Dead" then
        return "Status: Deceased"
    end
    if status == "Unavailable" or current.missingFromRoster == true then
        return "Contact unavailable"
    end

    if (status == "Unknown" or status == "") and visitActive and returnStatus == "Resting" then
        return "Status: Returning home"
    end
    if (status == "Unknown" or status == "") and visitActive and returnStatus == "Trading" then
        if arrivalCountdown then
            return string.format("Status: Moving toward your area (ETA %s)", arrivalCountdown)
        end
        return "Status: Moving toward your area"
    end
    if (status == "Unknown" or status == "") and visitMode == "Departure" then
        return "Status: Returning home"
    end

    if visitActive and arrivalCountdown and (status == "Away" or status == "Trading") then
        return string.format("Status: Moving toward your area (ETA %s)", arrivalCountdown)
    end

    if status == "Resting" then
        return "Resting at base"
    end
    if status == "Trading" and visitActive and (visitMode == "Follow" or state == "Follow") then
        return "Called in and following"
    end
    if status == "Trading" and visitActive and (visitMode == "Trading" or state == "Trading") then
        return "Called in and trading"
    end
    if status == "Trading" then
        return "Trading in the field"
    end
    if status == "Away" and visitActive and returnStatus == "Trading" then
        if arrivalCountdown then
            return string.format("Moving toward your area (ETA %s)", arrivalCountdown)
        end
        return "Moving toward your area"
    end
    if status == "Away" and returnStatus == "Trading" then
        return "En route to trade"
    end
    if status == "Away" and returnStatus == "Resting" then
        return "Returning home"
    end
    if state ~= "" then
        return "Status: " .. state
    end

    return "Status: " .. status
end

function DT_TraderContacts.CanRequestVisit(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    if not current then
        return false, "unknown", nil
    end

    if DT_TraderContacts.GetEffectiveReputation(current) < DT_TraderContacts.VISIT_REPUTATION_REQUIRED then
        return false, "rep", current
    end

    local soul = DT_TraderContacts.GetRosterSoul(current.id)
    if not soul then
        return false, "unsupported", current
    end

    if tostring(current.status or "") ~= "Resting" then
        return false, "state", current
    end

    return true, nil, current
end

function DT_TraderContacts.RequestVisit(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    local allowed, reason, hydrated = DT_TraderContacts.CanRequestVisit(current)
    if not allowed then
        return false, reason, hydrated
    end

    local player = Internal.GetLocalPlayer()
    if not player then
        return false, "player", hydrated
    end

    sendClientCommand(player, "DTNPC", "RequestTraderVisit", {
        uuid = hydrated.id,
        x = math.floor(player:getX()),
        y = math.floor(player:getY()),
        z = math.floor(player:getZ()),
    })

    if DT_Reputation and DT_Reputation.ModifyPersonalRep then
        DT_Reputation.ModifyPersonalRep(hydrated.id, hydrated.factionID, -DT_TraderContacts.VISIT_REPUTATION_COST, "contact_visit_request")
    end

    local walkHours = Internal.GetVisitWalkHours()
    local stayHours = SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingStayHours or 4.0
    hydrated.status = "Away"
    hydrated.state = "Departure"
    hydrated.returnStatus = "Trading"
    hydrated.returnTime = Internal.GetWorldAgeHours() + walkHours
    hydrated.contactVisitActive = true
    hydrated.contactVisitMode = "Departure"
    hydrated.contactVisitRequestedBy = player.getUsername and player:getUsername() or nil
    hydrated.contactVisitRequestedByID = player.getOnlineID and player:getOnlineID() or nil
    hydrated.contactVisitTargetX = math.floor(player:getX())
    hydrated.contactVisitTargetY = math.floor(player:getY())
    hydrated.contactVisitTargetZ = math.floor(player:getZ())
    hydrated.contactVisitStartedAt = Internal.GetWorldAgeHours()
    hydrated.contactVisitReturnStatus = "Resting"
    hydrated.reputation = DT_TraderContacts.GetEffectiveReputation(hydrated)

    DT_TraderContacts.SaveContact(hydrated)
    if DT_V2_RadarManager and DT_V2_RadarManager.RequestRoster then
        DT_V2_RadarManager.RequestRoster()
    end

    return true, hydrated, walkHours, stayHours
end

function DT_TraderContacts.BuildConversationTarget(contact)
    local normalized = DT_TraderContacts.RefreshContactData(contact)
    if not normalized then
        return nil
    end

    normalized.factionName = DT_TraderContacts.GetFactionDisplayName(normalized)
    normalized.returnTime = nil
    normalized.reputation = DT_TraderContacts.GetEffectiveReputation(normalized)
    normalized.isContactConversation = true
    return normalized
end

function DT_TraderContacts.FormatContactSummary(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    if not current then
        return "Unknown contact"
    end

    local rep = DT_TraderContacts.GetEffectiveReputation(current)
    local role = tostring(current.archetype or current.role or "Survivor")
    return string.format("%s  |  %s  |  Rep %d", tostring(current.name or "Unknown"), role, rep)
end