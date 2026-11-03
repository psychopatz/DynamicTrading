if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

-- Resident-trader Hoomans excursion adapter.
-- DTCommon owns destination intent and all commercial location/arrival state.
-- Hoomans owns participant travel, safety, visit timing, and exact-home return.

DTHoomans = DTHoomans or {}
DTHoomans.ResidentExcursion = DTHoomans.ResidentExcursion or {}

local Resident = DTHoomans.ResidentExcursion
local Settlement = DTHoomans.Settlement
local TraderService = DTCommon and DTCommon.TraderService
local Policy = DTCommon and DTCommon.CoreActorPolicy
local TraderWorld = DTCommon and DTCommon.TraderWorld
    or require "DTCommon/DTCommon_TraderWorld"
local WorldProvider = DTHoomans.TraderWorldProvider

local POLICY_ID = "dynamic_trading_resident_commercial"
local PURPOSE = "commercial_run"
local PUBLIC_REASON = "trading run"
local VISIT_INTENT = "commercial"
local MIN_BUDGET = 50
local MIN_OPPORTUNITY_SCORE = 1
local COOLDOWN_HOURS = 48

local function authority()
    return DTCommon and DTCommon.Storage
        and type(DTCommon.Storage.IsAuthority) == "function"
        and DTCommon.Storage.IsAuthority() == true
end

local function worldAge(value)
    value = tonumber(value)
    if value then return math.max(0, value) end
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and type(gameTime.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(gameTime:getWorldAgeHours()) or 0)
    end
    return 0
end

local function log(level, message)
    print("[DT][" .. tostring(level) .. "] " .. tostring(message))
end

local function recordForFaction(factionID)
    local traderID = Settlement and Settlement.TraderIDForFaction
        and Settlement.TraderIDForFaction(factionID) or nil
    local record = traderID and TraderService
        and TraderService.GetRecord and TraderService.GetRecord(traderID)
        or nil
    return traderID, record
end

local function homeCommunity(factionID)
    if not Settlement
        or type(Settlement.ActiveCommunityForFaction) ~= "function"
    then
        return nil
    end
    return Settlement.ActiveCommunityForFaction(factionID)
end

local function recentlyVisited(record, at)
    local policy = Policy and Policy.Get and Policy.Get(record) or {}
    local lastAt = tonumber(policy.lastVisitAt) or 0
    return lastAt > 0 and at < lastAt + COOLDOWN_HOURS
end

local function residentPolicy(faction, at)
    local community
    local traderID
    local record
    local policy
    local excursionService = PNC and PNC.CommunityExcursionService or nil
    local selectedSettlement
    local selectedTarget
    local reason
    local participantID
    local canDepart

    if not authority() or type(faction) ~= "table"
        or not TraderWorld or not WorldProvider
    then
        return nil
    end
    community = homeCommunity(faction.id)
    if not community or community.status ~= "active" then return nil end

    traderID, record = recordForFaction(faction.id)
    if not traderID or not record then
        if Settlement and type(Settlement.EnsureTraderForFaction) == "function"
        then
            local bound = Settlement.EnsureTraderForFaction(faction.id)
            if not bound then return nil end
            traderID, record = recordForFaction(faction.id)
        end
    end
    if not record then return nil end

    policy = Policy and Policy.Get and Policy.Get(record) or nil
    if not policy or policy.homeSettlementID ~= community.id
        or policy.currentSettlementID ~= community.id
        or policy.available ~= true
    then
        return nil
    end
    if recentlyVisited(record, at) then return nil end
    if tonumber(record.b) < MIN_BUDGET or record.i == nil then return nil end

    participantID = record.p or record.l
    if not participantID then return nil end

    if excursionService and type(excursionService.Get) == "function" then
        local existing = excursionService.Get(faction.id)
        if existing and existing.state ~= "AT_HOME"
            and existing.state ~= "FAILED"
        then
            return nil
        end
        if existing and existing.state == "FAILED"
            and existing.failure
            and (tonumber(existing.failure.retryAt) or 0) > at
        then
            return nil
        end
    end

    selectedSettlement, reason = TraderWorld.SelectDestination(
        traderID,
        community.id,
        at,
        { minScore = MIN_OPPORTUNITY_SCORE }
    )
    if not selectedSettlement then return nil, reason end

    selectedTarget, reason = WorldProvider.ResolveSettlementTarget(
        record, selectedSettlement.settlementID)
    if not selectedTarget then return nil, reason end

    if excursionService
        and type(excursionService.CanParticipantDepartForCommunity)
            == "function"
    then
        canDepart, reason = excursionService.CanParticipantDepartForCommunity(
            faction.id, participantID, community.id)
        if not canDepart then return nil, reason end
    end

    return {
        start = true,
        homeFactionID = faction.id,
        homeCommunityID = community.id,
        participants = { participantID },
        purpose = PURPOSE,
        publicReason = PUBLIC_REASON,
        visitIntent = VISIT_INTENT,
        destination = selectedTarget,
        itinerary = { selectedTarget },
        expectedReturnAt = at + 12,
        traderID = traderID,
        reason = reason or "dtcommon_destination_selected",
    }
end

local function updateState(traderID, spec)
    if not TraderWorld
        or type(TraderWorld.UpdateExternalState) ~= "function"
    then
        return false, "trader_world_unavailable"
    end
    return TraderWorld.UpdateExternalState(traderID, spec)
end

local function excursionJourneyID(payload, suffix)
    local id = "dt_excursion:" .. tostring(payload and payload.id or "unknown")
    if suffix then id = id .. ":" .. tostring(suffix) end
    return id
end

