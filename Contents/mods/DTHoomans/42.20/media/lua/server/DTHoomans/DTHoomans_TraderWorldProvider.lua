-- DTHoomans representation provider for DTCommon.TraderWorld.
-- DTCommon owns trader population, destination intent, arrival/cooldown, and
-- commercial effects. This provider owns caravan/body/group execution only.

DTHoomans = DTHoomans or {}
DTHoomans.TraderWorldProvider = DTHoomans.TraderWorldProvider or {}

local Provider = DTHoomans.TraderWorldProvider
local Providers = DTCommon and DTCommon.TraderProviders
    or require "DTCommon/DTCommon_TraderProviderRegistry"
local Service = DTCommon and DTCommon.TraderService

Provider.ID = "DTHoomans"
Provider.MOBILITY_INTENT = "dynamic_trading_managed"
Provider.MIN_DISTANCE = 45
Provider.MAX_DISTANCE = 90

local function authority()
    return DTCommon and DTCommon.Storage
        and type(DTCommon.Storage.IsAuthority) == "function"
        and DTCommon.Storage.IsAuthority() == true
end

local function worldAge(value)
    value = tonumber(value)
    if value ~= nil then return math.max(0, value) end
    local time = getGameTime and getGameTime() or nil
    if time and type(time.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(time:getWorldAgeHours()) or 0)
    end
    return 0
end

local function firstPlayer()
    local players = getOnlinePlayers and getOnlinePlayers() or nil
    if players and type(players.size) == "function"
        and type(players.get) == "function"
    then
        for index = 0, players:size() - 1 do
            local player = players:get(index)
            if player then return player end
        end
    elseif type(players) == "table" then
        for _, player in ipairs(players) do
            if player then return player end
        end
    end
    return getPlayer and getPlayer() or nil
end

local function placementFor(player, sequence)
    local span = math.max(1,
        Provider.MAX_DISTANCE - Provider.MIN_DISTANCE + 1)
    local offset = Provider.MIN_DISTANCE
        + (tonumber(sequence) or 0) % span
    local angle = ((tonumber(sequence) or 0) * 2.399963)
        % (math.pi * 2)
    return math.floor(player:getX() + math.cos(angle) * offset),
        math.floor(player:getY() + math.sin(angle) * offset),
        math.floor(player:getZ() or 0)
end

local function factionFor(record)
    local id = record and record.g or nil
    local factions = PNC and PNC.Factions or nil
    return id and factions and type(factions.Get) == "function"
        and factions.Get(id) or nil
end

function Provider.isAvailable()
    return authority()
        and DTHoomans.Caravan ~= nil
        and type(DTHoomans.Caravan.Spawn) == "function"
        and PNC ~= nil
end

function Provider.ownsRecord(_, record)
    local faction = factionFor(record)
    local tags = faction and faction.tags or nil
    if type(tags) ~= "table"
        or tags.dynamicTrading ~= true
        or tags.mobileGroup ~= true
        or faction.status ~= "active"
    then
        return false
    end
    return true
end

function Provider.spawnTrader(spec)
    if not authority() then return nil, "server_authority_required" end
    spec = type(spec) == "table" and spec or {}
    local player = firstPlayer()
    if not player then return nil, "no_player" end
    local caravan = DTHoomans.Caravan
    if not caravan or type(caravan.Spawn) ~= "function" then
        return nil, "caravan_service_unavailable"
    end

    local sequence = tonumber(spec.sequence) or 1
    local traderID = spec.traderID
        or ("trader:world:" .. tostring(sequence))
    local position = type(spec.position) == "table"
        and spec.position or nil
    local x, y, z = placementFor(player, sequence)
    if position
        and tonumber(position.x) ~= nil
        and tonumber(position.y) ~= nil
    then
        x = tonumber(position.x)
        y = tonumber(position.y)
        z = tonumber(position.z) or 0
    end
    local debugSpawn = spec.debug == true
    local request, reason = caravan.Spawn(
        x, y, z, nil, nil, {
            debug = debugSpawn,
            presenceMode = debugSpawn and "live" or "auto",
            traderID = traderID,
            worldManaged = true,
            mobilityIntent = Provider.MOBILITY_INTENT,
        })
    if not request or request.status ~= "spawned" then
        return nil, reason or (request and request.reason)
            or "caravan_spawn_failed"
    end
    return {
        traderID = request.traderID or traderID,
        actorID = request.actorID,
        factionID = request.factionID,
        record = Service and Service.GetRecord
            and Service.GetRecord(request.traderID or traderID) or nil,
    }
end

local function targetFor(record, settlementID)
    local faction = factionFor(record)
    local helper = PNC and PNC.MobileGroupDirectorInternal or nil
    if not faction or not helper
        or type(helper.ResolveSettlementDepartureTargets) ~= "function"
    then
        return nil, "mobile_target_resolver_unavailable"
    end
    local targets = helper.ResolveSettlementDepartureTargets(
        faction, { commercial = true, candidateLimit = 64 })
    for _, target in ipairs(targets or {}) do
        if tostring(target.communityID or "")
            == tostring(settlementID or "")
        then
            return target
        end
    end
    return nil, "settlement_target_unreachable"
