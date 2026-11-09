-- One trader-faction generation contract for both Dynamic Trading providers.
-- Core owns the bodyless canonical actor path. A physical adopter registers the
-- materialization path; the contract keeps that difference in presenceMode.

DTCommon = DTCommon or {}
DTCommon.TraderGeneration = DTCommon.TraderGeneration or {}

local Generation = DTCommon.TraderGeneration
local Presets = require "DTCommon/DTCommon_TraderPresets"
local ActorSystem = require "PsychopatzCore/Actors/PsychopatzActors"
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

function Generation.CreateCanonicalActors(spec, memberPlan)
    spec = type(spec) == "table" and spec or {}
    memberPlan = type(memberPlan) == "table" and memberPlan or {}
    local registry = spec.actorRegistry or ActorSystem.DefaultRegistry
    local position = type(spec.position) == "table" and spec.position or {}
    local createdActorIDs = {}
    local memberSpecs = memberPlan.memberSpecs or {}
    local actorIDs = memberPlan.actorIDs or {}
    local created = {}
    local index
    local member
    local actor
    local reason
    local extensions

    if not registry or type(registry.Create) ~= "function" then
        return nil, "actor_registry_unavailable"
    end
    for index = 1, #memberSpecs do
        member = memberSpecs[index]
        if type(member) ~= "table" or not member.actorID then
            for _, actorID in ipairs(createdActorIDs) do
                registry:Remove(actorID)
            end
            return nil, "trader_member_spec_invalid"
        end
        if registry:Get(member.actorID) then
            for _, actorID in ipairs(createdActorIDs) do
                registry:Remove(actorID)
            end
            return nil, "canonical_actor_id_collision"
        end
        extensions = {}
        for extensionID, extensionValue in pairs(member.extensions or {}) do
            extensions[extensionID] = extensionValue
        end
        local actorExtensions = memberPlan.actorExtensions
            and memberPlan.actorExtensions[index] or nil
        for extensionID, extensionValue in pairs(actorExtensions or {}) do
            if extensions[extensionID] == nil then
                extensions[extensionID] = extensionValue
            end
        end
        extensions["dynamictrading.traderPreset"] = {
            schemaVersion = tonumber(member.schemaVersion) or 1,
            presetID = member.presetID,
            role = member.role,
            visualProfile = member.visualProfile,
        }
        actor, reason = registry:Create({
            actorId = member.actorID,
            identitySeed = member.identitySeed,
            identity = member.identity,
            archetypeID = member.coreArchetypeID
                or member.archetypeID or "core.survivor",
            ownerMod = "DynamicTrading",
            appearance = member.appearance,
            starterItems = member.startingItems,
            world = {
                position = {
                    x = tonumber(position.x) or 0,
                    y = tonumber(position.y) or 0,
                    z = tonumber(position.z) or 0,
                },
            },
            extensions = extensions,
            source = member.source,
        })
        if not actor then
            for _, actorID in ipairs(createdActorIDs) do
                registry:Remove(actorID)
            end
            return nil, reason or "canonical_actor_create_failed"
        end
        member.identity = actor.identity
        member.personalInventory = actor.personalInventory
        member.coreActorID = actor.actorId
        actorIDs[index] = actor.actorId
        createdActorIDs[#createdActorIDs + 1] = actor.actorId
        created[#created + 1] = actor
    end
    return {
        schemaVersion = Presets.SCHEMA_VERSION,
        actorIDs = actorIDs,
        memberSpecs = memberSpecs,
        actors = created,
        createdActorIDs = createdActorIDs,
    }, "canonical_actors_created"
end

function Generation.RemoveCanonicalActors(result)
    if type(result) ~= "table" then return false end
    local registry = result.actorRegistry or ActorSystem.DefaultRegistry
    if not registry or type(registry.Remove) ~= "function" then return false end
    for _, actorID in ipairs(result.createdActorIDs or {}) do
        registry:Remove(actorID)
    end
    return true
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
