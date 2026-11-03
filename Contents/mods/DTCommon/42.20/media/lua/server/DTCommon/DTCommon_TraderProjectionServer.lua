-- Provider-agnostic authoritative trader actor projection.
-- DTCommon owns the canonical trader-world feed; presentation adapters consume
-- the bounded PsychopatzCore projection on clients.

DTCommon = DTCommon or {}
DTCommon.TraderProjectionServer =
    DTCommon.TraderProjectionServer or {}

local Bridge = DTCommon.TraderProjectionServer
local Providers = DTCommon.TraderProviders
    or require "DTCommon/DTCommon_TraderProviderRegistry"
local Projection =
    require "PsychopatzCore/Actors/PsychopatzActorProjection"
local Sync =
    require "PsychopatzCore/Actors/PsychopatzActorProjectionServer"

Bridge.SOURCE_ID = "DynamicTrading"

local function worldAge()
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and type(gameTime.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(gameTime:getWorldAgeHours()) or 0)
    end
    return 0
end

local function defaultRegistry()
    local actors = PsychopatzCore and PsychopatzCore.Actors or nil
    return actors and actors.DefaultRegistry or nil
end

local function registryFor(record)
    local ca = record and record.ca or nil
    local providerID = ca and (ca.provider or ca.coreProvider) or nil
    local provider = providerID and Providers.Get(providerID) or nil
    if provider and type(provider.getActorRegistry) == "function" then
        local ok, registry = pcall(provider.getActorRegistry)
        if ok and registry then return registry end
    end
    return defaultRegistry()
end

function Bridge.BuildEntries()
    local output = {}
    local service = DTCommon and DTCommon.TraderService or nil
    if not service or type(service.ForEach) ~= "function" then
        return output
    end

    local now = worldAge()
    service.ForEach(function(traderID, record)
        local ca = record and record.ca or nil
        local actorID = ca and (ca.actorID or ca.coreActorID) or nil
        if not actorID then return end

        local registry = registryFor(record)
        local actor = registry and registry:Get(actorID) or nil
        if not actor then return end

        local lease = actor.providerLease or {}
        local providerID =
            ca.provider or ca.coreProvider or lease.provider
        local provider = providerID and Providers.Get(providerID) or nil
        local projected = Projection.ProjectActor(actor, now, {
            sourceID = Bridge.SOURCE_ID,
            provider = providerID,
            providerState = ca.providerState
                or ca.coreProviderState or lease.state,
            bodyID = ca.providerBodyID
                or ca.coreProviderBodyID or lease.bodyID,
        })
        if projected and provider
            and type(provider.getPosition) == "function"
        then
            local ok, position = pcall(
                provider.getPosition, traderID, record, now)
            if ok and type(position) == "table"
                and tonumber(position.x) and tonumber(position.y)
            then
                projected.position = {
                    x = tonumber(position.x),
                    y = tonumber(position.y),
                    z = tonumber(position.z) or 0,
                }
            end
            if provider.kind == "physical" then
                projected.journey = nil
            end
        end
        if projected then output[#output + 1] = projected end
    end)
    return output
end

function Bridge.Publish()
    return Sync.Broadcast(Bridge.SOURCE_ID)
end

Sync.RegisterProvider(Bridge.SOURCE_ID, {
    BuildEntries = Bridge.BuildEntries,
})

local world = DTCommon and DTCommon.TraderWorld or nil
if world and type(world.RegisterChangeListener) == "function" then
    world.RegisterChangeListener(
        "DTCommon:trader_projection",
        function() Bridge.Publish() end
    )
end

return Bridge
