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

Provider.ID = "DTAbstract"
Provider.DEFAULT_SPEED = 60

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
    local adapter = coreProvider()
    local acquired, reason = adapter.Acquire(actor, {
        Actors = actors(),
    }, {
        owner = "dtcommon:trader_world",
        now = now,
    })
    if not acquired then return nil, reason end

    local reg = registry()
    if not reg then return nil, "actor_registry_unavailable" end
    return reg:Commit(
        actor.actorId,
        acquired,
        actor.revision
    )
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

local function legacyAbstractActorID(actorID)
    actorID = tostring(actorID or "")
    return string.sub(actorID, 1, 15) == "actor:dt:world:"
        or string.sub(actorID, 1, 15) == "actor:abstract:"
end

local function actorUsedElsewhere(actorID, traderID)
    local used = false
    if Service and type(Service.ForEach) == "function" then
        Service.ForEach(function(otherID, other)
            if tostring(otherID) ~= tostring(traderID) then
                local ca = other and other.ca or nil
                local otherActorID = ca
                    and (ca.actorID or ca.coreActorID) or nil
                if tostring(otherActorID or "")
                    == tostring(actorID or "")
                then
                    used = true
                end
            end
        end)
    end
    return used
end

function Provider.ownsRecord(_, record)
    local ca = record and record.ca or nil
    return ca ~= nil
        and tostring(ca.provider or ca.coreProvider or "") == Provider.ID
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
    if not candidate then
        return nil, reason or "canonical_trader_candidate_unavailable"
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
        coreActorID = candidate.actorID,
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
    Provider.LastRollbackError = nil

    return {
        traderID = createdID,
        actorID = candidate.actorID,
        groupID = candidate.groupID,
        factionID = candidate.factionID,
        settlementID = settlementID,
        record = record,
        position = candidate.position,
    }
end

local function directoryHas(settlementID)
    return settlementID ~= nil
        and Directory
        and type(Directory.Get) == "function"
        and Directory.Get(settlementID) ~= nil
end