end

function Provider.ResolveSettlementTarget(record, settlementID)
    return targetFor(record, settlementID)
end

function Provider.canTravelTo(_, record, settlement, now)
    if not settlement
        or tostring(settlement.settlementID or "") == ""
    then
        return false
    end
    local target = targetFor(record, settlement.settlementID)
    if not target then return false end
    local faction = factionFor(record)
    local visits = PNC and PNC.MobileSettlementVisitService or nil
    if visits and type(visits.IsSettlementVisitEligible) == "function" then
        local ok = visits.IsSettlementVisitEligible(
            faction, target, worldAge(now))
        return ok == true
    end
    return true
end

function Provider.scoreDestination(_, record, settlement, now)
    local target = targetFor(record, settlement and settlement.settlementID)
    local faction = factionFor(record)
    local mobility = DTHoomans.CommercialMobility
    if not target or not faction or not mobility
        or type(mobility.OpportunityScore) ~= "function"
    then
        return 0
    end
    return tonumber(mobility.OpportunityScore(
        faction, target, { at = worldAge(now) })) or 0
end

function Provider.startMovement(traderID, record, request)
    if not authority() then return nil, "server_authority_required" end
    local faction = factionFor(record)
    if not faction then return nil, "faction_not_found" end
    local target, reason = targetFor(
        record, request and request.destinationSettlementID)
    if not target then return nil, reason end

    local mobility = PNC and PNC.CommercialMobilityService or nil
    if not mobility or type(mobility.StartCommercialTravel) ~= "function" then
        return nil, "commercial_travel_unavailable"
    end
    local started
    started, reason = mobility.StartCommercialTravel(
        faction,
        target,
        worldAge(request and request.now),
        {
            managedBy = "DynamicTrading",
            traderID = traderID,
            journeyID = request and request.journeyID,
        })
    if not started then return nil, reason end
    return {
        status = "en_route",
        journeyID = request and request.journeyID,
        target = target,
    }
end

function Provider.pollMovement(_, record, request)
    local faction = factionFor(record)
    local mobile = faction and faction.mobile or nil
    if not mobile then
        local ca = record and record.ca or nil
        if ca and tostring(ca.returnProviderID or "") ~= "" then
            return {
                status = "external",
                journeyID = request and request.journeyID,
            }
        end
        return nil, "mobile_group_unavailable"
    end

    if mobile.travel or mobile.pendingSettlementArrival then
        return {
            status = "en_route",
            journeyID = request and request.journeyID,
        }
    end
    if mobile.visit then
        return {
            status = "en_route",
            journeyID = request and request.journeyID,
        }
    end

    -- Hoomans emits authoritative settlement-arrival events. The DTHoomans
    -- arrival adapter calls DTCommon.TraderWorld.Arrive exactly once, so an
    -- idle group with a still-pending DT destination remains externally driven
    -- rather than fabricating a second arrival here.
    return {
        status = "external",
        journeyID = request and request.journeyID,
    }
end

if Providers then
    Providers.Register(Provider.ID, {
        kind = "physical",
        priority = 200,
        spawnTraderPriority = 100,
        materializeTraderPriority = 300,
        isAvailable = Provider.isAvailable,
        ownsRecord = Provider.ownsRecord,
        spawnTrader = Provider.spawnTrader,
        canTravelTo = Provider.canTravelTo,
        scoreDestination = Provider.scoreDestination,
        startMovement = Provider.startMovement,
        pollMovement = Provider.pollMovement,
        getPosition = function(traderID, _, now)
            local runtime = DTHoomans.ProviderRuntime
            if runtime and type(runtime.GetPosition) == "function" then
                return runtime.GetPosition(traderID, now)
            end
            return nil, "physical_position_unavailable"
        end,
        materializeTrader = function(traderID, options)
            local runtime = DTHoomans.ProviderRuntime
            if not runtime or type(runtime.MaterializeTrader) ~= "function" then
                return nil, "physical_provider_unavailable"
            end
            return runtime.MaterializeTrader(traderID, options)
        end,
        dematerializeTrader = function(traderID, options)
            local runtime = DTHoomans.ProviderRuntime
            if not runtime or type(runtime.DematerializeTrader) ~= "function" then
                return nil, "physical_provider_unavailable"
            end
            return runtime.DematerializeTrader(traderID, options)
        end,
        recoverMissingBody = function(traderID, options)
            local runtime = DTHoomans.ProviderRuntime
            if not runtime or type(runtime.RecoverMissingBody) ~= "function" then
                return nil, "physical_provider_unavailable"
            end
            return runtime.RecoverMissingBody(traderID, options)
        end,
    })
end

return Provider
