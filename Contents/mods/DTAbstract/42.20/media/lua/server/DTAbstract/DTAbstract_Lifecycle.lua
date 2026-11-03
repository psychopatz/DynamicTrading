-- Server-authoritative standalone abstract trader lifecycle and director.
--
-- DynamicTrading owns trader stock, budgets and commerce; DTAbstract owns the
-- standalone abstract trader population policy and travel progression.
-- PsychopatzCore owns actor identity, provider leases and journey progression.

if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

DTAbstract = DTAbstract or {}
DTAbstract.Lifecycle = DTAbstract.Lifecycle or {}

local Lifecycle = DTAbstract.Lifecycle

Lifecycle.MAX_ABSTRACT_TRADERS = 2
Lifecycle.INTERVAL_HOURS = 1
Lifecycle.DEFAULT_SPEED = 60
Lifecycle.COOLDOWN_HOURS_AT_SETTLEMENT = 4

local nextAttemptAt = 0
local lastSummary = { activeCount = 0, spawned = 0, advanced = 0, arrived = 0 }
local customActorRegistry = nil

local function isAuthority()
    if DTCommon and DTCommon.Storage and type(DTCommon.Storage.IsAuthority) == "function" then
        return DTCommon.Storage.IsAuthority() == true
    end
    if PsychopatzCore and PsychopatzCore.RuntimeRole
        and type(PsychopatzCore.RuntimeRole.AllowsServerCode) == "function"
    then
        return PsychopatzCore.RuntimeRole.AllowsServerCode() == true
    end
    return not (isClient and isClient() == true)
end

local function worldAge()
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and type(gameTime.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(gameTime:getWorldAgeHours()) or 0)
    end
    return 0
end

local function getActors()
    if PsychopatzCore and PsychopatzCore.Actors then
        return PsychopatzCore.Actors
    end
    local ok, actors = pcall(require, "PsychopatzCore/Actors/PsychopatzActors")
    if ok and actors then return actors end
    return nil
end

local function getActorRegistry()
    if customActorRegistry then return customActorRegistry end
    local actors = getActors()
    if actors and actors.DefaultRegistry then
        return actors.DefaultRegistry
    end
    if actors and type(actors.NewRegistry) == "function" then
        customActorRegistry = actors.NewRegistry()
        return customActorRegistry
    end
    return nil
end

function Lifecycle.SetActorRegistry(registry)
    customActorRegistry = registry
end

function Lifecycle.GetActorRegistry()
    return getActorRegistry()
end

function Lifecycle.ListAbstractTraders()
    local list = {}
    if not DTCommon or not DTCommon.TraderService then return list end

    DTCommon.TraderService.ForEach(function(traderID, record)
        local ca = record and record.ca or nil
        if ca and ca.available ~= false
            and (ca.provider == "DTAbstract" or ca.coreProvider == "DTAbstract")
            and (ca.providerState == "abstract"
                or ca.coreProviderState == "abstract"
                or ca.providerState == nil)
        then
            list[#list + 1] = {
                traderID = traderID,
                record = record,
                actorID = ca.actorID or ca.coreActorID,
                homeSettlementID = ca.homeSettlementID,
                currentSettlementID = ca.currentSettlementID,
                destinationSettlementID = ca.destinationSettlementID,
            }
        end
    end)

    table.sort(list, function(a, b) return a.traderID < b.traderID end)
    return list
end

function Lifecycle.CountAbstractTraders()
    local list = Lifecycle.ListAbstractTraders()
    return #list
end

function Lifecycle.ReconcileActorLinks()
    local reg = getActorRegistry()
    local Policy = DTCommon and DTCommon.CoreActorPolicy
    if not reg or not Policy or not DTCommon or not DTCommon.TraderService then
        return { checked = 0, quarantined = 0, restored = 0 }
    end

    local summary = { checked = 0, quarantined = 0, restored = 0 }
    local changed = false
    DTCommon.TraderService.ForEach(function(_, record)
        local ca = record and record.ca or nil
        if not ca or (ca.provider ~= "DTAbstract"
            and ca.coreProvider ~= "DTAbstract")
        then
            return
        end
        summary.checked = summary.checked + 1
        local actorID = ca.actorID or ca.coreActorID
        local actor = actorID and reg:Get(actorID) or nil
        if not actor then
            if ca.available ~= false
                or ca.availabilityReason ~= "core_actor_missing"
            then
                Policy.SetAvailable(record, false, "core_actor_missing")
                summary.quarantined = summary.quarantined + 1
                changed = true
            end
        elseif ca.available == false
            and ca.availabilityReason == "core_actor_missing"
        then
            Policy.SetAvailable(record, true, nil)
            summary.restored = summary.restored + 1
            changed = true
        end
    end)

    if changed and DTCommon.TraderStock
        and DTCommon.TraderStock.SaveAndTransmit
    then
        DTCommon.TraderStock.SaveAndTransmit()
    end
    return summary
end

