-- Common bounded representation switching for canonical trader-world actors.
-- DTCommon decides *when* a representation changes. Registered providers own
-- the actual body/actor mechanics.

DTCommon = DTCommon or {}
DTCommon.TraderRepresentationRuntime =
    DTCommon.TraderRepresentationRuntime or {}

local Runtime = DTCommon.TraderRepresentationRuntime
local Providers = DTCommon.TraderProviders
    or require "DTCommon/DTCommon_TraderProviderRegistry"
local Service = DTCommon.TraderService
local World = DTCommon.TraderWorld
    or require "DTCommon/DTCommon_TraderWorld"

Runtime.MATERIALIZE_RADIUS = 60
Runtime.DEMATERIALIZE_RADIUS = 90
Runtime.CHECK_INTERVAL_MS = 2000

local lastCheckAt = 0

local function nowMs()
    if getTimestampMs then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    if getTimeInMillis then
        local ok, value = pcall(getTimeInMillis)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return 0
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

local function eachPlayer(callback)
    if isServer and isServer() and getOnlinePlayers then
        local players = getOnlinePlayers()
        if players and type(players.size) == "function"
            and type(players.get) == "function"
        then
            for index = 0, players:size() - 1 do
                callback(players:get(index))
            end
            return
        elseif type(players) == "table" then
            for _, player in ipairs(players) do callback(player) end
            return
        end
    end
    local current = getSpecificPlayer and getSpecificPlayer(0)
        or (getPlayer and getPlayer() or nil)
    if current then callback(current) end
end

local function nearestDistance(position)
    if type(position) ~= "table" then return math.huge end
    local nearest = math.huge
    eachPlayer(function(player)
        local px = player and player.getX and tonumber(player:getX()) or nil
        local py = player and player.getY and tonumber(player:getY()) or nil
        if px and py and tonumber(position.x) and tonumber(position.y) then
            local dx = px - tonumber(position.x)
            local dy = py - tonumber(position.y)
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance < nearest then nearest = distance end
        end
    end)
    return nearest
end

local function recordFor(traderID)
    return Service and Service.GetRecord
        and Service.GetRecord(tostring(traderID or "")) or nil
end

local function providerFor(record)
    local policy = record and record.ca or nil
    local id = policy and (policy.provider or policy.coreProvider) or nil
    local provider = id and Providers.Get(id) or nil
    return provider, id, policy
end

local function positionFor(provider, traderID, record, now)
    if not provider or type(provider.getPosition) ~= "function" then
        return nil, "provider_position_unavailable"
    end
    local ok, position, reason = pcall(
        provider.getPosition, traderID, record, now)
    if not ok then return nil, tostring(position) end
    return position, reason
end

function Runtime.MaterializeTrader(traderID, options)
    options = type(options) == "table" and options or {}
    local record = recordFor(traderID)
    if not record then return nil, "trader_not_found" end
    local current, currentID = providerFor(record)
    if not current then return nil, "current_provider_unavailable" end
    if current.kind == "physical" then
        return nil, "already_physical"
    end

    local target = Providers.Select("materializeTrader", {
        traderID = traderID,
        record = record,
        fromProvider = currentID,
    })
    if not target or target.id == currentID then
        return nil, "physical_provider_unavailable"
    end

    local request = {}
    for key, value in pairs(options) do request[key] = value end
    request.returnProviderID = currentID

    -- Freeze the source provider's canonical projection into the handoff
    -- request. This is essential for group-shared journeys where the actor
    -- itself intentionally carries no duplicate personal journey.
    if request.position == nil then
        local position = positionFor(
            current,
            traderID,
            record,
            request.now
        )
        if position then request.position = position end
    end

    local actor, result = target.materializeTrader(traderID, request)
    if actor then
        World.NotifyChange("representation_materialized", {
            traderID = traderID,
            fromProvider = currentID,
            toProvider = target.id,
        })
    end
    return actor, result
end

