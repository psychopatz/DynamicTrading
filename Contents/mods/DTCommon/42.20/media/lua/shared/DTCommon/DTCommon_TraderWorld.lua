-- Canonical provider-agnostic DynamicTrading trader-world lifecycle.
-- DTCommon owns commercial/world intent. Representation providers own only
-- how a trader is spawned, moved, materialized, and observed.

DTCommon = DTCommon or {}
DTCommon.TraderWorld = DTCommon.TraderWorld or {}

local World = DTCommon.TraderWorld
local Providers = DTCommon.TraderProviders
    or require "DTCommon/DTCommon_TraderProviderRegistry"
local Policy = DTCommon.CoreActorPolicy
    or require "DTCommon/DTCommon_CoreActorPolicy"
local Service = DTCommon.TraderService
local Directory = DTCommon.SettlementDirectory
local Storage = DTCommon.Storage

World.MAX_ROAMING_TRADERS = 2
World.INTERVAL_HOURS = 1
World.COOLDOWN_HOURS = 4
World.DEFAULT_ROLE = "roaming"
World.LastTickSummary = World.LastTickSummary or {
    managed = 0, activeCount = 0, spawned = 0, departed = 0,
    advanced = 0, arrived = 0, skipped = "not_run",
}

local function authority()
    return Storage and type(Storage.IsAuthority) == "function"
        and Storage.IsAuthority() == true
end

local function worldAge(value)
    value = tonumber(value)
    if value ~= nil then return math.max(0, value) end
    local time = getGameTime and getGameTime() or nil
    if time and type(time.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(time:getWorldAgeHours()) or 0)
    end
    return 0
end

local function persist()
    if Storage and type(Storage.Touch) == "function"
        and type(Storage.Transmit) == "function"
    then
        Storage.Touch()
        Storage.Transmit()
        return true
    end
    if DTCommon.TraderStock
        and type(DTCommon.TraderStock.SaveAndTransmit) == "function"
    then
        return DTCommon.TraderStock.SaveAndTransmit()
    end
    return true
end

local function policyFor(record)
    return Policy and Policy.Get and Policy.Get(record) or nil
end

local function savePolicy(record, policy)
    if not record or not policy then return false end
    policy.worldRevision = math.max(0,
        math.floor(tonumber(policy.worldRevision) or 0)) + 1
    record.ca = policy
    persist()
    return true
end

local function activeProvider(record)
    local policy = policyFor(record)
    local id = policy and policy.provider or nil
    return id and Providers and Providers.Get(id) or nil, id, policy
end

local function providerOwnsRecord(traderID, record)
    if not Providers then return false end
    for _, provider in ipairs(Providers.List()) do
        if type(provider.ownsRecord) == "function" then
            local ok, owned = pcall(provider.ownsRecord, traderID, record)
            if ok and owned == true then return true, provider.id end
        end
    end
    return false
end

local function inferManaged(traderID, record)
    local policy = policyFor(record)
    if not policy then return false end
    if policy.worldManaged == true then return true end

    local owned, providerID = providerOwnsRecord(traderID, record)
    if owned then
        policy.worldManaged = true
        policy.worldRole = policy.worldRole or World.DEFAULT_ROLE
        policy.provider = policy.provider or providerID
        policy.lifecycleState = policy.lifecycleState or "idle"
        savePolicy(record, policy)
        return true
    end
    return false
end

function World.AdoptTrader(traderID, spec)
    if not authority() then return nil, "server_authority_required" end
    spec = type(spec) == "table" and spec or {}
    local record = Service and Service.GetRecord
        and Service.GetRecord(traderID) or nil
    if not record then return nil, "trader_not_found" end

    local policy = policyFor(record)
    if not policy then return nil, "trader_policy_unavailable" end
    policy.worldManaged = spec.worldManaged ~= false
    policy.worldRole = tostring(spec.worldRole
        or policy.worldRole or World.DEFAULT_ROLE)
    policy.lifecycleState = tostring(spec.lifecycleState
        or policy.lifecycleState or "idle")
    if spec.provider then policy.provider = tostring(spec.provider) end
    if spec.providerState then
        policy.providerState = tostring(spec.providerState)
    end
    if spec.homeSettlementID and not policy.homeSettlementID then
        policy.homeSettlementID = tostring(spec.homeSettlementID)
    end
    if spec.currentSettlementID ~= nil then
        policy.currentSettlementID = spec.currentSettlementID
            and tostring(spec.currentSettlementID) or nil
    end
    if spec.cooldownUntil ~= nil then
        policy.cooldownUntil = math.max(0,
            tonumber(spec.cooldownUntil) or 0)
    end
    savePolicy(record, policy)
    return record
