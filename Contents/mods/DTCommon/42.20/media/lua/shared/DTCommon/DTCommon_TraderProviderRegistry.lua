-- Provider-agnostic representation registry for the canonical trader world.
-- DTCommon owns commercial lifecycle; adopters register how a trader is
-- represented and how movement is executed in that representation.

DTCommon = DTCommon or {}
DTCommon.TraderProviders = DTCommon.TraderProviders or {}

local Registry = DTCommon.TraderProviders

Registry.ByID = Registry.ByID or {}
Registry.Revision = Registry.Revision or 0
Registry.MAX_PROVIDERS = 16
Registry.MAX_ID_LENGTH = 64

local function providerID(value)
    value = tostring(value or "")
    if value == "" then return nil end
    if #value > Registry.MAX_ID_LENGTH then
        value = string.sub(value, 1, Registry.MAX_ID_LENGTH)
    end
    return value
end

local function count()
    local total = 0
    for _ in pairs(Registry.ByID) do total = total + 1 end
    return total
end

function Registry.Register(id, definition)
    id = providerID(id)
    if not id or type(definition) ~= "table" then
        return false, "invalid_provider"
    end
    if not Registry.ByID[id] and count() >= Registry.MAX_PROVIDERS then
        return false, "provider_capacity_exceeded"
    end

    local previous = Registry.ByID[id]
    local copy = {}
    if previous then
        for key, value in pairs(previous) do copy[key] = value end
    end
    for key, value in pairs(definition) do copy[key] = value end
    copy.id = id
    copy.priority = tonumber(copy.priority) or 0
    copy.enabled = copy.enabled ~= false

    Registry.ByID[id] = copy
    Registry.Revision = Registry.Revision + 1
    return true, previous and "provider_updated" or "provider_registered", copy
end

function Registry.Unregister(id)
    id = providerID(id)
    if not id or not Registry.ByID[id] then return false end
    Registry.ByID[id] = nil
    Registry.Revision = Registry.Revision + 1
    return true
end

function Registry.Get(id)
    id = providerID(id)
    return id and Registry.ByID[id] or nil
end

function Registry.IsKnown(id)
    id = providerID(id)
    return id ~= nil and Registry.ByID[id] ~= nil
end

function Registry.List()
    local output = {}
    for _, definition in pairs(Registry.ByID) do
        output[#output + 1] = definition
    end
    table.sort(output, function(left, right)
        if left.priority ~= right.priority then
            return left.priority > right.priority
        end
        return tostring(left.id) < tostring(right.id)
    end)
    return output
end

local function available(definition, context)
    if not definition or definition.enabled == false then return false end
    if type(definition.isAvailable) == "function" then
        local ok, value = pcall(definition.isAvailable, context)
        return ok and value == true
    end
    return true
end

function Registry.Select(capability, context)
    capability = tostring(capability or "")
    local candidates = {}
    for _, definition in ipairs(Registry.List()) do
        if available(definition, context)
            and (capability == "" or type(definition[capability]) == "function")
        then
            candidates[#candidates + 1] = definition
        end
    end
    table.sort(candidates, function(left, right)
        local field = capability ~= "" and (capability .. "Priority") or nil
        local leftPriority = tonumber(field and left[field]) or left.priority or 0
        local rightPriority = tonumber(field and right[field]) or right.priority or 0
        if leftPriority ~= rightPriority then
            return leftPriority > rightPriority
        end
        return tostring(left.id) < tostring(right.id)
    end)
    return candidates[1]
end

function Registry.Call(id, capability, ...)
    local definition = Registry.Get(id)
    if not definition then return nil, "provider_not_found" end
    if not available(definition, { capability = capability }) then
        return nil, "provider_unavailable"
    end
    local fn = definition[capability]
    if type(fn) ~= "function" then
        return nil, "provider_capability_unavailable"
    end
    return fn(...)
end

-- Core is a valid lease identity for existing generic actors even when no DT
-- representation adapter is active. Adopters register their provider IDs
-- from their own shared init.
Registry.Register("PsychopatzCore", {
    kind = "core",
    priority = -1000,
})

return Registry