function Runtime.DematerializeTrader(traderID, options)
    options = type(options) == "table" and options or {}
    local record = recordFor(traderID)
    if not record then return nil, "trader_not_found" end
    local current, currentID, policy = providerFor(record)
    if not current or current.kind ~= "physical" then
        return nil, "trader_not_physical"
    end
    local returnProviderID = tostring(
        options.returnProviderID
            or policy.returnProviderID
            or "")
    if returnProviderID == "" then
        return nil, "native_physical_representation"
    end
    if type(current.dematerializeTrader) ~= "function" then
        return nil, "dematerialize_capability_unavailable"
    end
    local request = {}
    for key, value in pairs(options) do request[key] = value end
    request.returnProviderID = returnProviderID
    local actor, result = current.dematerializeTrader(traderID, request)
    if actor then
        local returnProvider = Providers.Get(returnProviderID)
        local position = type(result) == "table"
            and (result.position or result.finalPosition)
            or nil
        if returnProvider
            and type(returnProvider.rebaseMovement) == "function"
            and type(position) == "table"
        then
            local ok, rebased, rebaseReason = pcall(
                returnProvider.rebaseMovement,
                traderID,
                record,
                {
                    position = position,
                    now = request.now,
                    reason = request.reason,
                }
            )
            if not ok or rebased == false or rebased == nil then
                return nil, ok
                    and (rebaseReason or "return_provider_rebase_failed")
                    or tostring(rebased)
            end
        end

        World.NotifyChange("representation_dematerialized", {
            traderID = traderID,
            fromProvider = currentID,
            toProvider = returnProviderID,
        })
    end
    return actor, result
end

function Runtime.Tick(now)
    local summary = {
        checked = 0,
        materialized = 0,
        dematerialized = 0,
        recovered = 0,
    }
    if not Service or type(Service.ForEach) ~= "function" then
        summary.skipped = "trader_service_unavailable"
        return summary
    end
    now = worldAge(now)

    Service.ForEach(function(traderID, record)
        local provider, providerID, policy = providerFor(record)
        if not provider or not policy then return end

        -- Only temporary physical projections carry a returnProviderID.
        if provider.kind == "physical"
            and tostring(policy.returnProviderID or "") ~= ""
            and type(provider.recoverMissingBody) == "function"
        then
            local recovered, reason = provider.recoverMissingBody(
                traderID, {
                    now = now,
                    returnProviderID = policy.returnProviderID,
                })
            if recovered and reason == "recovered_missing_body" then
                summary.recovered = summary.recovered + 1
                provider, providerID, policy = providerFor(record)
                World.NotifyChange("representation_recovered", {
                    traderID = traderID,
                    toProvider = providerID,
                })
            end
        end

        local position = positionFor(
            provider, traderID, record, now)
        local distance = nearestDistance(position)
        summary.checked = summary.checked + 1

        if provider and provider.kind ~= "physical"
            and distance <= Runtime.MATERIALIZE_RADIUS
        then
            local actor = Runtime.MaterializeTrader(traderID, {
                now = now,
                reason = "dt_nearby_materialize",
            })
            if actor then
                summary.materialized = summary.materialized + 1
            end
        elseif provider and provider.kind == "physical"
            and tostring(policy and policy.returnProviderID or "") ~= ""
            and distance > Runtime.DEMATERIALIZE_RADIUS
        then
            local actor = Runtime.DematerializeTrader(traderID, {
                now = now,
                reason = "dt_out_of_range_dematerialize",
            })
            if actor then
                summary.dematerialized = summary.dematerialized + 1
            end
        end
    end)

    return summary
end

local function onTick()
    local at = nowMs()
    if at > 0 and at - lastCheckAt < Runtime.CHECK_INTERVAL_MS then return end
    lastCheckAt = at
    Runtime.Tick(worldAge())
end

if Events and Events.OnTick and type(Events.OnTick.Add) == "function"
    and not Runtime.TickHookRegistered
then
    Runtime.TickHookRegistered = true
    Events.OnTick.Add(onTick)
end

return Runtime
