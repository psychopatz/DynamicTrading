local Internal = DT_TraderContacts.Internal

function Internal.GetRosterSource()
    if DT_V2_RadarManager and DT_V2_RadarManager.ClientRoster and type(DT_V2_RadarManager.ClientRoster.Souls) == "table" then
        return DT_V2_RadarManager.ClientRoster.Souls
    end

    local roster = ModData.get and ModData.get("DynamicTrading_Roster") or nil
    if roster and type(roster.Souls) == "table" then
        return roster.Souls
    end

    return nil
end

function DT_TraderContacts.GetRosterSoul(traderOrID)
    local traderID = traderOrID
    if type(traderOrID) == "table" then
        traderID = DT_TraderContacts.GetTraderID(traderOrID)
    end

    if not traderID then
        return nil
    end

    local souls = Internal.GetRosterSource()
    local soul = souls and souls[tostring(traderID)] or nil
    if type(soul) ~= "table" then
        return nil
    end

    return Internal.CloneContact(soul)
end

function DT_TraderContacts.RefreshContactData(contact)
    local normalized = DT_TraderContacts.NormalizeTrader(contact)
    if not normalized then
        return nil
    end

    local soul = DT_TraderContacts.GetRosterSoul(normalized.id)
    if soul then
        if soul.name ~= nil then normalized.name = soul.name end
        if soul.factionID ~= nil then normalized.factionID = soul.factionID end
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
    end

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

    if status == "Resting" then
        return "Status: Resting at base"
    end
    if status == "Trading" and visitActive and (visitMode == "Follow" or state == "Follow") then
        return "Status: Called in and following your lead"
    end
    if status == "Trading" and visitActive and (visitMode == "Guard" or state == "Guard") then
        return "Status: Called in and guarding nearby"
    end
    if status == "Trading" then
        return "Status: Trading in the field"
    end
    if status == "Away" and visitActive and returnStatus == "Trading" then
        return "Status: Moving toward your area"
    end
    if status == "Away" and returnStatus == "Trading" then
        return "Status: En route to trade"
    end
    if status == "Away" and returnStatus == "Resting" then
        return "Status: Returning home"
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

    local stayHours = SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingStayHours or 4.0
    hydrated.status = "Trading"
    hydrated.state = "Follow"
    hydrated.returnStatus = "Away"
    hydrated.returnTime = Internal.GetWorldAgeHours() + stayHours
    hydrated.contactVisitActive = true
    hydrated.contactVisitMode = "Follow"
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

    return true, hydrated, stayHours
end

function DT_TraderContacts.BuildConversationTarget(contact)
    local normalized = DT_TraderContacts.RefreshContactData(contact)
    if not normalized then
        return nil
    end

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