local function onExcursion(payload)
    local traderID
    local record
    local destination
    local result
    local reason
    if type(payload) ~= "table" then
        return false, "excursion_payload_missing"
    end
    if payload.purpose ~= PURPOSE then return true end

    traderID, record = recordForFaction(payload.factionID)
    if not traderID or not record then
        return false, "resident_trader_missing"
    end

    local now = payload.stateAt or worldAge()
    local destinationID = payload.destination
        and payload.destination.communityID or nil

    if payload.state == "PREPARING" then
        return updateState(traderID, {
            currentProvided = true,
            currentSettlementID = payload.homeCommunityID,
            originProvided = true,
            originSettlementID = payload.homeCommunityID,
            destinationProvided = true,
            destinationSettlementID = destinationID,
            lifecycleState = "preparing",
            journeyID = excursionJourneyID(payload),
            journeyState = "planned",
        })
    end

    if payload.state == "OUTBOUND" then
        if not destinationID then return false, "outbound_destination_missing" end
        return TraderWorld.BeginExternalJourney(
            traderID, destinationID, {
                now = now,
                originSettlementID = payload.homeCommunityID,
                journeyID = excursionJourneyID(payload),
                worldRole = "resident",
                lifecycleState = "traveling",
                journeyState = "outbound",
                validatedDestination = true,
                available = false,
                availabilityReason = "community_excursion_outbound",
            })
    end

    if payload.state == "RETURNING_HOME" then
        local visited = payload.visitedCommunityID
            or destinationID
            or (record.ca and record.ca.lastSettlementID)
        if not payload.homeCommunityID then
            return false, "home_settlement_missing"
        end
        return TraderWorld.BeginExternalJourney(
            traderID, payload.homeCommunityID, {
                now = now,
                originSettlementID = visited,
                journeyID = excursionJourneyID(payload, "return"),
                worldRole = "resident",
                lifecycleState = "returning",
                journeyState = "returning_home",
                validatedDestination = true,
                available = false,
                availabilityReason = "community_excursion_returning_home",
            })
    end

    if payload.state == "VISITING" then
        destination = destinationID
        if not destination then return false, "visit_destination_missing" end
        result, reason = Settlement.MarkTraderVisit(
            traderID,
            destination,
            {
                visitID = "dt_excursion:" .. tostring(payload.id)
                    .. ":" .. tostring(destination),
                journeyID = excursionJourneyID(payload),
                now = payload.visitedAt or now,
                available = false,
                exchange = true,
                cooldownHours = COOLDOWN_HOURS,
            }
        )
        if not result and reason ~= "duplicate_visit" then
            log("WARN", "resident_excursion_exchange_failed trader="
                .. tostring(traderID) .. " reason=" .. tostring(reason))
            return false, reason
        end

        local nextDest = payload.nextDestination
            and payload.nextDestination.communityID or nil
        local updated, updateReason = updateState(traderID, {
            currentProvided = true,
            currentSettlementID = destination,
            destinationProvided = true,
            destinationSettlementID = nextDest,
            lifecycleState = "visiting",
            journeyState = "arrived",
            available = false,
            availabilityReason = "resident_trader_visiting",
        })
        if not updated then return false, updateReason end
        return true, reason
    end

    if payload.state == "AT_HOME" then
        return updateState(traderID, {
            currentProvided = true,
            currentSettlementID = payload.homeCommunityID,
            originProvided = true,
            originSettlementID = payload.homeCommunityID,
            destinationProvided = true,
            destinationSettlementID = nil,
            lifecycleState = "idle",
            journeyState = "home",
            available = true,
            availabilityReason = "resident_trader_home",
        })
    end

    if payload.state == "FAILED" then
        local departedAt = tonumber(payload.departedAt) or 0
        local completedAt = tonumber(payload.completedAt) or 0
        local visitedAt = tonumber(payload.visitedAt) or 0
        local returnStartedAt = tonumber(payload.returnStartedAt) or 0
        local hasDeparted = departedAt > 0
        local hasCompleted = completedAt > 0
        local hasVisited = visitedAt > 0
        local isReturning = returnStartedAt > 0

        if hasDeparted and not hasCompleted then
            local visited = payload.visitedCommunityID
                or destinationID
                or (record.ca and record.ca.lastSettlementID)
            return updateState(traderID, {
                currentProvided = true,
                currentSettlementID = hasVisited and not isReturning
                    and visited or nil,
                originProvided = isReturning,
                originSettlementID = isReturning and visited or nil,
                destinationProvided = true,
                destinationSettlementID = nil,
                lifecycleState = "failed",
                journeyState = "failed",
                available = false,
                availabilityReason = "resident_excursion_failed",
            })
        end

        return updateState(traderID, {
            currentProvided = true,
            currentSettlementID = payload.homeCommunityID,
            originProvided = true,
            originSettlementID = payload.homeCommunityID,
            destinationProvided = true,
            destinationSettlementID = nil,
            lifecycleState = "idle",
            journeyState = "failed_before_departure",
            available = true,
            availabilityReason = "resident_excursion_not_departed",
        })
    end

    return true
end

Resident.OnExcursion = onExcursion

function Resident.Register()
    local excursions = PNC and PNC.CommunityExcursionService or nil
    if not excursions then return false, "excursion_service_unavailable" end
    local policyOK, policyReason = excursions.RegisterDeparturePolicy(
        POLICY_ID,
        residentPolicy
    )
    local listenerOK, listenerReason = excursions.RegisterListener(onExcursion)
    Resident.Registered = policyOK and listenerOK
    if not Resident.Registered then
        return false, policyReason or listenerReason
    end
    return true, "resident_excursion_registered"
end

Resident.Register()

return Resident
