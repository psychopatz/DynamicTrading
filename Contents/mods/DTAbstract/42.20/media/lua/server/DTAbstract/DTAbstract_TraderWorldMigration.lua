-- One-way migration for pre-S7 standalone DTAbstract trader actors.
--
-- This module is not a runtime world authority. It recognizes only retired
-- actor IDs, rebinds the existing commercial record to an already-canonical
-- SurvivorWorld trader actor/group, then removes the retired actor when safe.

DTAbstract = DTAbstract or {}
DTAbstract.TraderWorldMigration =
    DTAbstract.TraderWorldMigration or {}

local Migration = DTAbstract.TraderWorldMigration

function Migration.IsRetiredActorID(actorID)
    actorID = tostring(actorID or "")
    return string.sub(actorID, 1, 15) == "actor:dt:world:"
        or string.sub(actorID, 1, 15) == "actor:abstract:"
end

local function actorUsedElsewhere(
    service,
    actorID,
    traderID
)
    local used = false
    if service and type(service.ForEach) == "function" then
        service.ForEach(function(otherID, other)
            if tostring(otherID) ~= tostring(traderID) then
                local ca = other and other.ca or nil
                if tostring(ca and ca.actorID or "")
                    == tostring(actorID or "")
                then
                    used = true
                end
            end
        end)
    end
    return used
end

local function directoryHas(directory, settlementID)
    return settlementID ~= nil
        and directory
        and type(directory.Get) == "function"
        and directory.Get(settlementID) ~= nil
end

function Migration.Rebind(traderID, record, now, deps)
    deps = type(deps) == "table" and deps or {}
    local ca = record and record.ca or nil
    local oldActorID = ca and ca.actorID or nil
    if not Migration.IsRetiredActorID(oldActorID) then
        return nil, "retired_actor_not_recognized"
    end

    local registry = type(deps.registry) == "function"
        and deps.registry() or nil
    if not registry then
        return nil, "actor_registry_unavailable"
    end
    local oldActor = registry:Get(oldActorID)

    local anchor
    local actorAPI = type(deps.actors) == "function"
        and deps.actors() or nil
    if oldActor
        and oldActor.world
        and actorAPI
        and actorAPI.World
    then
        anchor = actorAPI.World.ProjectPosition(
            oldActor.world,
            now
        )
    end

    local runtime = deps.runtime
    if not runtime
        or type(runtime.SelectTraderCandidate) ~= "function"
    then
        return nil, "survivor_world_runtime_unavailable"
    end
    local candidate, reason = runtime.SelectTraderCandidate({
        anchor = anchor,
        now = now,
        actorRegistry = registry,
    })
    if not candidate then
        return nil,
            reason or "canonical_trader_candidate_unavailable"
    end

    local replacement = registry:Get(candidate.actorID)
    if not replacement then
        return nil, "core_actor_not_found"
    end
    if type(deps.acquire) ~= "function"
        or type(deps.releaseAcquired) ~= "function"
    then
        return nil, "provider_migration_contract_unavailable"
    end

    local committed
    committed, reason = deps.acquire(replacement, now)
    if not committed then return nil, reason end

    local service = deps.service
    local oldShared = actorUsedElsewhere(
        service,
        oldActorID,
        traderID
    )
    if oldActor and not oldShared then
        local lease = oldActor.providerLease or {}
        if lease.provider == "DTAbstract"
            and lease.state ~= "released"
        then
            local released, releaseReason =
                deps.releaseAcquired(oldActor, now)
            if not released then
                deps.releaseAcquired(committed, now)
                return nil, releaseReason
            end
        end
    end

    local Policy = DTCommon and DTCommon.CoreActorPolicy
        or require "DTCommon/DTCommon_CoreActorPolicy"
    if not Policy
        or type(Policy.Get) ~= "function"
        or type(Policy.SetProviderLease) ~= "function"
    then
        deps.releaseAcquired(committed, now)
        return nil, "trader_policy_unavailable"
    end

    local policy = Policy.Get(record)
    policy.actorID = candidate.actorID
    policy.homeSettlementID = directoryHas(
        deps.directory,
        policy.homeSettlementID
    ) and policy.homeSettlementID
        or candidate.communityID
    policy.currentSettlementID = directoryHas(
        deps.directory,
        policy.currentSettlementID
    ) and policy.currentSettlementID
        or candidate.communityID

    -- Retired standalone routes used non-canonical static settlement IDs and
    -- actor-owned journeys. Do not copy those into the canonical group route.
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
        deps.releaseAcquired(committed, now)
        return nil, reason
    end

    if oldActor and not oldShared then
        registry:Remove(oldActorID)
    end

    return candidate, "legacy_rebound", {
        traderID = tostring(traderID),
        oldActorID = tostring(oldActorID),
        actorID = candidate.actorID,
        groupID = candidate.groupID,
        communityID = candidate.communityID,
    }
end

return Migration