end

function World.ListManaged(role)
    local output = {}
    if not Service or type(Service.ForEach) ~= "function" then return output end
    role = role and tostring(role) or nil
    Service.ForEach(function(traderID, record)
        if inferManaged(traderID, record) then
            local policy = policyFor(record)
            if policy and (not role or policy.worldRole == role) then
                output[#output + 1] = {
                    traderID = traderID,
                    record = record,
                    policy = policy,
                }
            end
        end
    end)
    table.sort(output, function(left, right)
        return tostring(left.traderID) < tostring(right.traderID)
    end)
    return output
end

function World.CountManaged(role)
    return #World.ListManaged(role)
end

function World.ListByProvider(providerID)
    providerID = tostring(providerID or "")
    local output = {}
    if providerID == "" or not Service
        or type(Service.ForEach) ~= "function"
    then
        return output
    end
    Service.ForEach(function(traderID, record)
        local policy = policyFor(record)
        if policy and tostring(policy.provider or "") == providerID then
            output[#output + 1] = {
                traderID = traderID,
                record = record,
                policy = policy,
            }
        end
    end)
    table.sort(output, function(left, right)
        return tostring(left.traderID) < tostring(right.traderID)
    end)
    return output
end

function World.CountByProvider(providerID)
    return #World.ListByProvider(providerID)
end

World.ProjectionDirty = World.ProjectionDirty == true

function World.MarkProjectionDirty()
    World.ProjectionDirty = true
    return true
end

function World.ConsumeProjectionDirty()
    if World.ProjectionDirty ~= true then return false end
    World.ProjectionDirty = false
    return true
end

function World.SpawnTrader(providerID, spec)
    if not authority() then return nil, "server_authority_required" end
    spec = type(spec) == "table" and spec or {}
    providerID = tostring(providerID or "")
    local provider = Providers and Providers.Get(providerID) or nil
    if not provider or type(provider.spawnTrader) ~= "function" then
        return nil, "spawn_provider_unavailable"
    end

    local request = {}
    for key, value in pairs(spec) do request[key] = value end
    request.provider = providerID
    request.worldRole = request.worldRole or World.DEFAULT_ROLE

    local ok, result, reason = pcall(provider.spawnTrader, request)
    if not ok then return nil, tostring(result) end
    if not result then return nil, reason or "spawn_failed" end

    local traderID = type(result) == "table"
        and result.traderID or result
    local adopted, adoptReason = World.AdoptTrader(traderID, {
        worldRole = request.worldRole,
        provider = providerID,
        lifecycleState = request.lifecycleState or "idle",
        homeSettlementID = type(result) == "table"
            and result.settlementID or request.homeSettlementID,
        currentSettlementID = type(result) == "table"
            and result.settlementID or request.currentSettlementID,
    })
    if not adopted then return nil, adoptReason end
    if type(result) ~= "table" then result = { traderID = traderID } end
    result.record = adopted
    World.MarkProjectionDirty()
    return result
end

local function hashToken(value)
    local hash = 0
    value = tostring(value or "")
    for i = 1, #value do
        hash = (hash * 31 + string.byte(value, i)) % 1000003
    end
    return hash
end

