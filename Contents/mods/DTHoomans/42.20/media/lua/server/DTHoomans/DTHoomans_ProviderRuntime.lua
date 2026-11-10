-- Production physical-provider runtime for canonical DynamicTrading actors.
-- DTHoomans owns physical body/provider mechanics; DTCommon requests representation transitions.

DTHoomans = DTHoomans or {}
DTHoomans.ProviderRuntime = DTHoomans.ProviderRuntime or {}

local Runtime = DTHoomans.ProviderRuntime
local OWNER = "dthoomans:runtime"
local RETURN_OWNER = "dtcommon:trader_world"

local function worldAge()
    local time = getGameTime and getGameTime() or nil
    if time and type(time.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(time:getWorldAgeHours()) or 0)
    end
    return 0
end

local function actors()
    return PsychopatzCore and PsychopatzCore.Actors or nil
end

local function registry()
    local service = actors()
    return service and service.DefaultRegistry or nil
end

local function trader(traderID)
    if not DTCommon or not DTCommon.TraderService then return nil end
    return DTCommon.TraderService.GetRecord(tostring(traderID or ""))
end

local function adapter()
    return PNC and PNC.Persistence and PNC.Persistence.CoreProvider or nil
end

local function coreContext()
    return { Actors = actors() }
end

local function ensureHoomansRecord(actor, physicalProvider, position)
    if not PNC or not PNC.Registry or not PNC.Registry.Get
        or not PNC.Registry.AddRecord
    then
        return nil, false, "hoomans_registry_unavailable"
    end

    local existing = PNC.Registry.Get(actor.actorId)
    if existing then return existing, false end
    if not PNC.Types or type(PNC.Types.NewRecord) ~= "function"
        or type(physicalProvider.BuildRecord) ~= "function"
    then
        return nil, false, "hoomans_record_factory_unavailable"
    end

    local identity = actor.identity or {}
    local base = PNC.Types.NewRecord({
        id = actor.actorId,
        displayName = identity.displayName or tostring(actor.actorId),
        identitySeed = identity.identitySeed,
        identity = identity,
        appearance = actor.appearance,
        appearanceAuthored = actor.appearance ~= nil,
        archetypeID = identity.archetypeID or "core.actor",
        tacticalClass = "neutral",
        x = position.x,
        y = position.y,
        z = position.z or 0,
        persist = true,
    })
    if not base then return nil, false, "hoomans_record_create_failed" end

    local record, projectionReason = physicalProvider.BuildRecord(
        actor, coreContext(), base)
    if not record then
        return nil, false, projectionReason or "hoomans_projection_failed"
    end
    record.runtime = record.runtime or {}
    record.runtime.dtProviderProjection = true
    record.persist = true

    if PNC.Registry.AddRecord(record) ~= true then
        return nil, false, "hoomans_record_register_failed"
    end
    return record, true
end

local function releaseProviderProjection(actorID)
    if not PNC or not PNC.Registry or not PNC.Registry.Get then return false end
    local record = PNC.Registry.Get(actorID)
    if not record or not record.runtime
        or record.runtime.dtProviderProjection ~= true
    then
        return false
    end
    if PNC.Registry.RemoveRecord then
        PNC.Registry.RemoveRecord(actorID)
        return true
    end
    return false
end

local function bodyPosition(body, fallback)
    fallback = type(fallback) == "table" and fallback or { x = 0, y = 0, z = 0 }
    if body then
        local x = body.getX and tonumber(body:getX()) or nil
        local y = body.getY and tonumber(body:getY()) or nil
        local z = body.getZ and tonumber(body:getZ()) or nil
        if x and y then
            return { x = x, y = y, z = z or fallback.z or 0 }
        end
    end
    return {
        x = tonumber(fallback.x) or 0,
        y = tonumber(fallback.y) or 0,
        z = tonumber(fallback.z) or 0,
    }
end

local function commitProjectedLocation(reg, actor, now, explicit)
    local service = actors()
    if not service or not actor or not actor.world then
        return nil, "actor_world_unavailable"
    end
    local projected
    if type(explicit) == "table"
        and tonumber(explicit.x) ~= nil
        and tonumber(explicit.y) ~= nil
    then
        projected = {
            x = tonumber(explicit.x),
            y = tonumber(explicit.y),
            z = tonumber(explicit.z) or 0,
        }
    else
        projected = service.World.ProjectPosition(actor.world, now)
    end
    if not projected then return nil, "actor_position_unavailable" end

    local nextWorld, reason = service.World.NewState(
        actor.world, actor.actorId, now)
    if not nextWorld then return nil, reason end
    local nextLocation
    nextLocation, reason = service.Location.SetPosition(
        nextWorld.location, projected, nextWorld.location.revision)
    if not nextLocation then return nil, reason end
    nextWorld.location = nextLocation
    nextWorld.revision = (tonumber(actor.world.revision) or 0) + 1

    return reg:Commit(actor.actorId, { world = nextWorld }, actor.revision)
