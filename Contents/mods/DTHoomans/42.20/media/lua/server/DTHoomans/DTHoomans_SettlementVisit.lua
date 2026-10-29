if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

-- Server-only bridge from Project Hoomans' authoritative travel arrival
-- lifecycle to DynamicTrading's settlement visit seam. Project Hoomans owns the
-- journey and canonical community identity; this adapter only forwards the
-- verified context to DTCommon.

DTHoomans = DTHoomans or {}
DTHoomans.Settlement = DTHoomans.Settlement or {}

local Settlement = DTHoomans.Settlement
local Service = DTCommon and DTCommon.TraderService
local ARRIVAL_ACTION = "dynamic_trading_settlement"
local MAX_ID_LENGTH = 192

local function text(value)
    if value == nil then return nil end
    value = tostring(value)
    return value ~= "" and value or nil
end

local function bounded(value, maximum)
    value = text(value) or ""
    maximum = tonumber(maximum) or MAX_ID_LENGTH
    if #value > maximum then return string.sub(value, 1, maximum) end
    return value
end

local function worldAge()
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and type(gameTime.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(gameTime:getWorldAgeHours()) or 0)
    end
    return 0
end

local function activeCommunity(communityID)
    local communities = PNC and PNC.Communities or nil
    local community
    if not communities or type(communities.Get) ~= "function" then
        return nil, "settlement_identity_unavailable"
    end
    community = communities.Get(communityID)
    if type(community) ~= "table"
        or tostring(community.id or "") ~= tostring(communityID or "")
        or community.status ~= "active"
    then
        return nil, "settlement_not_found"
    end
    return community
end

-- The canonical market identity is Project Hoomans' active community.id. A
-- faction owns a settlement but is not itself the settlement identity; a site
-- is only its physical location and may be reused later.
function Settlement.SettlementIDForFaction(factionID)
    local communities = PNC and PNC.Communities or nil
    local values
    if not communities or type(communities.GetForFaction) ~= "function" then
        return nil, "settlement_identity_unavailable"
    end
    values = communities.GetForFaction(factionID)
    for _, community in ipairs(type(values) == "table" and values or {}) do
        if type(community) == "table"
            and community.status == "active"
            and text(community.id)
        then
            return bounded(community.id), nil
        end
    end
    return nil, "settlement_not_found"
end

local function settlementIDFor(action, journey)
    local metadata = journey and journey.metadata or nil
    local requested = action and (action.settlementID or action.communityID)
        or nil
    requested = requested or metadata
        and (metadata.settlementID or metadata.communityID) or nil
    if requested then
        local community, reason = activeCommunity(requested)
        if not community then return nil, reason end
        return bounded(community.id), nil
    end
    local factionID = action and action.factionID or nil
    factionID = factionID or metadata and metadata.factionID or nil
    if factionID then return Settlement.SettlementIDForFaction(factionID) end
    return nil, "settlement_required"
end

local function traderMatchesNPC(record, npcID)
    local members = type(record and record.m) == "table" and record.m or {}
    if tostring(record and (record.p or record.l) or "")
        == tostring(npcID or "")
    then
        return true
    end
    for index = 1, #members do
        if tostring(members[index]) == tostring(npcID or "") then
            return true
        end
    end
    return false
end

local function traderIDForNPC(npcID, requestedTraderID)
    local selected
    local requested = text(requestedTraderID)
    if not Service or type(Service.ForEach) ~= "function" then
        return nil, "trader_service_unavailable"
    end
    Service.ForEach(function(traderID, record)
        if selected or type(record) ~= "table" then return end
        if requested and tostring(traderID) ~= requested then return end
        if traderMatchesNPC(record, npcID) then selected = tostring(traderID) end
    end)
    if selected then return selected end
    return nil, requested and "trader_npc_mismatch" or "trader_not_found"
end

local function visitIDFor(action, journey, traderID, settlementID)
    local requested = action and action.visitID or nil
    requested = requested or journey and journey.journeyId or nil
    requested = text(requested)
    if not requested then
        requested = "arrival"
    end
    return bounded("dt_settlement:" .. tostring(traderID)
        .. ":" .. tostring(settlementID) .. ":" .. requested, 128)
end

local function arrivalTime(action, journey)
    local value = action and action.now or nil
    value = value or journey and journey.arrivedWorldHour or nil
    value = value or journey and journey.lastAdvancedWorldHour or nil
    return tonumber(value) or worldAge()
end

function Settlement.MarkTraderVisit(traderID, settlementID, options)
    local request = {}
    local resolved
    local reason
    local key
    if not Service or type(Service.MarkSettlementVisit) ~= "function" then
        return nil, "trader_service_unavailable"
    end
    options = type(options) == "table" and options or {}
    resolved = text(settlementID or options.settlementID
        or options.communityID)
    if not resolved and options.factionID then
        resolved, reason = Settlement.SettlementIDForFaction(options.factionID)
        if not resolved then return nil, reason end
    end
    if not resolved then return nil, "settlement_required" end
    resolved, reason = activeCommunity(resolved)
    if not resolved then return nil, reason end
    for key, value in pairs(options) do request[key] = value end
    request.authority = "server"
    request.atSettlement = true
    request.settlementID = bounded(resolved.id)
    request.communityID = nil
    return Service.MarkSettlementVisit(traderID, request)
end

local function arrivalHandler(record, journey, action)
    local npcID = record and record.id or nil
    local traderID
    local settlementID
    local result
    local reason
    traderID, reason = traderIDForNPC(npcID, action and action.traderID)
    if not traderID then return false, reason end
    settlementID, reason = settlementIDFor(action, journey)
    if not settlementID then return false, reason end
    result, reason = Settlement.MarkTraderVisit(
        traderID,
        settlementID,
        {
            visitID = visitIDFor(action, journey, traderID, settlementID),
            now = arrivalTime(action, journey),
            available = action and action.available,
            earned = action and action.earned,
            restock = action and action.restock,
        }
    )
    if not result and reason == "duplicate_visit" then
        return true, reason
    end
    if not result then return false, reason end
    return true, "settlement_visit"
end

Settlement.ARRIVAL_ACTION = ARRIVAL_ACTION
Settlement.ArrivalHandler = arrivalHandler

function Settlement.RegisterArrivalHandler()
    local api = PNC and PNC.API and PNC.API.Travel or nil
    local arrivals = PNC and PNC.Travel and PNC.Travel.Arrivals or nil
    local registered
    if not api or type(api.RegisterArrivalHandler) ~= "function" then
        return false, "travel_arrival_api_unavailable"
    end
    registered = api.RegisterArrivalHandler(ARRIVAL_ACTION, arrivalHandler)
    if registered and arrivals and type(arrivals.StrictActionTypes) == "table" then
        arrivals.StrictActionTypes[ARRIVAL_ACTION] = true
    end
    Settlement.ArrivalHandlerRegistered = registered == true
    return registered == true,
        registered and nil or "travel_arrival_registration_failed"
end

Settlement.RegisterArrivalHandler()

if Events and Events.OnGameStart
    and type(Events.OnGameStart.Add) == "function"
    and not Settlement.ArrivalStartHookRegistered
then
    Settlement.ArrivalStartHookRegistered = true
    Events.OnGameStart.Add(function() Settlement.RegisterArrivalHandler() end)
end

return Settlement