function World.SelectDestination(traderID, currentSettlementID, now, options)
    options = type(options) == "table" and options or {}
    if not Directory or type(Directory.List) ~= "function" then
        return nil, "settlement_directory_unavailable"
    end
    local record = Service and Service.GetRecord
        and Service.GetRecord(traderID) or nil
    if not record then return nil, "trader_not_found" end
    local provider = activeProvider(record)
    local candidates = {}
    for _, settlement in ipairs(Directory.List()) do
        if settlement.enabled ~= false
            and tostring(settlement.settlementID or "")
                ~= tostring(currentSettlementID or "")
        then
            local allowed = true
            if provider and type(provider.canTravelTo) == "function" then
                local ok, result = pcall(
                    provider.canTravelTo, traderID, record, settlement, now)
                allowed = ok and result ~= false
            end
            if allowed then
                local score = 0
                if provider and type(provider.scoreDestination) == "function" then
                    local ok, value = pcall(
                        provider.scoreDestination,
                        traderID, record, settlement, now)
                    if ok then score = tonumber(value) or 0 end
                end
                candidates[#candidates + 1] = {
                    settlement = settlement,
                    score = math.max(-100, math.min(100, score)),
                }
            end
        end
    end
    if #candidates == 0 then return nil, "no_destination" end
    table.sort(candidates, function(left, right)
        if left.score ~= right.score then return left.score > right.score end
        return tostring(left.settlement.settlementID)
            < tostring(right.settlement.settlementID)
    end)
    local bestScore = candidates[1].score
    local minimumScore = tonumber(options.minScore)
    if minimumScore ~= nil and bestScore < minimumScore then
        return nil, "destination_score_below_minimum"
    end
    local top = {}
    for _, entry in ipairs(candidates) do
        if entry.score ~= bestScore then break end
        top[#top + 1] = entry.settlement
    end
    local seed = hashToken(traderID)
        + math.floor(worldAge(now))
        + math.floor(tonumber(policyFor(record).visitCount) or 0)
    local index = (seed % #top) + 1
    return top[index]
end

local function newJourneyID(traderID, destinationSettlementID, now, revision)
    return table.concat({
        "dtworld",
        tostring(traderID),
        tostring(destinationSettlementID),
        tostring(math.floor(worldAge(now) * 1000)),
        tostring(math.floor(tonumber(revision) or 0) + 1),
    }, ":")
end

function World.BeginJourney(traderID, destinationSettlementID, spec)
    if not authority() then return nil, "server_authority_required" end
    spec = type(spec) == "table" and spec or {}
    local record = Service and Service.GetRecord
        and Service.GetRecord(traderID) or nil
    if not record then return nil, "trader_not_found" end
    local provider, providerID, policy = activeProvider(record)
    if not provider then return nil, "provider_unavailable" end
    if type(provider.startMovement) ~= "function" then
        return nil, "provider_movement_unavailable"
    end
    local destination = Directory and Directory.Get
        and Directory.Get(destinationSettlementID) or nil
    if not destination then return nil, "destination_not_found" end

    local now = worldAge(spec.now)
    local origin = policy.currentSettlementID or policy.homeSettlementID
    local journeyID = tostring(spec.journeyID
        or newJourneyID(traderID, destinationSettlementID, now,
            policy.worldRevision))
    local request = {
        journeyID = journeyID,
        originSettlementID = origin,
        destinationSettlementID = tostring(destinationSettlementID),
        destination = destination,
        now = now,
        reason = spec.reason or "dtcommon_world_departure",
    }
    local ok, result, reason = pcall(
        provider.startMovement, traderID, record, request)
    if not ok then return nil, tostring(result) end
    if result == false or result == nil then
        return nil, reason or "provider_movement_rejected"
    end
    if type(result) == "string" then
        request.providerReason = result
    elseif type(result) == "table" then
        request.providerResult = result
        if result.journeyID then journeyID = tostring(result.journeyID) end
    end

    policy = policyFor(record)
    policy.worldManaged = true
    policy.worldRole = policy.worldRole or World.DEFAULT_ROLE
    policy.originSettlementID = origin
    policy.currentSettlementID = nil
    policy.destinationSettlementID = tostring(destinationSettlementID)
    policy.lifecycleState = "traveling"
    policy.journeyID = journeyID
    policy.journeyState = "en_route"
    policy.cooldownUntil = 0
    savePolicy(record, policy)

    return {
        traderID = traderID,
        provider = providerID,
        journeyID = journeyID,
        originSettlementID = origin,
        destinationSettlementID = tostring(destinationSettlementID),
    }
end

function World.BeginExternalJourney(traderID, destinationSettlementID, spec)
    if not authority() then return nil, "server_authority_required" end
    spec = type(spec) == "table" and spec or {}
    local record = Service and Service.GetRecord
        and Service.GetRecord(traderID) or nil
    if not record then return nil, "trader_not_found" end
    destinationSettlementID = tostring(destinationSettlementID or "")
    if destinationSettlementID == "" then
        return nil, "destination_required"
    end
    local destination = Directory and Directory.Get
        and Directory.Get(destinationSettlementID) or nil
    if not destination and spec.validatedDestination ~= true then
        return nil, "destination_not_found"
    end

    local policy = policyFor(record)
    local now = worldAge(spec.now)
    local origin = spec.originSettlementID
        or policy.currentSettlementID
        or policy.homeSettlementID
    local journeyID = tostring(spec.journeyID
        or newJourneyID(traderID, destinationSettlementID, now,
            policy.worldRevision))

    policy.worldManaged = true
    policy.worldRole = tostring(spec.worldRole
        or policy.worldRole or World.DEFAULT_ROLE)
    policy.originSettlementID = origin and tostring(origin) or nil
    policy.currentSettlementID = nil
    policy.destinationSettlementID = destinationSettlementID
    policy.lifecycleState = tostring(spec.lifecycleState or "traveling")
    policy.journeyID = journeyID
    policy.journeyState = tostring(spec.journeyState or "en_route")
    savePolicy(record, policy)

    if spec.available ~= nil then
        if Service and type(Service.SetActorAvailability) == "function" then
            Service.SetActorAvailability(
                traderID,
                spec.available == true,
                spec.availabilityReason
            )
        elseif Policy and type(Policy.SetAvailable) == "function" then
            Policy.SetAvailable(record, spec.available == true,
                spec.availabilityReason)
            record.s = spec.available == true
                and DTCommon.STATUS_READY or DTCommon.STATUS_AWAY
            savePolicy(record, Policy.Get(record))
        end
    end

    return {
        traderID = traderID,
        journeyID = journeyID,
        originSettlementID = origin,
        destinationSettlementID = destinationSettlementID,
    }
end

function World.UpdateExternalState(traderID, spec)
    if not authority() then return false, "server_authority_required" end
    spec = type(spec) == "table" and spec or {}
    local record = Service and Service.GetRecord
        and Service.GetRecord(traderID) or nil
    if not record then return false, "trader_not_found" end
    local policy = policyFor(record)

    if spec.currentProvided == true then
        policy.currentSettlementID = spec.currentSettlementID
            and tostring(spec.currentSettlementID) or nil
    end
    if spec.originProvided == true then
        policy.originSettlementID = spec.originSettlementID
            and tostring(spec.originSettlementID) or nil
    end
    if spec.destinationProvided == true then
        policy.destinationSettlementID = spec.destinationSettlementID
            and tostring(spec.destinationSettlementID) or nil
    end
    if spec.lifecycleState ~= nil then
        policy.lifecycleState = tostring(spec.lifecycleState)
    end
    if spec.journeyID ~= nil then
        policy.journeyID = tostring(spec.journeyID)
    end
    if spec.journeyState ~= nil then
        policy.journeyState = tostring(spec.journeyState)
    end
    if spec.cooldownUntil ~= nil then
        policy.cooldownUntil = math.max(0,
            tonumber(spec.cooldownUntil) or 0)
    end
    savePolicy(record, policy)

    if spec.available ~= nil then
        if Service and type(Service.SetActorAvailability) == "function" then
            Service.SetActorAvailability(
                traderID,
                spec.available == true,
                spec.availabilityReason
            )
        elseif Policy and type(Policy.SetAvailable) == "function" then
            Policy.SetAvailable(record, spec.available == true,
                spec.availabilityReason)
            record.s = spec.available == true
                and DTCommon.STATUS_READY or DTCommon.STATUS_AWAY
            savePolicy(record, Policy.Get(record))
        end
    end
    return true
end

function World.ReportJourneyState(traderID, state, spec)
    if not authority() then return false, "server_authority_required" end
    local record = Service and Service.GetRecord
        and Service.GetRecord(traderID) or nil
    if not record then return false, "trader_not_found" end
    local policy = policyFor(record)
    if spec and spec.journeyID and policy.journeyID
        and tostring(spec.journeyID) ~= tostring(policy.journeyID)
    then
        return false, "journey_identity_mismatch"
    end
    policy.lifecycleState = state == "arrived" and "arriving"
        or state == "en_route" and "traveling"
        or tostring(state or policy.lifecycleState or "idle")
    policy.journeyState = tostring(state or policy.journeyState or "")
    savePolicy(record, policy)
    return true
end

function World.Arrive(traderID, settlementID, spec)
    if not authority() then return nil, "server_authority_required" end
    spec = type(spec) == "table" and spec or {}
    local record = Service and Service.GetRecord
        and Service.GetRecord(traderID) or nil
    if not record then return nil, "trader_not_found" end
    settlementID = tostring(settlementID or "")
    if settlementID == "" then return nil, "settlement_required" end
    local policy = policyFor(record)
    local now = worldAge(spec.now)
    local journeyID = tostring(spec.journeyID
        or policy.journeyID
        or ("arrival:" .. traderID .. ":" .. settlementID
            .. ":" .. tostring(math.floor(now * 1000))))
    local visitID = tostring(spec.visitID
        or ("dtworld:" .. journeyID .. ":" .. settlementID))

    local result, reason = Service.MarkSettlementVisit(traderID, {
        authority = "server",
        atSettlement = true,
        settlementID = settlementID,
        visitID = visitID,
        now = now,
        exchange = spec.exchange ~= false,
        restock = spec.restock == true,
        earned = spec.earned,
        available = spec.available,
    })
    local duplicate = result == nil and reason == "duplicate_visit"
    if not result and not duplicate then return nil, reason end

    policy = policyFor(record)
    policy.worldManaged = true
    policy.worldRole = policy.worldRole or World.DEFAULT_ROLE
    policy.originSettlementID = policy.originSettlementID
        or policy.lastSettlementID
    policy.currentSettlementID = settlementID
    policy.destinationSettlementID = nil
    policy.lifecycleState = "cooldown"
    policy.journeyID = journeyID
    policy.journeyState = "arrived"
    policy.cooldownUntil = now + math.max(0,
        tonumber(spec.cooldownHours) or World.COOLDOWN_HOURS)
    savePolicy(record, policy)

    return {
        traderID = traderID,
        settlementID = settlementID,
        visitID = visitID,
        journeyID = journeyID,
        duplicate = duplicate,
        visit = result,
    }, duplicate and "duplicate_visit" or "arrived"
end

function World.SetIdle(traderID, spec)
    if not authority() then return false, "server_authority_required" end
    spec = type(spec) == "table" and spec or {}
    local record = Service and Service.GetRecord
        and Service.GetRecord(traderID) or nil
    if not record then return false, "trader_not_found" end
    local policy = policyFor(record)
    if spec.currentSettlementID ~= nil then
        policy.currentSettlementID = spec.currentSettlementID
            and tostring(spec.currentSettlementID) or nil
    end
    policy.destinationSettlementID = nil
    policy.lifecycleState = "idle"
    policy.journeyState = spec.journeyState or "idle"
    if spec.cooldownUntil ~= nil then
        policy.cooldownUntil = math.max(0,
            tonumber(spec.cooldownUntil) or 0)
    end
    savePolicy(record, policy)
    return true
end

function World.AdvanceTrader(traderID, now)
    if not authority() then return nil, "server_authority_required" end
    now = worldAge(now)
    local record = Service and Service.GetRecord
        and Service.GetRecord(traderID) or nil
    if not record then return nil, "trader_not_found" end
    local provider, _, policy = activeProvider(record)
    if not provider then return nil, "provider_unavailable" end

    if policy.lifecycleState == "traveling"
        or policy.destinationSettlementID ~= nil
    then
        if type(provider.pollMovement) ~= "function" then
            return "external"
        end
        local ok, result, reason = pcall(
            provider.pollMovement, traderID, record, {
                now = now,
                journeyID = policy.journeyID,
                destinationSettlementID = policy.destinationSettlementID,
            })
        if not ok then return nil, tostring(result) end
        if result == false or result == nil then
            return nil, reason or "provider_poll_failed"
        end
        local status = type(result) == "table"
            and result.status or tostring(result)
        if status == "arrived" then
            local destination = type(result) == "table"
                and result.settlementID or policy.destinationSettlementID
            local arrived, arriveReason = World.Arrive(
                traderID, destination, {
                    now = now,
                    journeyID = type(result) == "table"
                        and result.journeyID or policy.journeyID,
                    visitID = type(result) == "table"
                        and result.visitID or nil,
                    exchange = type(result) ~= "table"
                        or result.exchange ~= false,
                })
            return arrived and "arrived" or nil, arriveReason
        end
        if status == "en_route" or status == "traveling" then
            return "en_route"
        end
        return status
    end

    if policy.cooldownUntil and now < policy.cooldownUntil then
        return "cooldown"
    end

    local current = policy.currentSettlementID or policy.homeSettlementID
    local destination, reason =
        World.SelectDestination(traderID, current, now)
    if not destination then return "idle", reason end
    local started, startReason = World.BeginJourney(
        traderID, destination.settlementID, { now = now })
    return started and "departed" or nil, startReason
end

local function providerForSpawn(context)
    if not Providers then return nil end
    return Providers.Select("spawnTrader", context)
end

function World.ReconcileProviders()
    local summary = { checked = 0, changed = 0, failed = 0 }
    if not Service or type(Service.ForEach) ~= "function" then return summary end
    Service.ForEach(function(traderID, record)
        local provider = activeProvider(record)
        if provider and type(provider.reconcileRecord) == "function" then
            summary.checked = summary.checked + 1
            local ok, accepted, reason = pcall(
                provider.reconcileRecord, traderID, record)
            if not ok or accepted == false then
                summary.failed = summary.failed + 1
            elseif reason == "changed" then
                summary.changed = summary.changed + 1
            end
        end
    end)
    if summary.changed > 0 then
        persist()
    end
    return summary
end

function World.EnsurePopulation(now, spawnBudget)
    if not authority() then
        return { managed = 0, spawned = 0, skipped = "not_authority" }
    end
    now = worldAge(now)
    local managed = World.ListManaged(World.DEFAULT_ROLE)
    local summary = {
        managed = #managed,
        spawned = 0,
        skipped = nil,
    }
    if #managed >= World.MAX_ROAMING_TRADERS then
        summary.skipped = "at_capacity"
        return summary
    end

    local provider = providerForSpawn({
        role = World.DEFAULT_ROLE,
        now = now,
    })
    if not provider then
        summary.skipped = "spawn_provider_unavailable"
        return summary
    end

    local needed = World.MAX_ROAMING_TRADERS - #managed
    local budget = math.min(
        math.max(1, math.floor(tonumber(spawnBudget) or 1)),
        needed
    )
    for index = 1, budget do
        local result, reason = World.SpawnTrader(provider.id, {
            worldRole = World.DEFAULT_ROLE,
            sequence = #managed + index,
            now = now,
        })
        if not result then
            summary.skipped = reason or "spawn_failed"
            break
        end
        summary.spawned = summary.spawned + 1
        summary.managed = summary.managed + 1
    end
    return summary
end

function World.Tick(force, now)
    local summary = {
        managed = 0, activeCount = 0, spawned = 0, departed = 0,
        advanced = 0, arrived = 0, skipped = nil,
    }
    if not authority() then
        summary.skipped = "not_authority"
        return summary
    end
    now = worldAge(now)

    summary.reconciliation = World.ReconcileProviders()
    local population = World.EnsurePopulation(
        now,
        force == true and World.MAX_ROAMING_TRADERS or 1
    )
    summary.spawned = population.spawned or 0

    local traders = World.ListManaged(World.DEFAULT_ROLE)
    summary.managed = #traders
    summary.activeCount = #traders
    for _, entry in ipairs(traders) do
        local status = World.AdvanceTrader(entry.traderID, now)
        if status == "departed" then
            summary.departed = summary.departed + 1
        elseif status == "en_route" then
            summary.advanced = summary.advanced + 1
        elseif status == "arrived" then
            summary.arrived = summary.arrived + 1
        end
    end
    World.LastTickSummary = summary
    return summary
end

function World.LastSummary()
    return World.LastTickSummary
end

return World
