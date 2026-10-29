if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

-- DynamicTrading's resident-trader policy. Project Hoomans owns the generic
-- excursion, participant travel, settlement visit safety, and exact-home
-- return; this bridge contributes only the bounded commercial decision and
-- the merchant-side economic consequences of an accepted visit.

DTHoomans = DTHoomans or {}
DTHoomans.ResidentExcursion = DTHoomans.ResidentExcursion or {}

local Resident = DTHoomans.ResidentExcursion
local Settlement = DTHoomans.Settlement
local TraderService = DTCommon and DTCommon.TraderService
local Policy = DTCommon and DTCommon.CoreActorPolicy

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
    local community = Settlement.ActiveCommunityForFaction(factionID)
    return community
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
    local mobility = PNC and PNC.CommercialMobilityService or nil
    local selected
    local reason
    local participantID
    local canDepart
    if not authority() or type(faction) ~= "table" then return nil end
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
    if not mobility or type(mobility.SelectDestination) ~= "function" then
        return nil
    end
    selected, reason = mobility.SelectDestination(faction, at, {
        resident = true,
        origin = community.home,
        excludeCommunityID = community.id,
        cooldown = function(target)
            return tostring(target and target.communityID or "")
                == tostring(policy.lastSettlementID or "")
                and recentlyVisited(record, at)
        end,
    })
    if not selected
        or tonumber(selected.score) < MIN_OPPORTUNITY_SCORE
    then
        return nil
    end
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
        destination = selected,
        itinerary = { selected },
        expectedReturnAt = at + 12,
        traderID = traderID,
        reason = reason,
    }
end

local function applyAvailability(traderID, available, reason)
    if not TraderService
        or type(TraderService.SetCoreActorAvailability) ~= "function"
    then
        return false, "trader_service_unavailable"
    end
    return TraderService.SetCoreActorAvailability(
        traderID, available == true, reason)
end

local function onExcursion(payload)
    local traderID
    local record
    local destination
    local result
    local reason
    if type(payload) ~= "table" then return false, "excursion_payload_missing" end
    if payload.purpose ~= PURPOSE then return true end
    traderID, record = recordForFaction(payload.factionID)
    if not traderID or not record then
        return false, "resident_trader_missing"
    end
    if payload.state == "PREPARING" then
        if TraderService and TraderService.SetCurrentSettlement then
            TraderService.SetCurrentSettlement(
                traderID, payload.homeCommunityID)
        end
        return true
    end
    if payload.state == "OUTBOUND"
        or payload.state == "RETURNING_HOME"
    then
        if TraderService and TraderService.SetCurrentSettlement then
            TraderService.SetCurrentSettlement(traderID, nil)
        end
        return applyAvailability(traderID, false,
            "community_excursion_" .. string.lower(payload.state))
    end
    if payload.state == "VISITING" then
        destination = payload.destination
            and payload.destination.communityID or nil
        if not destination then return false, "visit_destination_missing" end
        result, reason = Settlement.MarkTraderVisit(
            traderID,
            destination,
            {
                visitID = "dt_excursion:" .. tostring(payload.id)
                    .. ":" .. tostring(destination),
                now = payload.visitedAt or payload.stateAt or worldAge(),
                available = false,
                exchange = true,
            }
        )
        if not result and reason ~= "duplicate_visit" then
            log("WARN", "resident_excursion_exchange_failed trader="
                .. tostring(traderID) .. " reason=" .. tostring(reason))
            return false, reason
        end
        return applyAvailability(traderID, false,
            "resident_trader_visiting")
    end
    if payload.state == "AT_HOME" then
        if TraderService and TraderService.SetCurrentSettlement then
            TraderService.SetCurrentSettlement(
                traderID, payload.homeCommunityID)
        end
        return applyAvailability(traderID, true, "resident_trader_home")
    end
    if payload.state == "FAILED" then
        if payload.departedAt ~= nil
            and not payload.completedAt
        then
            if TraderService and TraderService.SetCurrentSettlement then
                TraderService.SetCurrentSettlement(traderID, nil)
            end
            return applyAvailability(traderID, false,
                "resident_excursion_failed")
        end
        if TraderService and TraderService.SetCurrentSettlement then
            TraderService.SetCurrentSettlement(
                traderID, payload.homeCommunityID)
        end
        return applyAvailability(traderID, true,
            "resident_excursion_not_departed")
    end
    return true
end

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
