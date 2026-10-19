-- Optional Core provider adapter. DTAbstract owns no actor identity or body;
-- it only requests a Core-owned projection and lease transition.

DTAbstract = DTAbstract or {}
DTAbstract.CoreProvider = DTAbstract.CoreProvider or {}

local Adapter = DTAbstract.CoreProvider

local function actors(core)
    return core and core.Actors
end

local function provider(core)
    local service = actors(core)
    return service and service.Provider
end

local function owner(spec)
    return type(spec) == "table" and spec.owner
        or "DTAbstract"
end

function Adapter.Project(actor, core)
    local service = provider(core)
    if not service or type(service.Project) ~= "function" then
        return nil, "core_provider_unavailable"
    end
    return service.Project(actor, "DTAbstract")
end

function Adapter.Acquire(actor, core, spec)
    local service = provider(core)
    if not service or type(service.Acquire) ~= "function" then
        return nil, "core_provider_unavailable"
    end
    spec = type(spec) == "table" and spec or {}
    spec.provider = "DTAbstract"
    spec.owner = owner(spec)
    return service.Acquire(actor, spec)
end

function Adapter.Materialize(actor, core, spec)
    local service = provider(core)
    if not service or type(service.Materialize) ~= "function" then
        return nil, "core_provider_unavailable"
    end
    spec = type(spec) == "table" and spec or {}
    spec.provider = "DTAbstract"
    spec.owner = owner(spec)
    return service.Materialize(actor, spec)
end

function Adapter.Dematerialize(actor, core, spec)
    local service = provider(core)
    if not service or type(service.Dematerialize) ~= "function" then
        return nil, "core_provider_unavailable"
    end
    spec = type(spec) == "table" and spec or {}
    spec.provider = "DTAbstract"
    spec.owner = owner(spec)
    return service.Dematerialize(actor, spec)
end

function Adapter.Release(actor, core, spec)
    local service = provider(core)
    if not service or type(service.Release) ~= "function" then
        return nil, "core_provider_unavailable"
    end
    spec = type(spec) == "table" and spec or {}
    spec.provider = "DTAbstract"
    spec.owner = owner(spec)
    return service.Release(actor, spec)
end

return Adapter