end

local function setReturnProvider(record, providerID)
    if not record or not record.ca then return false end
    record.ca.returnProviderID = providerID
        and tostring(providerID) ~= "" and tostring(providerID) or nil
    if DTCommon.TraderStock and DTCommon.TraderStock.SaveAndTransmit then
        DTCommon.TraderStock.SaveAndTransmit()
    end
    return true
end

local function syncPolicy(record, actor)
    if not record or not actor or not actor.providerLease then return false end
    local Policy = DTCommon and DTCommon.CoreActorPolicy
        or require "DTCommon/DTCommon_CoreActorPolicy"
    local policy, reason = Policy.SetProviderLease(record, actor.providerLease)
    if not policy then return false, reason end
    if DTCommon.TraderStock and DTCommon.TraderStock.SaveAndTransmit then
        DTCommon.TraderStock.SaveAndTransmit()
    end
    return true
end

function Runtime.MaterializeTrader(traderID, options)
    options = type(options) == "table" and options or {}
    local record = trader(traderID)
    if not record or not record.ca then return nil, "trader_not_found" end

    local reg = registry()
    local service = actors()
    local provider = adapter()
    if not reg or not service then return nil, "core_actor_unavailable" end
    if not provider or type(provider.Materialize) ~= "function" then
        return nil, "physical_provider_unavailable"
    end

    local actorID = record.ca.actorID
    local current = actorID and reg:Get(actorID) or nil
    if not current then return nil, "core_actor_not_found" end

    local now = tonumber(options.now) or worldAge()
    local lease = current.providerLease or {}
    local returnProviderID = tostring(
        options.returnProviderID
            or record.ca.returnProviderID
            or lease.provider
            or "")
    if returnProviderID == "" or returnProviderID == "DTHoomans" then
        return nil, "return_provider_unavailable"
    end
    if lease.provider == "DTHoomans" and lease.state == "materialized" then
        return current, "already_materialized"
    end
    if lease.state ~= "abstract" then
        return nil, "actor_not_abstract"
    end

    -- Freeze the live spawn point at the current canonical journey projection
    -- before switching provider ownership.
    local positioned, reason = commitProjectedLocation(
        reg,
        current,
        now,
        options.position
    )
    if not positioned then return nil, reason end
    current = positioned

    setReturnProvider(record, returnProviderID)

    local switched
    switched, reason = reg:SwitchProvider(actorID, {
        provider = "DTHoomans",
        owner = OWNER,
        handoffFrom = lease.owner or RETURN_OWNER,
        authority = "server",
        now = now,
    })
    if not switched then
        setReturnProvider(record, nil)
        return nil, reason
    end

    local projectedPosition = service.World.ProjectPosition(
        switched.world, now)
    local hoomansRecord, adopted
    hoomansRecord, adopted, reason = ensureHoomansRecord(
        switched, provider, projectedPosition)
    if not hoomansRecord then
        reg:SwitchProvider(actorID, {
            provider = returnProviderID,
            owner = RETURN_OWNER,
            handoffFrom = OWNER,
            authority = "server",
            now = now,
        })
        setReturnProvider(record, nil)
        return nil, reason
    end

    local result
    result, reason = provider.Materialize(
        switched, coreContext(), {
            provider = "DTHoomans",
            owner = OWNER,
            authority = "server",
            now = now,
            position = projectedPosition,
            record = hoomansRecord,
            reason = options.reason or "dt_handoff_materialize",
            registerBody = true,
        })
    if not result then
        if adopted then releaseProviderProjection(actorID) end
        -- Roll provider ownership back so a failed body spawn cannot strand
        -- the trader in a DTHoomans abstract lease.
        reg:SwitchProvider(actorID, {
            provider = returnProviderID,
            owner = RETURN_OWNER,
            handoffFrom = OWNER,
            authority = "server",
            now = now,
        })
        setReturnProvider(record, nil)
        return nil, reason
    end

    local committed
    committed, reason = reg:Commit(actorID, {
        providerLease = result.actor.providerLease,
    }, switched.revision)
    if not committed then
        pcall(provider.Dematerialize, result.actor, coreContext(), {
            owner = OWNER,
            authority = "server",
            now = now,
            body = result.body,
            bodyID = result.bodyID
                or (result.actor.providerLease
                    and result.actor.providerLease.bodyID),
            reason = "dt_materialize_commit_rollback",
        })
        if adopted then releaseProviderProjection(actorID) end
        reg:SwitchProvider(actorID, {
            provider = returnProviderID,
            owner = RETURN_OWNER,
            handoffFrom = OWNER,
            authority = "server",
            now = now,
        })
        setReturnProvider(record, nil)
        return nil, reason
    end

    syncPolicy(record, committed)
    if DTCommon.TraderService.BindPhysical then
        DTCommon.TraderService.BindPhysical(traderID, actorID)
    end
    return committed, result
