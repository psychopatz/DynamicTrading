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

local function lowerText(value)
    value = text(value)
    return value and string.lower(value) or nil
end

local function hasProfileTag(tags, candidates)
    local key
    local value
    local candidate
    local normalizedKey
    local normalizedValue
    if type(tags) ~= "table" then return false end
    for _, candidate in ipairs(candidates) do
        value = tags[candidate]
        if value == true then return true end
        if lowerText(value) == candidate then return true end
    end
    -- Project Hoomans tags are a bounded key/value map. Accept a matching
    -- value as well as a matching key so existing faction metadata can drive
    -- the profile without adding a DynamicTrading taxonomy to Hoomans.
    for key, value in pairs(tags) do
        normalizedKey = lowerText(key)
        normalizedValue = lowerText(value)
        for _, candidate in ipairs(candidates) do
            if normalizedKey == candidate or normalizedValue == candidate then
                return true
            end
        end
    end
    return false
end

local FARM_PROFILE_TAGS = {
    "farm", "farming", "agriculture", "agricultural",
}
local MILITARY_PROFILE_TAGS = {
    "military", "armed", "security", "ammunition", "weapons",
}

-- Resolve only bounded, already-persisted Hoomans metadata. DynamicTrading
-- does not create a parallel faction/settlement taxonomy; unsupported
-- classifications deliberately fall back to the neutral profile.
local function marketProfileForCommunity(community)
    local factions = PNC and PNC.Factions or nil
    local faction
    local archetype
    local mode
    local tags
    if type(community) ~= "table" then return "default" end
    faction = factions and type(factions.Get) == "function"
        and factions.Get(community.factionID) or nil
    tags = faction and faction.tags or nil
    archetype = lowerText(faction and faction.archetypeID)
    mode = lowerText(community.mode)
    if hasProfileTag(tags, MILITARY_PROFILE_TAGS)
        or archetype == "military"
    then
        return "military"
    end
    if hasProfileTag(tags, FARM_PROFILE_TAGS)
        or archetype == "farm"
        or archetype == "agricultural"
        or mode == "farm"
    then
        return "farm"
    end
    return "default"
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

local function provisionMarket(community)
    local markets = DTCommon and DTCommon.SettlementMarket or nil
    local profileID
    local market
    local createdOrReason
    if type(community) ~= "table" or not text(community.id) then
        return nil, "settlement_required"
    end
    -- Older isolated bridge harnesses do not load the market module. Keep the
    -- explicit legacy helper usable there; production DTCommon always exposes
    -- the registry and therefore takes the provisioning path below.
    if not markets or type(markets.GetOrCreate) ~= "function" then
        return true, false
    end
    profileID = marketProfileForCommunity(community)
    market, createdOrReason = markets.GetOrCreate(
        bounded(community.id),
        { profileID = profileID }
    )
    if not market then return nil, createdOrReason end
    return market, createdOrReason
end

Settlement.MarketProfileForCommunity = marketProfileForCommunity
Settlement.ProvisionMarket = provisionMarket

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