function Provider.RebindLegacyRecord(traderID, record, now)
    local ca = record and record.ca or nil
    local oldActorID = ca and (ca.actorID or ca.coreActorID) or nil
    if not legacyAbstractActorID(oldActorID) then
        return nil, "legacy_actor_not_recognized"
    end

    now = worldAge(now)
    local reg = registry()
    if not reg then return nil, "actor_registry_unavailable" end
    local oldActor = reg:Get(oldActorID)

    local anchor
    local api = actors()
    if oldActor and oldActor.world and api and api.World then
        anchor = api.World.ProjectPosition(oldActor.world, now)
    end

    local candidate, reason = Runtime.SelectTraderCandidate({
        anchor = anchor,
        now = now,
        actorRegistry = reg,
    })
    if not candidate then
        return nil, reason or "canonical_trader_candidate_unavailable"
    end

    local replacement = reg:Get(candidate.actorID)
    if not replacement then return nil, "core_actor_not_found" end
    local committed
    committed, reason = acquire(replacement, now)
    if not committed then return nil, reason end

    -- Retire only the recognized pre-S7 standalone actor and only when no
    -- other trader record still references it. Never delete canonical actors.
    if oldActor and not actorUsedElsewhere(oldActorID, traderID) then
        local lease = oldActor.providerLease or {}
        if lease.provider == Provider.ID
            and lease.state ~= "released"
        then
            local released, releaseReason =
                releaseAcquired(oldActor, now)
            if not released then
                releaseAcquired(committed, now)
                return nil, releaseReason
            end
        end
    end

    local Policy = DTCommon and DTCommon.CoreActorPolicy
    if not Policy or type(Policy.Get) ~= "function"
        or type(Policy.SetProviderLease) ~= "function"
    then
        releaseAcquired(committed, now)
        return nil, "trader_policy_unavailable"
    end

    local policy = Policy.Get(record)
    policy.actorID = candidate.actorID
    policy.homeSettlementID = directoryHas(policy.homeSettlementID)
        and policy.homeSettlementID or candidate.communityID
    policy.currentSettlementID = directoryHas(policy.currentSettlementID)
        and policy.currentSettlementID or candidate.communityID

    -- Legacy standalone travel used the retired Kentucky directory and an
    -- actor-owned journey. It cannot be safely projected onto a canonical
    -- group route by ID, so migrate at the canonical home and let DTCommon
    -- choose the next commercial destination normally.
    policy.originSettlementID = nil
    policy.destinationSettlementID = nil
    policy.lifecycleState = "idle"
    policy.journeyID = nil
    policy.journeyState = nil
    policy.cooldownUntil = 0
    record.ca = policy

    local synced
    synced, reason = Policy.SetProviderLease(
        record,
        committed.providerLease
    )
    if not synced then
        releaseAcquired(committed, now)
        return nil, reason
    end

    if oldActor
        and not actorUsedElsewhere(oldActorID, traderID)
    then
        reg:Remove(oldActorID)
    end

    Provider.LastLegacyRebind = {
        traderID = tostring(traderID),
        oldActorID = tostring(oldActorID),
        actorID = candidate.actorID,
        groupID = candidate.groupID,
        communityID = candidate.communityID,
    }
    return candidate, "legacy_rebound"
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
    local origin = world:ProjectGroupPosition(group.id, now)
        or group.location
    local target = {
        id = request.destinationSettlementID,
        kind = "SETTLEMENT",
        x = destinationPosition.x,
        y = destinationPosition.y,
        z = destinationPosition.z or 0,
    }
    local updated
    updated, reason = world:StartGroupJourney(group.id, {
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
    local actorID = ca and (ca.actorID or ca.coreActorID) or nil
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
        group, reason = world:AdvanceGroupJourney(group.id, now)
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
    local actorID = ca and (ca.actorID or ca.coreActorID) or nil
    if not actorID then return nil, "core_actor_missing" end

    local world = Runtime.GetRegistry()
    local actorRegistry = registry()
    local actor = actorRegistry and actorRegistry:Get(actorID) or nil
    if not world or not actor then
        return nil, "actor_position_unavailable"
    end
    local group, reason = Runtime.FindGroupForActor(actorID)
    if not group then return nil, reason end
    return world:ProjectGroupMemberPosition(
        group.id,
        actorID,
        actor.world,
        worldAge(now)
    )
end

function Provider.rebaseMovement(_, record, options)
    options = type(options) == "table" and options or {}
    local ca = record and record.ca or nil
    local actorID = ca and (ca.actorID or ca.coreActorID) or nil
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
    updated, reason = world:RebaseGroupJourney(
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
    local actorID = ca and (ca.actorID or ca.coreActorID) or nil
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
                world:CancelGroupJourney(
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
    local actorID = ca.actorID or ca.coreActorID
    local actorRegistry = registry()
    local actor = actorRegistry and actorID
        and actorRegistry:Get(actorID) or nil
    local Policy = DTCommon and DTCommon.CoreActorPolicy
    if not Policy then return false, "trader_policy_unavailable" end

    local group = actor and Runtime.FindGroupForActor(actorID) or nil

    -- Pre-S7 standalone DTAbstract traders used actor:dt:world:* actors with
    -- no canonical SurvivorWorld group. Rebind those records once to an
    -- existing Core trader group, preserving the DTCommon commercial record.
    if (not actor or not group)
        and legacyAbstractActorID(actorID)
    then
        local rebound, reboundReason =
            Provider.RebindLegacyRecord(
                traderID,
                record,
                worldAge()
            )
        if rebound then
            ca = record.ca
            actorID = ca and ca.actorID or nil
            actor = actorRegistry and actorID
                and actorRegistry:Get(actorID) or nil
            group = actor
                and Runtime.FindGroupForActor(actorID)
                or nil
            Policy.SetAvailable(record, true, nil)
            Provider.LastLegacyRebindError = nil
            return true, "changed"
        end
        Provider.LastLegacyRebindError = tostring(
            reboundReason or "legacy_rebind_failed"
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