end

local function rebaseWorldFromBody(actor, body, now)
    local service = actors()
    local fallback = service.World.ProjectPosition(actor.world, now)
    local position = bodyPosition(body, fallback)
    local oldJourney = actor.world and actor.world.journey or nil

    local nextWorld, reason = service.World.NewState(
        actor.world, actor.actorId, now)
    if not nextWorld then return nil, reason end
    local nextLocation
    nextLocation, reason = service.Location.SetPosition(
        nextWorld.location, position, nextWorld.location.revision)
    if not nextLocation then return nil, reason end
    nextWorld.location = nextLocation

    if oldJourney and service.Journey.ACTIVE_STATES[oldJourney.state] then
        nextWorld, reason = service.World.StartJourney(
            nextWorld, actor.actorId, {
                journeyID = oldJourney.journeyID,
                ownerMod = oldJourney.ownerMod,
                ownerRef = oldJourney.ownerRef,
                mode = "abstract",
                origin = position,
                destination = oldJourney.destination,
                destinationAnchorID = oldJourney.destinationAnchorID,
                speed = oldJourney.speed,
                startAt = now,
                arrivalRadius = oldJourney.arrivalRadius,
                arrivalAction = oldJourney.arrivalAction,
                metadata = oldJourney.metadata,
            }, now)
        if not nextWorld then return nil, reason end
    else
        nextWorld.revision = (tonumber(actor.world.revision) or 0) + 1
    end
    return nextWorld
end

function Runtime.DematerializeTrader(traderID, options)
    options = type(options) == "table" and options or {}
    local record = trader(traderID)
    if not record or not record.ca then return nil, "trader_not_found" end

    local reg = registry()
    local provider = adapter()
    if not reg then return nil, "core_actor_unavailable" end
    if not provider or type(provider.Dematerialize) ~= "function" then
        return nil, "physical_provider_unavailable"
    end

    local actorID = record.ca.actorID
    local current = actorID and reg:Get(actorID) or nil
    if not current then return nil, "core_actor_not_found" end
    local lease = current.providerLease or {}
    if lease.provider ~= "DTHoomans" then
        return nil, "provider_mismatch"
    end
    if lease.state ~= "materialized" then
        return nil, "actor_not_materialized"
    end

    local returnProviderID = tostring(
        options.returnProviderID
            or record.ca.returnProviderID
            or "")
    if returnProviderID == "" or returnProviderID == "DTHoomans" then
        return nil, "return_provider_unavailable"
    end

    local now = tonumber(options.now) or worldAge()
    local liveBody = PNC and PNC.Registry and PNC.Registry.GetLiveZombie
        and PNC.Registry.GetLiveZombie(actorID) or nil
    local capturedPosition = bodyPosition(
        liveBody, actors().World.ProjectPosition(current.world, now))

    local result, reason = provider.Dematerialize(
        current, coreContext(), {
            provider = "DTHoomans",
            owner = OWNER,
            authority = "server",
            now = now,
            body = liveBody,
            bodyID = lease.bodyID,
            reason = options.reason or "dt_handoff_dematerialize",
        })
    if not result then return nil, reason end

    local dematerialized
    dematerialized, reason = reg:Commit(actorID, {
        providerLease = result.actor.providerLease,
        personalInventory = result.actor.personalInventory,
    }, current.revision)
    if not dematerialized then return nil, reason end

    -- Rebase remaining route from the physical body's actual final position.
    local nextWorld
    nextWorld, reason = rebaseWorldFromBody(
        dematerialized, {
            getX = function() return capturedPosition.x end,
            getY = function() return capturedPosition.y end,
            getZ = function() return capturedPosition.z end,
        }, now)
    if not nextWorld then return nil, reason end
    local rebased
    rebased, reason = reg:Commit(actorID, {
        world = nextWorld,
    }, dematerialized.revision)
    if not rebased then return nil, reason end

    local resumed
    resumed, reason = reg:SwitchProvider(actorID, {
        provider = returnProviderID,
        owner = RETURN_OWNER,
        handoffFrom = OWNER,
        authority = "server",
        now = now,
    })
    if not resumed then return nil, reason end

    syncPolicy(record, resumed)
    setReturnProvider(record, nil)
    if DTCommon.TraderService.ClearPhysical then
        DTCommon.TraderService.ClearPhysical(traderID)
    end
    releaseProviderProjection(actorID)
    if type(result) ~= "table" then result = {} end
    result.position = capturedPosition
    return resumed, result