local function arrivalMemberIDs(details)
    local output = {}
    local seen = {}
    local group = details and details.group or nil
    local faction = details and details.faction or nil
    local source = group and (group.memberIds or group.memberIDs) or nil
    local key
    local value
    local npcID
    if type(source) == "table" then
        for key, value in pairs(source) do
            npcID = type(key) == "number" and value or key
            if npcID and not seen[tostring(npcID)] then
                seen[tostring(npcID)] = true
                output[#output + 1] = tostring(npcID)
            end
        end
    end
    if #output == 0 and type(faction and faction.memberIDs) == "table" then
        for npcID, present in pairs(faction.memberIDs) do
            if present == true and not seen[tostring(npcID)] then
                seen[tostring(npcID)] = true
                output[#output + 1] = tostring(npcID)
            end
        end
    end
    table.sort(output)
    while #output > 24 do table.remove(output) end
    return output
end

local function traderIDForFaction(factionID, details)
    local requested
    local record
    local memberIDs
    local index
    local traderID
    if not text(factionID) then return nil, "faction_required" end
    requested = Settlement.TraderIDForFaction
        and Settlement.TraderIDForFaction(factionID)
        or "dt_" .. tostring(factionID)
    if requested and Service and type(Service.GetRecord) == "function" then
        record = Service.GetRecord(requested)
        if record and tostring(record.g or "") == tostring(factionID) then
            return requested
        end
    end
    memberIDs = arrivalMemberIDs(details)
    for index = 1, #memberIDs do
        traderID = traderIDForNPC(memberIDs[index])
        if traderID then return traderID end
    end
    return nil, "trader_not_found"
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
    local market
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
    market, reason = provisionMarket(resolved)
    if not market then return nil, reason end
    for key, value in pairs(options) do request[key] = value end
    request.authority = "server"
    request.atSettlement = true
    request.settlementID = bounded(resolved.id)
    request.communityID = nil
    return Service.MarkSettlementVisit(traderID, request)
end

local function arrivalVisitID(details, traderID, settlementID)
    local travel = details and details.travel or nil
    local faction = details and details.faction or nil
    local visit = faction and faction.mobile and faction.mobile.visit or nil
    local key = details and details.visitID or nil
    key = key or travel and (travel.visitID or travel.id
        or travel.journeyId or travel.revision) or nil
    key = key or visit and visit.id or nil
    if not key then return nil end
    return bounded("dt_settlement:" .. tostring(traderID)
        .. ":" .. tostring(settlementID) .. ":" .. tostring(key), 128)
end

local function handleHoomansSettlementArrival(details)
    local faction = details and details.faction or nil
    local community = details and details.community or nil
    local settlementID
    local traderID
    local visitID
    local result
    local reason
    if type(details) ~= "table" then return false, "arrival_context_missing" end
    if type(community) ~= "table" then
        return false, "settlement_community_missing"
    end
    settlementID, reason = activeCommunity(community.id)
    if not settlementID then return false, reason end
    if type(faction) ~= "table" or not faction.id then
        return false, "mobile_faction_missing"
    end
    traderID, reason = traderIDForFaction(faction.id, details)
    if not traderID then return false, reason end
    visitID = arrivalVisitID(details, traderID, settlementID.id)
    if not visitID then return false, "arrival_identity_missing" end
    result, reason = Settlement.MarkTraderVisit(
        traderID,
        settlementID.id,
        {
            visitID = visitID,
            now = details.at or worldAge(),
            exchange = true,
        }
    )
    if not result and reason == "duplicate_visit" then
        return true, reason
    end
    if not result then return false, reason end
    return true, "settlement_visit"
end

Settlement.HandleHoomansSettlementArrival = handleHoomansSettlementArrival

function Settlement.StartTraderTravel(traderID, settlementID, request)
    local api = PNC and PNC.API and PNC.API.Travel or nil
    local record
    local npcID
    local resolved
    local reason
    local action = {}
    local source
    if not api or type(api.Start) ~= "function" then
        return nil, "travel_api_unavailable"
    end
    if DTCommon.Storage and type(DTCommon.Storage.IsAuthority) == "function"
        and DTCommon.Storage.IsAuthority() ~= true
    then
        return nil, "server_authority_required"
    end
    record = Service and type(Service.GetRecord) == "function"
        and Service.GetRecord(traderID) or nil
    if not record then return nil, "trader_not_found" end
    npcID = text(record.p or record.l)
    if not npcID then return nil, "trader_npc_missing" end
    resolved, reason = activeCommunity(settlementID)
    if not resolved then return nil, reason end
    request = type(request) == "table" and request or {}
    source = type(request.arrivalAction) == "table"
        and request.arrivalAction or {}
    for key, value in pairs(source) do action[key] = value end
    action.type = ARRIVAL_ACTION
    action.traderID = bounded(traderID)
    action.settlementID = bounded(resolved.id)
    action.factionID = action.factionID or record.g
    if action.exchange == nil then action.exchange = request.exchange ~= false end
    request.ownerMod = request.ownerMod or "DynamicTrading"
    request.ownerRef = request.ownerRef or bounded(traderID)
    request.arrivalAction = action
    return api.Start(npcID, request)
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
            exchange = action and action.exchange == true,
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

local function onHoomansSettlementArrival(details)
    return handleHoomansSettlementArrival(details)
end

Settlement.HoomansArrivalListener = onHoomansSettlementArrival

function Settlement.RegisterHoomansArrivalListener()
    local service = PNC and PNC.MobileSettlementVisitService or nil
    local registered
    if not service or type(service.RegisterArrivalListener) ~= "function" then
        return false, "mobile_settlement_arrival_api_unavailable"
    end
    if Settlement.HoomansArrivalListenerRegistered then return true end
    registered = service.RegisterArrivalListener(onHoomansSettlementArrival)
    Settlement.HoomansArrivalListenerRegistered = registered == true
    return registered == true,
        registered and nil or "mobile_settlement_arrival_registration_failed"
end

Settlement.RegisterArrivalHandler()
Settlement.RegisterHoomansArrivalListener()

if Events and Events.OnGameStart
    and type(Events.OnGameStart.Add) == "function"
    and not Settlement.ArrivalStartHookRegistered
then
    Settlement.ArrivalStartHookRegistered = true
    Events.OnGameStart.Add(function() Settlement.RegisterArrivalHandler() end)
    if not Settlement.HoomansArrivalStartHookRegistered then
        Settlement.HoomansArrivalStartHookRegistered = true
        Events.OnGameStart.Add(function()
            Settlement.RegisterHoomansArrivalListener()
        end)
    end
end

return Settlement
