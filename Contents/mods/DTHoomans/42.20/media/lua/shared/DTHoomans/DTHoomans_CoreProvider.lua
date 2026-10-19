-- Core-backed provider adapter for the DTHoomans merchant body. Core owns the
-- actor snapshot and lease; this module only coordinates injected body hooks.

DTHoomans = DTHoomans or {}
DTHoomans.CoreProvider = DTHoomans.CoreProvider or {}

local Adapter = DTHoomans.CoreProvider

local function actors(core)
    return core and core.Actors
end

local function provider(core)
    local service = actors(core)
    return service and service.Provider
end

local function owner(spec)
    return type(spec) == "table" and spec.owner
        or "DTHoomans"
end

local function bodyID(body, spec)
    local value = type(spec) == "table" and (spec.bodyID or spec.bodyId)
        or nil
    if value ~= nil and tostring(value) ~= "" then return tostring(value) end
    if type(body) == "table" then
        value = body.bodyID or body.bodyId or body.id
        if value ~= nil and tostring(value) ~= "" then
            return tostring(value)
        end
    end
    return nil
end

function Adapter.Project(actor, core)
    local service = provider(core)
    if not service or type(service.Project) ~= "function" then
        return nil, "core_provider_unavailable"
    end
    return service.Project(actor, "DTHoomans")
end

function Adapter.Acquire(actor, core, spec)
    local service = provider(core)
    if not service or type(service.Acquire) ~= "function" then
        return nil, "core_provider_unavailable"
    end
    spec = type(spec) == "table" and spec or {}
    spec.provider = "DTHoomans"
    spec.owner = owner(spec)
    return service.Acquire(actor, spec)
end

function Adapter.Materialize(actor, core, spec)
    local service = provider(core)
    local projection
    local factory
    local body
    local id
    local nextActor
    local reason
    local cleanup
    if not service or type(service.Project) ~= "function"
        or type(service.Materialize) ~= "function"
    then
        return nil, "core_provider_unavailable"
    end
    spec = type(spec) == "table" and spec or {}
    projection, reason = service.Project(actor, "DTHoomans")
    if not projection then return nil, reason end
    factory = spec.bodyFactory or spec.spawn
    if type(factory) ~= "function" then return nil, "body_factory_required" end
    id, body = factory(projection, spec)
    if body == nil and type(id) == "table" then
        body = id
        id = nil
    end
    id = bodyID(body, { bodyID = id or spec.bodyID })
    if not id then return nil, "body_id_required" end

    local transition = {
        provider = "DTHoomans",
        owner = owner(spec),
        bodyID = id,
        now = spec.now,
    }
    nextActor, reason = service.Materialize(actor, transition)
    if not nextActor then
        cleanup = spec.cleanup or spec.destroy
        if type(cleanup) == "function" then cleanup(body, spec) end
        return nil, reason
    end
    if type(spec.applyProjection) == "function" then
        local applied = spec.applyProjection(body, projection, nextActor)
        if applied == false then
            cleanup = spec.cleanup or spec.destroy
            if type(cleanup) == "function" then cleanup(body, spec) end
            return nil, "body_projection_rejected"
        end
    end
    return {
        actor = nextActor,
        projection = service.Project(nextActor, "DTHoomans"),
        body = body,
        bodyID = id,
        leaseID = nextActor.providerLease.leaseID,
    }
end

function Adapter.Dematerialize(actor, core, spec)
    local service = provider(core)
    local projection
    local transition
    local nextActor
    local reason
    local body
    local cleanup
    if not service or type(service.Project) ~= "function"
        or type(service.Dematerialize) ~= "function"
    then
        return nil, "core_provider_unavailable"
    end
    spec = type(spec) == "table" and spec or {}
    projection, reason = service.Project(actor, "DTHoomans")
    if not projection then return nil, reason end
    body = spec.body
    if type(spec.persist) == "function" then
        local persisted = spec.persist(projection, body, spec)
        if persisted == false then return nil, "body_state_persist_failed" end
    end
    transition = {
        provider = "DTHoomans",
        owner = owner(spec),
        bodyID = spec.bodyID or projection.providerLease.bodyID,
        now = spec.now,
    }
    nextActor, reason = service.Dematerialize(actor, transition)
    if not nextActor then return nil, reason end
    cleanup = spec.cleanup or spec.destroy
    if type(cleanup) == "function" then cleanup(body, spec) end
    return {
        actor = nextActor,
        projection = service.Project(nextActor, "DTHoomans"),
        body = body,
        bodyID = transition.bodyID,
        leaseID = nextActor.providerLease.leaseID,
    }
end

function Adapter.Release(actor, core, spec)
    local service = provider(core)
    if not service or type(service.Release) ~= "function" then
        return nil, "core_provider_unavailable"
    end
    spec = type(spec) == "table" and spec or {}
    spec.provider = "DTHoomans"
    spec.owner = owner(spec)
    return service.Release(actor, spec)
end

return Adapter
