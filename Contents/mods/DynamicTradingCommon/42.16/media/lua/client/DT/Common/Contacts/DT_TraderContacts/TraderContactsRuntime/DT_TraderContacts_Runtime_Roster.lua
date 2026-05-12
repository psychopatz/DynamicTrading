local Internal = DT_TraderContacts.Internal

function Internal.GetRosterSources()
    local sources = {}
    local roster

    if DT_V2_RadarManager and DT_V2_RadarManager.ClientRoster and type(DT_V2_RadarManager.ClientRoster.Souls) == "table" then
        sources[#sources + 1] = DT_V2_RadarManager.ClientRoster.Souls
    end

    roster = ModData.get and ModData.get("DynamicTrading_Roster") or nil
    if roster and type(roster.Souls) == "table" then
        sources[#sources + 1] = roster.Souls
    end

    return sources
end

function Internal.GetRosterSourcesForBackend(backend)
    local resolved = string.upper(tostring(backend or ""))
    local sources = {}
    local roster

    if resolved == "DYNAMICTRADINGV1" or resolved == "V1" then
        roster = ModData.get and ModData.get("DynamicTrading_Roster") or nil
        if roster and type(roster.Souls) == "table" then
            sources[#sources + 1] = roster.Souls
        end
        return sources
    end

    if resolved == "DYNAMICTRADINGV2" or resolved == "V2" then
        if DT_V2_RadarManager and DT_V2_RadarManager.ClientRoster and type(DT_V2_RadarManager.ClientRoster.Souls) == "table" then
            sources[#sources + 1] = DT_V2_RadarManager.ClientRoster.Souls
        end

        roster = ModData.get and ModData.get("DynamicTrading_Roster") or nil
        if roster and type(roster.Souls) == "table" then
            sources[#sources + 1] = roster.Souls
        end
        return sources
    end

    return Internal.GetRosterSources()
end

function Internal.ResolveVisitBackend(contact, options)
    options = options or {}

    local explicit = tostring(options.requestBackend or "")
    if explicit ~= "" then
        return string.upper(explicit)
    end

    if type(contact) == "table" then
        local isActiveVisit = contact.contactVisitActive == true
        local current = tostring(contact.contactVisitBackend or contact.requestBackend or "")
        if isActiveVisit and current ~= "" then
            return string.upper(current)
        end
    end

    if options.radioObj then
        return "DynamicTradingV1"
    end

    return "DynamicTradingV2"
end

function Internal.RequestVisitStateRefresh(player, backend)
    if backend == "DynamicTradingV1" or backend == "V1" then
        sendClientCommand(player, "DynamicTrading", "RequestFullState", {})
    end

    if backend ~= "DynamicTradingV1" and backend ~= "V1" and DT_V2_RadarManager and DT_V2_RadarManager.RequestRoster then
        DT_V2_RadarManager.RequestRoster()
    end
end

function DT_TraderContacts.GetRosterSoul(traderOrID, options)
    local traderID = traderOrID
    local backend
    local registrySoul
    local sources
    local sourceIndex
    local souls
    local soul

    if type(traderOrID) == "table" then
        traderID = DT_TraderContacts.GetTraderID(traderOrID)
    end

    if not traderID then
        return nil
    end

    options = options or {}
    backend = Internal.ResolveVisitBackend(type(traderOrID) == "table" and traderOrID or nil, options)

    if (backend == "DynamicTradingV1" or backend == "V1") and DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry then
        registrySoul = DynamicTrading_Roster.GetSoulRegistry(tostring(traderID))
        if type(registrySoul) == "table" then
            return Internal.CloneContact(registrySoul)
        end
    end

    sources = Internal.GetRosterSourcesForBackend(backend)
    for sourceIndex = 1, #sources do
        souls = sources[sourceIndex]
        soul = souls and souls[tostring(traderID)] or nil
        if type(soul) == "table" then
            return Internal.CloneContact(soul)
        end
    end

    return nil
end
