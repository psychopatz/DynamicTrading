-- One trader-faction generation contract for both Dynamic Trading providers.
-- Core owns the bodyless canonical actor path. A physical adopter registers the
-- materialization path; the contract keeps that difference in presenceMode.

DTCommon = DTCommon or {}
DTCommon.TraderGeneration = DTCommon.TraderGeneration or {}

local Generation = DTCommon.TraderGeneration
Generation.Adapters = Generation.Adapters or {}
Generation.MAX_ADAPTERS = 8
Generation.PRESENCE_ABSTRACT = "abstract"
Generation.PRESENCE_LIVE = "live"
Generation.PRESENCE_AUTO = "auto"

local function providerID(value)
    value = tostring(value or "")
    if value == "" then return nil end
    if #value > 64 then value = string.sub(value, 1, 64) end
    return value
end

local function copySpec(spec)
    local copy = {}
    for key, value in pairs(spec) do copy[key] = value end
    return copy
end

local function normalize(spec)
    if type(spec) ~= "table" then return nil, "generation_spec_missing" end
    local copy = copySpec(spec)
    local presence = tostring(copy.presenceMode or
        Generation.PRESENCE_ABSTRACT)
    presence = string.lower(presence)
    if presence ~= Generation.PRESENCE_ABSTRACT
        and presence ~= Generation.PRESENCE_LIVE
        and presence ~= Generation.PRESENCE_AUTO
    then
        return nil, "unsupported_presence_mode"
    end
    local id = providerID(copy.providerID or copy.provider)
    if presence ~= Generation.PRESENCE_ABSTRACT and not id then
        return nil, "provider_missing"
    end
    copy.providerID = id or "DTAbstract"
    copy.presenceMode = presence
    return copy
end

function Generation.RegisterProvider(id, adapter)
    id = providerID(id)
    if not id or type(adapter) ~= "table"
        or type(adapter.GenerateForFaction) ~= "function"
    then
        return false, "invalid_generation_provider"
    end
    if not Generation.Adapters[id]
        and (tonumber(Generation.AdapterCount) or 0) >= Generation.MAX_ADAPTERS
    then
        return false, "generation_provider_capacity_exceeded"
    end
    Generation.Adapters[id] = adapter
    Generation.AdapterCount = 0
    for _ in pairs(Generation.Adapters) do
        Generation.AdapterCount = Generation.AdapterCount + 1
    end
    return true, "generation_provider_registered"
end

function Generation.UnregisterProvider(id)
    id = providerID(id)
    if not id or not Generation.Adapters[id] then return false end
    Generation.Adapters[id] = nil
    Generation.AdapterCount = math.max(0,
        (tonumber(Generation.AdapterCount) or 1) - 1)
    return true
end

local function abstractGeneration(spec)
    local ok
    local Factory
    local first
    local second
    local third
    ok, Factory = pcall(require,
        "DTCommon/DTCommon_CoreTraderCandidateFactory")
    if not ok or type(Factory) ~= "table"
        or type(Factory.Create) ~= "function"
    then
        return nil, "abstract_generation_unavailable"
    end
    ok, first, second, third = pcall(Factory.Create, spec)
    if not ok then return nil, "abstract_generation_exception" end
    return first, second, third
end

function Generation.GenerateForFaction(spec)
    local normalized, reason = normalize(spec)
    local adapter
    local ok
    local first
    local second
    local third
    if not normalized then return nil, reason end
    if normalized.presenceMode == Generation.PRESENCE_ABSTRACT then
        return abstractGeneration(normalized)
    end
    adapter = Generation.Adapters[normalized.providerID]
    if not adapter or type(adapter.GenerateForFaction) ~= "function" then
        return nil, "provider_generation_unavailable"
    end
    ok, first, second, third = pcall(
        adapter.GenerateForFaction, normalized)
    if not ok then return nil, "provider_generation_exception" end
    return first, second, third
end

return Generation
