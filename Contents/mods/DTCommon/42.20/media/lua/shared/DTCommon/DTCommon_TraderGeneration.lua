-- One trader-faction generation contract for DynamicTrading.
--
-- Core owns the canonical generation transaction. Providers only represent
-- the committed actors; they do not create an alternate actor/group pipeline.

DTCommon = DTCommon or {}
DTCommon.TraderGeneration = DTCommon.TraderGeneration or {}

local Generation = DTCommon.TraderGeneration
local Presets = require "DTCommon/DTCommon_TraderPresets"
if Presets.RegisterCoreArchetypes then
    Presets.RegisterCoreArchetypes()
end
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

function Generation.BuildMemberSpecs(spec)
    return Presets.BuildMembers(spec)
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

-- The only DynamicTrading generation entry point. It asks Core to plan and
-- commit the complete group, including member identities and actor records.
-- A representation provider may subsequently materialize the returned actor
-- IDs, but it cannot create a second canonical roster.
function Generation.GenerateCanonicalGroup(spec)
    local normalized, reason = normalize(spec)
    if not normalized then return nil, reason end

    local Factory = require "DTCommon/DTCommon_CoreTraderCandidateFactory"
    if type(Factory) ~= "table"
        or type(Factory.Create) ~= "function"
    then
        return nil, "canonical_generation_unavailable"
    end
    return Factory.Create(normalized)
end

function Generation.RemoveCanonicalGroup(result)
    if type(result) ~= "table" then return false end
    local groupID = tostring(result.groupID or "")
    local adapter = PNC and PNC.CoreSurvivorWorldAdapter or nil
    local SurvivorWorld = require
        "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorld"
    local world = SurvivorWorld.GetRuntimeRegistry()
    local removed = false
    if groupID ~= "" and adapter
        and type(adapter.RemoveGroup) == "function"
    then
        removed = adapter.RemoveGroup(
            groupID,
            "dynamic_trading_generation_rollback"
        ) == true
    elseif groupID ~= "" and world
        and type(world.RemoveGroup) == "function"
    then
        removed = world:RemoveGroup(groupID) == true
    end

    local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
    local registry = Actors and Actors.DefaultRegistry or nil
    if registry and type(registry.Remove) == "function" then
        for _, actorID in ipairs(result.createdActorIDs or {}) do
            registry:Remove(actorID)
            removed = true
        end
    end
    return removed
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
    return Generation.GenerateCanonicalGroup(spec)
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
