-- DTAbstract representation provider for DTCommon.TraderWorld.
-- It owns Core abstract actor/journey execution only; DTCommon owns population,
-- route intent, commercial arrival, cooldown, and settlement visit effects.

DTAbstract = DTAbstract or {}
DTAbstract.TraderWorldProvider = DTAbstract.TraderWorldProvider or {}

local Provider = DTAbstract.TraderWorldProvider
local Providers = DTCommon and DTCommon.TraderProviders
    or require "DTCommon/DTCommon_TraderProviderRegistry"
local Service = DTCommon and DTCommon.TraderService
local Directory = DTCommon and DTCommon.SettlementDirectory

Provider.ID = "DTAbstract"
Provider.DEFAULT_SPEED = 60

local customActorRegistry = nil

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

local function actors()
    if PsychopatzCore and PsychopatzCore.Actors then
        return PsychopatzCore.Actors
    end
    local ok, value = pcall(
        require, "PsychopatzCore/Actors/PsychopatzActors")
    return ok and value or nil
end

local function registry()
    if customActorRegistry then return customActorRegistry end
    local api = actors()
    if api and api.DefaultRegistry then return api.DefaultRegistry end
    if api and type(api.NewRegistry) == "function" then
        customActorRegistry = api.NewRegistry()
        return customActorRegistry
    end
    return nil
end

function Provider.SetActorRegistry(value)
    customActorRegistry = value
end

function Provider.GetActorRegistry()
    return registry()
end

local function nextSequence()
    local count = 0
    if Service and type(Service.ForEach) == "function" then
        Service.ForEach(function(id)
            if string.sub(tostring(id), 1, 16) == "trader:abstract:"
                or string.sub(tostring(id), 1, 13) == "trader:world:"
            then
                count = count + 1
            end
        end)
    end
    return count + 1
end

function Provider.ownsRecord(traderID, record)
    local ca = record and record.ca or nil
    return ca ~= nil
        and tostring(ca.provider or ca.coreProvider or "") == Provider.ID
end

function Provider.isAvailable()
    return authority() and registry() ~= nil
end