local function nextSpawnSequence()
    local count = 0
    if DTCommon and DTCommon.TraderService then
        DTCommon.TraderService.ForEach(function(id)
            if string.find(id, "trader:abstract:", 1, true) then
                count = count + 1
            end
        end)
    end
    return count + 1
end

function Lifecycle.SpawnAbstractTrader(options)
    if not isAuthority() then return nil, "server_authority_required" end
    options = type(options) == "table" and options or {}

    local Directory = DTCommon and DTCommon.SettlementDirectory
    if not Directory then return nil, "settlement_directory_unavailable" end

    local settlements = Directory.List()
    if #settlements < 1 then
        Directory.EnsureDefaults()
        settlements = Directory.List()
    end
    if #settlements < 1 then return nil, "no_settlements_available" end

    local seq = nextSpawnSequence()
    local traderID = options.traderID or ("trader:abstract:" .. tostring(seq))
    local actorID = options.actorID or ("actor:dt:abstract:" .. tostring(seq))

    local settlementID = options.settlementID or settlements[((seq - 1) % #settlements) + 1].settlementID
    local pos = options.position
    if not pos then
        pos = Directory.ResolvePosition(settlementID)
    end
    if not pos then return nil, "settlement_position_unavailable" end

    local reg = getActorRegistry()
    if not reg then return nil, "actor_registry_unavailable" end

    local actor, actorReason = reg:Get(actorID)
    if not actor then
        actor, actorReason = reg:Create({
            actorId = actorID,
            identitySeed = "abstract-seed-" .. actorID,
            world = {
                position = pos,
            },
        })
        if not actor then return nil, actorReason or "actor_create_failed" end
    end

    local coreProvider = DTAbstract.CoreProvider
    if not coreProvider then
        local ok, prov = pcall(require, "DTAbstract/DTAbstract_CoreProvider")
        if ok then coreProvider = prov end
    end
    if not coreProvider then
        return nil, "core_provider_unavailable"
    end

    local acquired, acqReason = coreProvider.Acquire(actor, { Actors = getActors() }, {
        owner = "abstract:lifecycle",
        now = options.now or worldAge(),
    })
    if not acquired then return nil, acqReason or "lease_acquire_failed" end

    local committed, comReason = reg:Commit(actorID, acquired, actor.revision)
    if not committed then return nil, comReason or "actor_commit_failed" end

    local createdID, record = DTCommon.TraderService.Create({
        traderID = traderID,
        displayName = options.displayName or ("Abstract Trader " .. tostring(seq)),
        traderRole = options.traderRole or "Roaming Trader",
        budget = options.budget or 1000,
        abstractAccessEnabled = true,
        actorID = actorID,
        coreActorID = actorID,
        provider = "DTAbstract",
        providerState = "abstract",
        coreProvider = "DTAbstract",
        coreProviderState = "abstract",
        homeSettlementID = settlementID,
        currentSettlementID = settlementID,
    })
    if not createdID then return nil, record or "trader_create_failed" end

    return {
        traderID = traderID,
        actorID = actorID,
        position = pos,
        settlementID = settlementID,
        record = record,
    }
end

function Lifecycle.SelectNextDestination(currentSettlementID)
    local Directory = DTCommon and DTCommon.SettlementDirectory
    if not Directory then return nil end

    local settlements = Directory.List()
    local candidates = {}
    for i = 1, #settlements do
        if settlements[i].settlementID ~= currentSettlementID and settlements[i].enabled ~= false then
            candidates[#candidates + 1] = settlements[i].settlementID
        end
    end
    if #candidates < 1 then return nil end
    local idx = (math.floor(worldAge()) % #candidates) + 1
    return candidates[idx]
end

function Lifecycle.StartTraderJourney(traderID, destinationSettlementID, now)
    if not isAuthority() then return nil, "server_authority_required" end
    now = tonumber(now) or worldAge()

    local record = DTCommon.TraderService.GetRecord(traderID)
    if not record or not record.ca then return nil, "trader_not_found" end
    local ca = record.ca

    local Directory = DTCommon.SettlementDirectory
    local destPos = Directory and Directory.ResolvePosition(destinationSettlementID)
    if not destPos then return nil, "destination_position_not_found" end

    local reg = getActorRegistry()
    local actor = reg and reg:Get(ca.actorID)
    if not actor or not actor.world then return nil, "actor_world_not_found" end

    local Actors = getActors()
    local World = Actors and Actors.World
    if not World then return nil, "actors_world_unavailable" end

    local originPos = World.ProjectPosition(actor.world, now)
    local originSettlementID = ca.currentSettlementID or ca.homeSettlementID

    local nextWorld, startReason = World.StartJourney(actor.world, actor.actorId, {
        origin = originPos,
        destination = destPos,
        speed = Lifecycle.DEFAULT_SPEED,
        startAt = now,
        arrivalAction = {
            type = "dt_settlement_visit",
            settlementID = destinationSettlementID,
        },
    }, now)
    if not nextWorld then return nil, startReason end

    local committed, comReason = reg:Commit(actor.actorId, { world = nextWorld }, actor.revision)
    if not committed then return nil, comReason end

    ca.originSettlementID = originSettlementID
    ca.currentSettlementID = nil
    ca.destinationSettlementID = destinationSettlementID
    DTCommon.TraderStock.SaveAndTransmit()

    return true, nextWorld.journey
end

function Lifecycle.AdvanceTrader(traderID, now)
    if not isAuthority() then return nil, "server_authority_required" end
    now = tonumber(now) or worldAge()

    local record = DTCommon.TraderService.GetRecord(traderID)
    if not record or not record.ca then return nil, "trader_not_found" end
    local ca = record.ca

    local reg = getActorRegistry()
    local actor = reg and reg:Get(ca.actorID)
    if not actor or not actor.world then return nil, "actor_world_not_found" end

    local Actors = getActors()
    local World = Actors and Actors.World
    if not World then return nil, "actors_world_unavailable" end

    local journey = actor.world.journey
    if journey and (journey.state == "en_route" or journey.state == "planned") then
        local nextWorld = World.AdvanceJourney(actor.world, now)
        if nextWorld.journey.state == "arrived" then
            local destID = ca.destinationSettlementID or (journey.arrivalAction and journey.arrivalAction.settlementID)
            local visitID = nextWorld.journey.journeyID or ("visit:" .. tostring(now))

            local handledWorld, handleReason = World.MarkArrivalHandled(nextWorld, "dt_abstract_lifecycle")
            if handledWorld then
                reg:Commit(actor.actorId, { world = handledWorld }, actor.revision)
            else
                reg:Commit(actor.actorId, { world = nextWorld }, actor.revision)
            end

            -- Exactly-once settlement visit & exchange
            if destID then
                DTCommon.TraderService.MarkSettlementVisit(traderID, {
                    settlementID = destID,
                    exchange = true,
                    visitID = visitID,
                    now = now,
                })
            end

            ca.lastSettlementID = destID
            ca.currentSettlementID = destID
            ca.destinationSettlementID = nil
            ca.lastVisitAt = now
            DTCommon.TraderStock.SaveAndTransmit()
            return "arrived"
        else
            reg:Commit(actor.actorId, { world = nextWorld }, actor.revision)
            return "en_route"
        end
    else
        -- Trader is idle at settlement: check cooldown before selecting next route
        local lastAt = tonumber(ca.lastVisitAt) or 0
        if (now - lastAt) >= Lifecycle.COOLDOWN_HOURS_AT_SETTLEMENT or lastAt == 0 then
            local nextDest = Lifecycle.SelectNextDestination(ca.currentSettlementID or ca.homeSettlementID)
            if nextDest then
                local ok, startReason = Lifecycle.StartTraderJourney(traderID, nextDest, now)
                if ok then return "departed" end
            end
        end
        return "idle"
    end
end

function Lifecycle.Tick(force, now)
    local summary = { activeCount = 0, spawned = 0, advanced = 0, arrived = 0, skipped = nil }
    if not isAuthority() then
        summary.skipped = "not_authority"
        return summary
    end

    now = tonumber(now) or worldAge()
    summary.reconciliation = Lifecycle.ReconcileActorLinks()
    local traders = Lifecycle.ListAbstractTraders()
    summary.activeCount = #traders

    -- 1. Ensure bounded population
    if summary.activeCount < Lifecycle.MAX_ABSTRACT_TRADERS then
        local spawned, reason = Lifecycle.SpawnAbstractTrader({ now = now })
        if spawned then
            summary.spawned = summary.spawned + 1
            summary.activeCount = summary.activeCount + 1
        else
            summary.skipped = reason
        end
    end

    -- 2. Advance active journeys / routes
    for i = 1, #traders do
        local traderID = traders[i].traderID
        local status = Lifecycle.AdvanceTrader(traderID, now)
        if status == "arrived" then
            summary.arrived = summary.arrived + 1
        elseif status == "en_route" or status == "departed" then
            summary.advanced = summary.advanced + 1
        end
    end

    lastSummary = summary
    if DTAbstract.ProjectionServer
        and type(DTAbstract.ProjectionServer.Publish) == "function"
    then
        DTAbstract.ProjectionServer.Publish()
    end
    return summary
end

function Lifecycle.LastSummary()
    return lastSummary
end

local function onTick()
    local at = worldAge()
    if nextAttemptAt and at < nextAttemptAt then return end
    nextAttemptAt = at + Lifecycle.INTERVAL_HOURS
    Lifecycle.Tick(false, at)
end

if Events and Events.OnGameStart
    and type(Events.OnGameStart.Add) == "function"
    and not Lifecycle.StartHookRegistered
then
    Lifecycle.StartHookRegistered = true
    Events.OnGameStart.Add(function()
        nextAttemptAt = worldAge() + Lifecycle.INTERVAL_HOURS
    end)
end

if Events and Events.OnTick
    and type(Events.OnTick.Add) == "function"
    and not Lifecycle.TickHookRegistered
then
    Lifecycle.TickHookRegistered = true
    Events.OnTick.Add(onTick)
end

return Lifecycle
