local Internal = DT_TraderContacts.Internal

function DT_TraderContacts.CanRequestVisit(contact, options)
    local current
    local backend
    local soul

    options = options or {}
    current = DT_TraderContacts.RefreshContactData(contact)
    if not current then
        if options.logCheck == true then
            DynamicTrading.Log("DTContacts", "Visit", "Warn", "CanRequestVisit failed: contact could not be refreshed")
        end
        return false, "unknown", nil
    end

    backend = Internal.ResolveVisitBackend(current, options)

    if DT_TraderContacts.GetEffectiveReputation(current) < DT_TraderContacts.VISIT_REPUTATION_REQUIRED then
        if options.logCheck == true then
            DynamicTrading.Log(
                "DTContacts",
                "Visit",
                "Debug",
                "CanRequestVisit denied (rep) id=" .. tostring(current.id)
                    .. " backend=" .. tostring(backend)
                    .. " rep=" .. tostring(DT_TraderContacts.GetEffectiveReputation(current))
            )
        end
        return false, "rep", current
    end

    soul = DT_TraderContacts.GetRosterSoul(current.id, options)
    if not soul then
        if options.logCheck == true then
            DynamicTrading.Log(
                "DTContacts",
                "Visit",
                "Warn",
                "CanRequestVisit denied (unsupported) id=" .. tostring(current.id)
                    .. " backend=" .. tostring(backend)
                    .. " missingRoster=true"
            )
        end
        return false, "unsupported", current
    end

    if tostring(current.status or "") ~= "Resting" then
        if options.logCheck == true then
            DynamicTrading.Log(
                "DTContacts",
                "Visit",
                "Debug",
                "CanRequestVisit denied (state) id=" .. tostring(current.id)
                    .. " backend=" .. tostring(backend)
                    .. " status=" .. tostring(current.status)
                    .. " state=" .. tostring(current.state)
            )
        end
        return false, "state", current
    end

    if options.logCheck == true then
        DynamicTrading.Log(
            "DTContacts",
            "Visit",
            "Debug",
            "CanRequestVisit allowed id=" .. tostring(current.id)
                .. " backend=" .. tostring(backend)
                .. " status=" .. tostring(current.status)
        )
    end

    return true, nil, current
end

function DT_TraderContacts.RequestVisit(contact, options)
    local current = DT_TraderContacts.RefreshContactData(contact)
    local backend = Internal.ResolveVisitBackend(current, options)
    local allowed
    local reason
    local hydrated
    local player
    local requestArgs
    local walkHours
    local stayHours

    allowed, reason, hydrated = DT_TraderContacts.CanRequestVisit(current, {
        requestBackend = backend,
        radioObj = options and options.radioObj or nil,
        logCheck = true
    })
    if not allowed then
        DynamicTrading.Log(
            "DTContacts",
            "Visit",
            "Warn",
            "RequestVisit aborted id=" .. tostring(current and current.id or "unknown")
                .. " backend=" .. tostring(backend)
                .. " reason=" .. tostring(reason)
        )
        return false, reason, hydrated
    end

    options = options or {}
    player = Internal.GetLocalPlayer()
    if not player then
        DynamicTrading.Log("DTContacts", "Visit", "Warn", "RequestVisit failed: local player unavailable")
        return false, "player", hydrated
    end

    DynamicTrading.Log(
        "DTContacts",
        "Visit",
        "Info",
        "Dispatching RequestTraderVisit id=" .. tostring(hydrated.id)
            .. " backend=" .. tostring(backend)
            .. " player=" .. tostring(player.getUsername and player:getUsername() or "local")
            .. " target=" .. tostring(math.floor(player:getX())) .. "," .. tostring(math.floor(player:getY())) .. "," .. tostring(math.floor(player:getZ()))
    )

    requestArgs = {
        uuid = hydrated.id,
        x = math.floor(player:getX()),
        y = math.floor(player:getY()),
        z = math.floor(player:getZ()),
        requestBackend = backend
    }

    if backend == "DynamicTradingV1" or backend == "V1" then
        sendClientCommand(player, "DynamicTrading", "RequestTraderVisit", requestArgs)
    else
        sendClientCommand(player, "DTNPC", "RequestTraderVisit", requestArgs)
    end

    if DT_Reputation and DT_Reputation.ModifyPersonalRep then
        DT_Reputation.ModifyPersonalRep(hydrated.id, hydrated.factionID, -DT_TraderContacts.VISIT_REPUTATION_COST, "contact_visit_request")
    end

    walkHours = Internal.GetVisitWalkHours()
    stayHours = SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingStayHours or 4.0
    hydrated.status = "Away"
    hydrated.state = "Departure"
    hydrated.returnStatus = "Trading"
    hydrated.returnTime = Internal.GetWorldAgeHours() + walkHours
    hydrated.contactVisitActive = true
    hydrated.contactVisitMode = "Departure"
    hydrated.contactVisitBackend = backend
    hydrated.contactVisitRequestedBy = player.getUsername and player:getUsername() or nil
    hydrated.contactVisitRequestedByID = player.getOnlineID and player:getOnlineID() or nil
    hydrated.contactVisitTargetX = math.floor(player:getX())
    hydrated.contactVisitTargetY = math.floor(player:getY())
    hydrated.contactVisitTargetZ = math.floor(player:getZ())
    hydrated.contactVisitStartedAt = Internal.GetWorldAgeHours()
    hydrated.contactVisitReturnStatus = "Resting"
    hydrated.reputation = DT_TraderContacts.GetEffectiveReputation(hydrated)

    DT_TraderContacts.SaveContact(hydrated)
    Internal.RequestVisitStateRefresh(player, backend)

    return true, hydrated, walkHours, stayHours
end
