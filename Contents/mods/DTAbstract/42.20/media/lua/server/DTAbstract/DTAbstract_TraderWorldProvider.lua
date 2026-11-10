-- DTAbstract representation provider for DTCommon.TraderWorld.
-- Canonical survivor identity, group membership, geography and movement live in
-- PsychopatzCore SurvivorWorld. DTAbstract only binds commercial roles and
-- executes the abstract representation of those existing canonical entities.

if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then
    return
end

DTAbstract = DTAbstract or {}
DTAbstract.TraderWorldProvider = DTAbstract.TraderWorldProvider or {}

local Provider = DTAbstract.TraderWorldProvider
local Providers = DTCommon and DTCommon.TraderProviders
    or require "DTCommon/DTCommon_TraderProviderRegistry"
local Service = DTCommon and DTCommon.TraderService
local Directory = DTCommon and DTCommon.SettlementDirectory
local Runtime = DTAbstract.SurvivorWorldRuntime
    or require "DTAbstract/DTAbstract_SurvivorWorldRuntime"
local Travel = (PsychopatzCore and PsychopatzCore.Travel)
    or require "PsychopatzCore/Travel/PsychopatzTravel"
local PreSurvivorWorldImport = require
    "DTAbstract/DTAbstract_PreSurvivorWorldImport"
local TraderGeneration = require
    "DTCommon/DTCommon_TraderGeneration"

Provider.ID = "DTAbstract"
Provider.DEFAULT_SPEED = 60
Provider.NEARBY_TALK_RADIUS = 60

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
    return Runtime.GetActorRegistry()
end

function Provider.SetActorRegistry(value)
    Runtime.SetActorRegistry(value)
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

local function coreProvider()
    return DTAbstract.CoreProvider
        or require "DTAbstract/DTAbstract_CoreProvider"
end

local function acquire(actor, now)
    local presence = PsychopatzCore
        and PsychopatzCore.SurvivorWorldPresence or nil
    if not presence then
        presence = require
            "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldPresence"
    end
    local acquired, reason = presence.EnsureAbstract(actor.actorId, {
        actorRegistry = registry(),
        provider = Provider.ID,
        owner = "dtcommon:trader_world",
        now = now,
    })
    if not acquired then return nil, reason end
    return acquired
end

local function releaseAcquired(actor, now)
    if not actor then return true end
    local adapter = coreProvider()
    local released, reason = adapter.Release(actor, {
        Actors = actors(),
    }, {
        owner = "dtcommon:trader_world",
        now = now,
    })
    if not released then return false, reason end
    local reg = registry()
    if not reg then return false, "actor_registry_unavailable" end
    local committed
    committed, reason = reg:Commit(
        actor.actorId,
        released,
        actor.revision
    )
    if not committed then return false, reason end
    return true
end

function Provider.ownsRecord(_, record)
    local ca = record and record.ca or nil
    return ca ~= nil
        and tostring(ca.provider or "") == Provider.ID
end

function Provider.isAvailable()
    if not authority() or registry() == nil then return false end
    local world = Runtime.GetRegistry()
    if world then return true end
    local resolved = Runtime.Ensure({
        actorRegistry = registry(),
    })
    return resolved ~= nil
end

local function placeDebugCandidate(candidate, position)
    if type(candidate) ~= "table"
        or type(position) ~= "table"
        or tonumber(position.x) == nil
        or tonumber(position.y) == nil
    then
        return candidate
    end
    local world = Runtime.GetRegistry()
    local group = world
        and type(world.GetGroup) == "function"
        and world:GetGroup(candidate.groupID) or nil
    if not group then return candidate end

    group.location = {
        id = group.location and group.location.id,
        kind = group.location and group.location.kind or "world",
        x = tonumber(position.x),
        y = tonumber(position.y),
        z = tonumber(position.z) or 0,
    }
    group.journey = nil
    group.targetLocation = nil
    group.state = "IDLE"
    group.stateEndsAt = 0

    local updated = world:UpsertGroup(group)
    if updated then
        Runtime.MarkDirty("dtabstract_debug_spawn_reposition")
        if Runtime.SurvivorWorld
            and Runtime.SurvivorWorld.RuntimeStore
            and type(Runtime.SurvivorWorld.RuntimeStore.Save) == "function"
        then
            Runtime.SurvivorWorld.RuntimeStore.Save()
        end
        candidate.position = {
            x = group.location.x,
            y = group.location.y,
            z = group.location.z,
        }
    end
    return candidate