end

function Runtime.RecoverMissingBody(traderID, options)
    options = type(options) == "table" and options or {}
    local record = trader(traderID)
    if not record or not record.ca then return nil, "trader_not_found" end

    local reg = registry()
    local service = actors()
    if not reg or not service then return nil, "core_actor_unavailable" end

    local actorID = record.ca.actorID
    local current = actorID and reg:Get(actorID) or nil
    if not current then return nil, "core_actor_not_found" end

    local lease = current.providerLease or {}
    if lease.provider ~= "DTHoomans"
        or lease.state ~= "materialized"
    then
        return nil, "actor_not_materialized"
    end

    local liveBody = PNC and PNC.Registry and PNC.Registry.GetLiveZombie
        and PNC.Registry.GetLiveZombie(actorID) or nil
    if liveBody then return current, "body_present" end

    local hoomansRecord = PNC and PNC.Registry and PNC.Registry.Get
        and PNC.Registry.Get(actorID) or nil
    if not hoomansRecord or not hoomansRecord.runtime
        or hoomansRecord.runtime.dtProviderProjection ~= true
    then
        return nil, "provider_projection_unavailable"
    end

    local lifecycle = hoomansRecord.runtime.lifecycle or {}
    if hoomansRecord.runtime.restoredBodyRebindPending == true
        or lifecycle.phase == "live"
        or lifecycle.bodyState == "bound"
    then
        return nil, "body_rebind_pending"
    end
    if lifecycle.phase ~= "abstract"
        or lifecycle.bodyState ~= "missing"
    then
        return nil, "body_state_not_reconciled"
    end

    local returnProviderID = tostring(
        options.returnProviderID
            or record.ca.returnProviderID
            or "")
    if returnProviderID == "" or returnProviderID == "DTHoomans" then
        return nil, "return_provider_unavailable"
    end

    local provider = adapter()
    local capturedInventory
    local now = tonumber(options.now) or worldAge()
    if provider and type(provider.CaptureInventory) == "function" then
        capturedInventory, _, reason =
            provider.CaptureInventory(current, hoomansRecord)
        if not capturedInventory then
            return nil, reason or "core_inventory_capture_failed"
        end
    else
        capturedInventory = current.personalInventory
    end

    local dematerialized, reason = service.Provider.Dematerialize(current, {
        provider = "DTHoomans",
        owner = OWNER,
        bodyID = lease.bodyID,
        authority = "server",
        now = now,
    })
    if not dematerialized then return nil, reason end

    local committed
    committed, reason = reg:Commit(actorID, {
        providerLease = dematerialized.providerLease,
        personalInventory = capturedInventory,
    }, current.revision)
    if not committed then return nil, reason end

    local resumed
    resumed, reason = reg:SwitchProvider(actorID, {
        provider = returnProviderID,
        owner = RETURN_OWNER,
        handoffFrom = OWNER,
        authority = "server",
        now = now,
    })
    if not resumed then return nil, reason end

    syncPolicy(record, resumed)
    setReturnProvider(record, nil)
    if DTCommon.TraderService.ClearPhysical then
        DTCommon.TraderService.ClearPhysical(traderID)
    end
    releaseProviderProjection(actorID)
    return resumed, "recovered_missing_body"
end

function Runtime.GetPosition(traderID, now)
    local record = trader(traderID)
    if not record or not record.ca then return nil, "trader_not_found" end
    local reg = registry()
    local actorID = record.ca.actorID
    local actor = reg and actorID and reg:Get(actorID) or nil
    if not actor then return nil, "core_actor_not_found" end

    local lease = actor.providerLease or {}
    if lease.provider == "DTHoomans" and lease.state == "materialized"
        and PNC and PNC.Registry and PNC.Registry.GetLiveZombie
    then
        local body = PNC.Registry.GetLiveZombie(actorID)
        if body then return bodyPosition(body) end
    end
    return actors().World.ProjectPosition(actor.world, now)
end

Runtime.OWNER = OWNER
Runtime.RETURN_OWNER = RETURN_OWNER

return Runtime
