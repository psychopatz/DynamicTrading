local Internal = DT_TraderContacts.Internal

local MISSING_CONTACT_DEATH_FLAVORS = {
    "bled out after a roadside ambush",
    "was dragged down by the dead on a supply run",
    "never made it back from a bad trade route",
    "was found dead after a raider hit",
    "disappeared in the fog and turned up dead days later",
    "was torn apart while trying to break through a horde",
    "caught a bullet in a scavenger crossfire",
    "was killed while fleeing a collapsed safehouse",
}

local function hashText(value)
    local text = tostring(value or "")
    local hash = 0
    for index = 1, #text do
        hash = (hash * 33 + string.byte(text, index)) % 2147483647
    end
    return hash
end

local function cloneDeathFlavor(contact)
    if not contact then
        return nil
    end

    local flavor = tostring(contact.deathFlavorText or "")
    if flavor ~= "" then
        return flavor
    end

    local seed = table.concat({
        tostring(contact.id or contact.uuid or contact.traderID or "unknown"),
        tostring(contact.factionID or "nofaction"),
        tostring(contact.name or "noname"),
    }, "|")
    local index = (hashText(seed) % #MISSING_CONTACT_DEATH_FLAVORS) + 1
    return MISSING_CONTACT_DEATH_FLAVORS[index]
end

local function clearTransientVisitState(normalized)
    normalized.returnTime = nil
    normalized.returnStatus = nil
    normalized.contactVisitActive = false
    normalized.contactVisitMode = nil
    normalized.contactVisitBackend = nil
    normalized.contactVisitRequestedBy = nil
    normalized.contactVisitRequestedByID = nil
    normalized.contactVisitTargetX = nil
    normalized.contactVisitTargetY = nil
    normalized.contactVisitTargetZ = nil
    normalized.contactVisitStartedAt = nil
    normalized.contactVisitReturnStatus = nil
end

local function markTraderDead(normalized, deathReason, deathFlavorText)
    normalized.status = "Dead"
    normalized.state = "Dead"
    normalized.deathReason = deathReason
    normalized.deathFlavorText = deathFlavorText
    clearTransientVisitState(normalized)
end

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

function Internal.GetRosterSourcesForBackend(backend)
    local resolved = string.upper(tostring(backend or ""))
    local sources = {}

    if resolved == "V1" then
        local roster = ModData.get and ModData.get("DynamicTrading_Roster") or nil
        if roster and type(roster.Souls) == "table" then
            sources[#sources + 1] = roster.Souls
        end
        return sources
    end

    if resolved == "V2" then
        if DT_V2_RadarManager and DT_V2_RadarManager.ClientRoster and type(DT_V2_RadarManager.ClientRoster.Souls) == "table" then
            sources[#sources + 1] = DT_V2_RadarManager.ClientRoster.Souls
        end

        local roster = ModData.get and ModData.get("DynamicTrading_Roster") or nil
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
        return "V1"
    end

    return "V2"
end

function Internal.RequestVisitStateRefresh(player, backend)
    if backend == "V1" then
        sendClientCommand(player, "DynamicTrading", "RequestFullState", {})
    end

    if backend ~= "V1" and DT_V2_RadarManager and DT_V2_RadarManager.RequestRoster then
        DT_V2_RadarManager.RequestRoster()
    end
end

function DT_TraderContacts.GetRosterSoul(traderOrID, options)
    local traderID = traderOrID
    if type(traderOrID) == "table" then
        traderID = DT_TraderContacts.GetTraderID(traderOrID)
    end

    if not traderID then
        return nil
    end

    options = options or {}
    local backend = Internal.ResolveVisitBackend(type(traderOrID) == "table" and traderOrID or nil, options)

    if backend == "V1" and DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry then
        local registrySoul = DynamicTrading_Roster.GetSoulRegistry(tostring(traderID))
        if type(registrySoul) == "table" then
            return Internal.CloneContact(registrySoul)
        end
    end

    local sources = Internal.GetRosterSourcesForBackend(backend)
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

    local soul = DT_TraderContacts.GetRosterSoul(normalized.id, {
        requestBackend = normalized.contactVisitBackend,
    })
    normalized.missingFromRoster = soul == nil
    normalized.factionMissing = DT_TraderContacts.Internal.IsFactionMissing and DT_TraderContacts.Internal.IsFactionMissing(normalized.factionID) or false
    normalized.deathReason = normalized.deathReason
    normalized.deathFlavorText = normalized.deathFlavorText

    local factionData = DT_TraderContacts.Internal.GetFactionData and DT_TraderContacts.Internal.GetFactionData(normalized.factionID) or nil
    local factionState = tostring(factionData and factionData.state or "")

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
        if soul.contactVisitBackend ~= nil then normalized.contactVisitBackend = soul.contactVisitBackend end
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
        markTraderDead(normalized, "WipedOut", "faction wiped out")
    elseif normalized.missingFromRoster and factionState == "Starving" then
        markTraderDead(normalized, "Starvation", "lost to starvation")
    elseif normalized.missingFromRoster then
        local listedInFaction = DT_TraderContacts.Internal.IsTraderListedInFaction
            and DT_TraderContacts.Internal.IsTraderListedInFaction(normalized.id, normalized.factionID)
            or false
        local deathReason = listedInFaction and "MissingFromRoster" or "MissingFromFaction"
        markTraderDead(normalized, deathReason, cloneDeathFlavor(normalized))
    end

    if tostring(normalized.status or "") == "Dead" then
        normalized.state = "Dead"
        clearTransientVisitState(normalized)
        if not normalized.deathFlavorText or normalized.deathFlavorText == "" then
            if tostring(normalized.deathReason or "") == "Starvation" then
                normalized.deathFlavorText = "lost to starvation"
            elseif tostring(normalized.deathReason or "") == "WipedOut" then
                normalized.deathFlavorText = "faction wiped out"
            else
                normalized.deathFlavorText = cloneDeathFlavor(normalized)
            end
        end
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
        local deathFlavorText = tostring(current.deathFlavorText or "")
        if deathFlavorText ~= "" then
            return "Status: Deceased (" .. deathFlavorText .. ")"
        end
        return "Status: Deceased"
    end
    if status == "Unavailable" or current.missingFromRoster == true then
        return "Status: Deceased"
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

function DT_TraderContacts.CanRequestVisit(contact, options)
    options = options or {}
    local current = DT_TraderContacts.RefreshContactData(contact)
    if not current then
        if options.logCheck == true then
            DynamicTrading.Log("DTContacts", "Visit", "Warn", "CanRequestVisit failed: contact could not be refreshed")
        end
        return false, "unknown", nil
    end

    local backend = Internal.ResolveVisitBackend(current, options)

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

    local soul = DT_TraderContacts.GetRosterSoul(current.id, options)
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
    local allowed, reason, hydrated = DT_TraderContacts.CanRequestVisit(current, {
        requestBackend = backend,
        radioObj = options and options.radioObj or nil,
        logCheck = true,
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

    local player = Internal.GetLocalPlayer()
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

    local requestArgs = {
        uuid = hydrated.id,
        x = math.floor(player:getX()),
        y = math.floor(player:getY()),
        z = math.floor(player:getZ()),
        requestBackend = backend,
    }

    if backend == "V1" then
        sendClientCommand(player, "DynamicTrading", "RequestTraderVisit", requestArgs)
    else
        sendClientCommand(player, "DTNPC", "RequestTraderVisit", requestArgs)
    end

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