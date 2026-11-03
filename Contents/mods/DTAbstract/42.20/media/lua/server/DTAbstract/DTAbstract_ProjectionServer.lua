-- Bridges authoritative DTAbstract Core actors into the generic bounded
-- PsychopatzCore client presentation projection.

DTAbstract = DTAbstract or {}
DTAbstract.ProjectionServer = DTAbstract.ProjectionServer or {}

local Bridge = DTAbstract.ProjectionServer
local Lifecycle = DTAbstract.Lifecycle
local Projection = require "PsychopatzCore/Actors/PsychopatzActorProjection"
local Sync = require "PsychopatzCore/Actors/PsychopatzActorProjectionServer"

Bridge.SOURCE_ID = "DTAbstract"

local function worldAge()
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and type(gameTime.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(gameTime:getWorldAgeHours()) or 0)
    end
    return 0
end

function Bridge.BuildEntries()
    local output = {}
    local registry = Lifecycle and Lifecycle.GetActorRegistry
        and Lifecycle.GetActorRegistry() or nil
    if not registry or not DTCommon or not DTCommon.TraderService then
        return output
    end

    local now = worldAge()
    DTCommon.TraderService.ForEach(function(traderID, record)
        local ca = record and record.ca or nil
        local provider = ca and (ca.provider or ca.coreProvider) or nil
        if ca and (provider == "DTAbstract" or provider == "DTHoomans") then
            local actorID = ca.actorID or ca.coreActorID
            local actor = actorID and registry:Get(actorID) or nil
            if actor then
                local projected = Projection.ProjectActor(actor, now, {
                    sourceID = Bridge.SOURCE_ID,
                    provider = provider,
                    providerState = ca.providerState
                        or ca.coreProviderState
                        or (actor.providerLease
                            and actor.providerLease.state),
                    bodyID = ca.providerBodyID
                        or ca.coreProviderBodyID
                        or (actor.providerLease
                            and actor.providerLease.bodyID),
                })
                if projected then output[#output + 1] = projected end
            end
        end
    end)
    return output
end

function Bridge.Publish()
    return Sync.Broadcast(Bridge.SOURCE_ID)
end

Sync.RegisterProvider(Bridge.SOURCE_ID, {
    BuildEntries = Bridge.BuildEntries,
})

return Bridge