end

function Provider.spawnTrader(spec)
    if not authority() then return nil, "server_authority_required" end
    spec = type(spec) == "table" and spec or {}

    local sequence = tonumber(spec.sequence) or nextSequence()
    local candidate, reason = Runtime.SelectTraderCandidate({
        anchor = spec.position,
        sequence = sequence,
        now = spec.now,
        actorRegistry = registry(),
    })
    if not candidate and spec.debug == true then
        candidate, reason = TraderGeneration.GenerateForFaction({
            provider = Provider.ID,
            presenceMode = "abstract",
            registry = Runtime.GetRegistry(),
            actorRegistry = registry(),
            position = spec.position,
            memberCount = spec.memberCount,
            createdAt = spec.now,
        })
    end
    if not candidate then
        return nil, reason or "canonical_trader_candidate_unavailable"
    end
    if spec.debug == true then
        candidate = placeDebugCandidate(candidate, spec.position)
    end

    local settlementID = candidate.communityID
    if not settlementID then
        return nil, "canonical_home_community_missing"
    end
    if Directory and Directory.Get
        and not Directory.Get(settlementID)
    then
        return nil, "canonical_home_community_unavailable"
    end

    local reg = registry()
    local actor = reg and reg:Get(candidate.actorID) or nil
    if not actor then return nil, "core_actor_not_found" end

    local now = worldAge(spec.now)
    local committed
    committed, reason = acquire(actor, now)
    if not committed then
        return nil, reason or "lease_acquire_failed"
    end

    local traderID = spec.traderID
        or ("trader:world:" .. tostring(sequence))
    local createdID, record = Service.Create({
        traderID = traderID,
        displayName = spec.displayName
            or ("Roaming Trader " .. tostring(sequence)),
        traderRole = spec.traderRole or "Roaming Trader",
        budget = spec.budget or 1000,
        abstractAccessEnabled = true,
        actorID = candidate.actorID,
        provider = Provider.ID,
        providerState = "abstract",
        homeSettlementID = settlementID,
        currentSettlementID = settlementID,
        worldManaged = true,
        worldRole = spec.worldRole or "roaming",
        lifecycleState = "idle",
    })
    if not createdID then
        local rolledBack, rollbackReason =
            releaseAcquired(committed, now)
        if not rolledBack then
            Provider.LastRollbackError = tostring(
                rollbackReason or "lease_rollback_failed"
            )
        end
        return nil, record or "trader_create_failed"
    end
    if type(Service.BindActorGroup) == "function" then
        local bound, bindReason = Service.BindActorGroup(
            createdID,
            candidate.factionID,
            candidate.actorID,
            candidate.memberActorIDs
        )
        if not bound then
            if type(Service.Remove) == "function" then
                Service.Remove(createdID)
            end
            local rolledBack, rollbackReason = releaseAcquired(committed, now)
            if not rolledBack then
                Provider.LastRollbackError = tostring(
                    rollbackReason or "lease_rollback_failed"
                )
            end
            return nil, bindReason or "trader_group_bind_failed"
        end
    end
    Provider.LastRollbackError = nil

    return {
        traderID = createdID,
        actorID = candidate.actorID,
        groupID = candidate.groupID,
        factionID = candidate.factionID,
        memberActorIDs = candidate.memberActorIDs,
        settlementID = settlementID,
        record = record,
        position = candidate.position,
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
    local actorID = ca and ca.actorID or nil
    if not actorID then return nil, "core_actor_missing" end

    local world, reason = Runtime.Ensure({
        actorRegistry = registry(),
    })
    if not world then return nil, reason end
    local group
    group, reason = Runtime.FindGroupForActor(actorID)
    if not group then return nil, reason end

    local destination = request and request.destination or nil
    local destinationPosition = destination and destination.position
        or (Directory and Directory.ResolvePosition
            and Directory.ResolvePosition(
                request and request.destinationSettlementID))
    if not destinationPosition then
        return nil, "destination_position_not_found"
    end

    local now = worldAge(request and request.now)
    local origin = Travel.Registry.ProjectPosition(
        world,
        group.id,
        now
    )
        or group.location
    local target = {
        id = request.destinationSettlementID,
        kind = "SETTLEMENT",
        x = destinationPosition.x,
        y = destinationPosition.y,
        z = destinationPosition.z or 0,
    }
    local updated
    updated, reason = Travel.Registry.Start(world, group.id, {
        journeyID = request and request.journeyID,
        ownerMod = "DynamicTrading",
        ownerRef = traderID,
        mode = "abstract",
        origin = origin,
        originAnchorID = group.location and group.location.id,
        destination = target,
        targetLocation = target,
        destinationAnchorID = request.destinationSettlementID,
        speed = Provider.DEFAULT_SPEED,
        startAt = now,
    }, now)
    if not updated then return nil, reason end
    local dirty, dirtyReason = Runtime.MarkDirty(
        "dtabstract_group_journey_started")
    if dirty == false then return nil, dirtyReason end

    return {
        status = updated.journey
            and updated.journey.state or "en_route",
        journeyID = updated.journey
            and updated.journey.journeyID
            or request.journeyID,
        groupID = updated.id,
    }
end

function Provider.pollMovement(_, record, request)
    local ca = record and record.ca or nil
    local actorID = ca and ca.actorID or nil
    if not actorID then return nil, "core_actor_missing" end

    local world = Runtime.GetRegistry()
    if not world then return nil, "survivor_world_unavailable" end
    local group, reason = Runtime.FindGroupForActor(actorID)
    if not group then return nil, reason end
    local journey = group.journey
    if not journey then return { status = "idle" } end

    local now = worldAge(request and request.now)
    if journey.state == "en_route"
        or journey.state == "planned"
        or journey.state == "waiting"
    then
        group, reason = Travel.Registry.Advance(world, group.id, now)
        if not group then return nil, reason end
        local dirty, dirtyReason = Runtime.MarkDirty(
            "dtabstract_group_journey_advanced")
        if dirty == false then return nil, dirtyReason end
        journey = group.journey
    end

    if journey and journey.state == "arrived" then
        return {
            status = "arrived",
            journeyID = journey.journeyID,
            settlementID = ca.destinationSettlementID
                or request.destinationSettlementID,
            exchange = true,
            groupID = group.id,
        }
    end
    return {
        status = journey and journey.state or "idle",
        journeyID = journey and journey.journeyID or nil,
        groupID = group.id,
    }
end

function Provider.getPosition(_, record, now)
    local ca = record and record.ca or nil
    local actorID = ca and ca.actorID or nil
    if not actorID then return nil, "core_actor_missing" end

    local world = Runtime.GetRegistry()
    local actorRegistry = registry()
    local actor = actorRegistry and actorRegistry:Get(actorID) or nil
    if not world or not actor then
        return nil, "actor_position_unavailable"
    end
    local group, reason = Runtime.FindGroupForActor(actorID)
    if not group then return nil, reason end
    return Travel.Registry.ProjectMemberPosition(
        world,
        group.id,
        actorID,
        actor.world,
        worldAge(now)
    )
end

function Provider.rebaseMovement(_, record, options)
    options = type(options) == "table" and options or {}
    local ca = record and record.ca or nil
    local actorID = ca and ca.actorID or nil
    if not actorID then return nil, "core_actor_missing" end
    local position = options.position
    if type(position) ~= "table"
        or tonumber(position.x) == nil
        or tonumber(position.y) == nil
    then
        return nil, "rebase_position_required"
    end

    local world = Runtime.GetRegistry()
    if not world then return nil, "survivor_world_unavailable" end
    local group, reason = Runtime.FindGroupForActor(actorID)
    if not group then return nil, reason end
    if not group.journey then
        return group, "no_active_group_journey"
    end

    local updated
    updated, reason = Travel.Registry.Rebase(
        world,
        group.id,
        {
            x = tonumber(position.x),
            y = tonumber(position.y),
            z = tonumber(position.z) or 0,
        },
        worldAge(options.now)
    )
    if not updated then return nil, reason end
    local dirty, dirtyReason = Runtime.MarkDirty(
        "dtabstract_group_journey_rebased")
    if dirty == false then return nil, dirtyReason end
    return updated
end

function Provider.releaseTrader(traderID, record, now)
    local ca = record and record.ca or nil
    local actorID = ca and ca.actorID or nil
    if not actorID then return false, "core_actor_missing" end

    local world = Runtime.GetRegistry()
    if world then
        local group = Runtime.FindGroupForActor(actorID)
        local journey = group and group.journey or nil
        if journey
            and journey.ownerMod == "DynamicTrading"
            and tostring(journey.ownerRef or "") == tostring(traderID)
            and journey.state ~= "arrived"
            and journey.state ~= "cancelled"
            and journey.state ~= "blocked"
        then
            local cancelled, cancelReason =
                Travel.Registry.Cancel(
                    world,
                    group.id,
                    "dt_trader_removed"
                )
            if not cancelled then
                return false, cancelReason
            end
            Runtime.MarkDirty(
                "dtabstract_group_journey_cancelled"
            )
        end
    end

    local actorRegistry = registry()
    local actor = actorRegistry and actorRegistry:Get(actorID) or nil
    if not actor then return true, "actor_already_missing" end
    local lease = actor.providerLease or {}
    if lease.provider ~= Provider.ID then
        return true, "lease_not_owned"
    end

    local released, reason = coreProvider().Release(
        actor,
        { Actors = actors() },
        {
            owner = "dtcommon:trader_world",
            now = worldAge(now),
        }
    )
    if not released then return false, reason end
    local committed
    committed, reason = actorRegistry:Commit(
        actorID,
        released,
        actor.revision
    )
    if not committed then return false, reason end
    return true, "released"
end

function Provider.reconcileRecord(traderID, record)
    local ca = record and record.ca or nil
    if not ca then return false, "trader_policy_missing" end
    local actorID = ca.actorID
    local actorRegistry = registry()
    local actor = actorRegistry and actorID
        and actorRegistry:Get(actorID) or nil
    local Policy = DTCommon and DTCommon.CoreActorPolicy
    if not Policy then return false, "trader_policy_unavailable" end

    local group = actor and Runtime.FindGroupForActor(actorID) or nil

    -- Pre-SurvivorWorld standalone actors are handled by one bounded import
    -- module; active provider code never interprets their old world model.
    if (not actor or not group)
        and PreSurvivorWorldImport.IsRetiredActorID(actorID)
    then
        local rebound, reboundReason, importDetails =
            PreSurvivorWorldImport.Rebind(
                traderID,
                record,
                worldAge(),
                {
                    registry = registry,
                    actors = actors,
                    runtime = Runtime,
                    directory = Directory,
                    service = Service,
                    acquire = acquire,
                    releaseAcquired = releaseAcquired,
                }
            )
        if rebound then
            Provider.LastPreSurvivorWorldImport = importDetails
            ca = record.ca
            actorID = ca and ca.actorID or nil
            actor = actorRegistry and actorID
                and actorRegistry:Get(actorID) or nil
            group = actor
                and Runtime.FindGroupForActor(actorID)
                or nil
            Policy.SetAvailable(record, true, nil)
            Provider.LastPreSurvivorWorldImportError = nil
            return true, "changed"
        end
        Provider.LastPreSurvivorWorldImportError = tostring(
            reboundReason or "world_import_failed"
        )
    end

    local available = actor ~= nil and group ~= nil
    local reason = not actor and "core_actor_missing"
        or not group and "core_group_missing"
        or nil
    local changed = false

    if not available then
        if ca.available ~= false
            or ca.availabilityReason ~= reason
        then
            Policy.SetAvailable(record, false, reason)
            changed = true
        end
    elseif ca.available == false
        and (ca.availabilityReason == "core_actor_missing"
            or ca.availabilityReason == "core_group_missing")
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
        rebaseMovement = Provider.rebaseMovement,
        getActorRegistry = Provider.GetActorRegistry,
    })
end

return Provider