function Provider.spawnTrader(spec)
    if not authority() then return nil, "server_authority_required" end
    spec = type(spec) == "table" and spec or {}

    local settlements = Directory and Directory.List
        and Directory.List() or {}
    if #settlements < 1 and Directory and Directory.EnsureDefaults then
        Directory.EnsureDefaults()
        settlements = Directory.List()
    end
    if #settlements < 1 then return nil, "no_settlements_available" end

    local sequence = tonumber(spec.sequence) or nextSequence()
    local traderID = spec.traderID
        or ("trader:world:" .. tostring(sequence))
    local actorID = spec.actorID
        or ("actor:dt:world:" .. tostring(sequence))
    local settlement = settlements[
        ((math.max(1, sequence) - 1) % #settlements) + 1]
    local settlementID = spec.settlementID or settlement.settlementID
    local position = spec.position
        or (Directory.ResolvePosition
            and Directory.ResolvePosition(settlementID))
    if not position then return nil, "settlement_position_unavailable" end

    local reg = registry()
    if not reg then return nil, "actor_registry_unavailable" end
    local actor = reg:Get(actorID)
    local reason
    if not actor then
        actor, reason = reg:Create({
            actorId = actorID,
            identitySeed = "dt-world-" .. tostring(actorID),
            world = { position = position },
        })
        if not actor then return nil, reason or "actor_create_failed" end
    end

    local coreProvider = DTAbstract.CoreProvider
        or require "DTAbstract/DTAbstract_CoreProvider"
    local acquired
    acquired, reason = coreProvider.Acquire(actor, { Actors = actors() }, {
        owner = "dtcommon:trader_world",
        now = spec.now or worldAge(),
    })
    if not acquired then return nil, reason or "lease_acquire_failed" end

    local committed
    committed, reason = reg:Commit(
        actorID, acquired, actor.revision)
    if not committed then return nil, reason or "actor_commit_failed" end

    local createdID, record = Service.Create({
        traderID = traderID,
        displayName = spec.displayName
            or ("Roaming Trader " .. tostring(sequence)),
        traderRole = spec.traderRole or "Roaming Trader",
        budget = spec.budget or 1000,
        abstractAccessEnabled = true,
        actorID = actorID,
        coreActorID = actorID,
        provider = Provider.ID,
        providerState = "abstract",
        coreProvider = Provider.ID,
        coreProviderState = "abstract",
        homeSettlementID = settlementID,
        currentSettlementID = settlementID,
        worldManaged = true,
        worldRole = spec.worldRole or "roaming",
        lifecycleState = "idle",
    })
    if not createdID then return nil, record or "trader_create_failed" end

    return {
        traderID = createdID,
        actorID = actorID,
        record = record,
        settlementID = settlementID,
        position = position,
    }
end

function Provider.canTravelTo(_, _, settlement)
    return settlement ~= nil
        and settlement.enabled ~= false
        and Directory ~= nil
        and Directory.ResolvePosition ~= nil
        and Directory.ResolvePosition(settlement.settlementID) ~= nil
end

function Provider.startMovement(traderID, record, request)
    if not authority() then return nil, "server_authority_required" end
    local ca = record and record.ca or nil
    local actorID = ca and (ca.actorID or ca.coreActorID) or nil
    local reg = registry()
    local actor = reg and actorID and reg:Get(actorID) or nil
    if not actor or not actor.world then return nil, "actor_world_not_found" end

    local api = actors()
    local world = api and api.World or nil
    if not world then return nil, "actors_world_unavailable" end
    local destination = request and request.destination or nil
    local destinationPosition = destination and destination.position
        or (Directory and Directory.ResolvePosition
            and Directory.ResolvePosition(
                request and request.destinationSettlementID))
    if not destinationPosition then
        return nil, "destination_position_not_found"
    end

    local now = worldAge(request and request.now)
    local origin = world.ProjectPosition(actor.world, now)
    local nextWorld, reason = world.StartJourney(
        actor.world, actor.actorId, {
            journeyID = request and request.journeyID,
            ownerMod = "DynamicTrading",
            ownerRef = traderID,
            mode = "abstract",
            origin = origin,
            destination = destinationPosition,
            speed = Provider.DEFAULT_SPEED,
            startAt = now,
            arrivalAction = {
                type = "dtcommon_trader_world",
                settlementID = request.destinationSettlementID,
            },
            metadata = {
                traderID = traderID,
                originSettlementID = request.originSettlementID,
                destinationSettlementID =
                    request.destinationSettlementID,
            },
        }, now)
    if not nextWorld then return nil, reason end

    local committed
    committed, reason = reg:Commit(
        actor.actorId, { world = nextWorld }, actor.revision)
    if not committed then return nil, reason end

    return {
        status = "en_route",
        journeyID = nextWorld.journey
            and nextWorld.journey.journeyID
            or request.journeyID,
    }
end

function Provider.pollMovement(_, record, request)
    local ca = record and record.ca or nil
    local actorID = ca and (ca.actorID or ca.coreActorID) or nil
    local reg = registry()
    local actor = reg and actorID and reg:Get(actorID) or nil
    if not actor or not actor.world then return nil, "actor_world_not_found" end

    local api = actors()
    local world = api and api.World or nil
    if not world then return nil, "actors_world_unavailable" end
    local journey = actor.world.journey
    if not journey then return { status = "idle" } end

    local now = worldAge(request and request.now)
    if journey.state == "en_route" or journey.state == "planned" then
        local nextWorld = world.AdvanceJourney(actor.world, now)
        local reason
        local committed
        committed, reason = reg:Commit(
            actor.actorId, { world = nextWorld }, actor.revision)
        if not committed then return nil, reason end
        journey = nextWorld.journey
    end

    if journey and journey.state == "arrived" then
        return {
            status = "arrived",
            journeyID = journey.journeyID,
            settlementID = ca.destinationSettlementID
                or request.destinationSettlementID,
            exchange = true,
        }
    end
    return {
        status = journey and journey.state or "idle",
        journeyID = journey and journey.journeyID or nil,
    }
end

function Provider.getPosition(_, record, now)
    local ca = record and record.ca or nil
    local actorID = ca and (ca.actorID or ca.coreActorID) or nil
    local reg = registry()
    local actor = reg and actorID and reg:Get(actorID) or nil
    local api = actors()
    if not actor or not actor.world or not api or not api.World then
        return nil, "actor_position_unavailable"
    end
    return api.World.ProjectPosition(actor.world, worldAge(now))
end

function Provider.reconcileRecord(traderID, record)
    local ca = record and record.ca or nil
    if not ca then return false, "trader_policy_missing" end
    local actorID = ca.actorID or ca.coreActorID
    local reg = registry()
    local actor = reg and actorID and reg:Get(actorID) or nil
    local Policy = DTCommon and DTCommon.CoreActorPolicy
    if not Policy then return false, "trader_policy_unavailable" end

    local changed = false
    if not actor then
        if ca.available ~= false
            or ca.availabilityReason ~= "core_actor_missing"
        then
            Policy.SetAvailable(record, false, "core_actor_missing")
            changed = true
        end
    elseif ca.available == false
        and ca.availabilityReason == "core_actor_missing"
    then
        Policy.SetAvailable(record, true, nil)
        changed = true
    end
    return true, changed and "changed" or "unchanged"
end

if Providers then
    Providers.Register(Provider.ID, {
        kind = "abstract",
        priority = 100,
        spawnTraderPriority = 200,
        isAvailable = Provider.isAvailable,
        ownsRecord = Provider.ownsRecord,
        spawnTrader = Provider.spawnTrader,
        canTravelTo = Provider.canTravelTo,
        startMovement = Provider.startMovement,
        pollMovement = Provider.pollMovement,
        reconcileRecord = Provider.reconcileRecord,
        getPosition = Provider.getPosition,
        getActorRegistry = Provider.GetActorRegistry,
    })
end

return Provider
