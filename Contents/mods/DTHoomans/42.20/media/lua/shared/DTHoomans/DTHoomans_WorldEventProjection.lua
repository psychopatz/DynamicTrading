-- Bounded, loop-free one-way projection of authoritative Core/Hoomans scoped
-- world events into DTCommon.MarketEvents.
-- Kahlua2-safe Lua 5.1: zero pcall, zero next(), zero per-tick polling.

DTHoomans = DTHoomans or {}
DTHoomans.WorldEventProjection = DTHoomans.WorldEventProjection or {}

local Projection = DTHoomans.WorldEventProjection

Projection.VERSION = 1
Projection.EVENT_PREFIX = "hoomans-world-event:"
Projection.DT_NATIVE_PREFIX = "dt-market-condition:"
Projection.EXCLUDE_SOURCE = "dt-market-condition"
Projection.LISTENER_ID = "dt_hoomans_world_event_projection"
Projection.LISTENER_OWNER = "DTHoomans"
Projection.MAX_AFFECTED_SETTLEMENTS = 32
Projection.MAX_ACTIVE_SYNC = 32
Projection.MAX_ID_LENGTH = 192
Projection.MAX_MODIFIERS = 16
Projection.MAX_KEY_LENGTH = 128

local _projectedByCoreID = {}
local _tokens = { registered = nil, expired = nil }
local _subscribedRegistry = nil

local function finite(value, fallback)
    local num = tonumber(value)
    if num == nil or num ~= num or num == math.huge or num == -math.huge then
        return fallback
    end
    return num
end

local function clamp(value, low, high, fallback)
    local num = finite(value, fallback)
    if num == nil then return nil end
    return math.max(low, math.min(high, num))
end

local function boundedText(value, maximum)
    if value == nil then return nil end
    local text = tostring(value)
    if text == "" then return nil end
    local limit = maximum or Projection.MAX_ID_LENGTH
    if #text > limit then
        return string.sub(text, 1, limit)
    end
    return text
end

local function hashText(value)
    local result = 17
    local text = tostring(value or "")
    for index = 1, #text do
        result = (result * 31 + string.byte(text, index)) % 2147483647
    end
    return tostring(result)
end

local function allowsServerCode()
    local runtime = PsychopatzCore and PsychopatzCore.RuntimeRole or nil
    if runtime and type(runtime.AllowsServerCode) == "function" then
        return runtime.AllowsServerCode() == true
    end
    local storage = DTCommon and DTCommon.Storage or nil
    if storage and type(storage.IsAuthority) == "function" then
        return storage.IsAuthority() == true
    end
    local isClientFn = rawget(_G, "isClient")
    if type(isClientFn) == "function" then
        return isClientFn() ~= true
    end
    return true
end

local function scopedRegistry()
    return PsychopatzCore and PsychopatzCore.ScopedWorldEvents or nil
end

local function marketEvents()
    return DTCommon and DTCommon.MarketEvents or nil
end

local function isIgnoredEvent(event)
    if type(event) ~= "table" then return true end
    local eventID = tostring(event.eventID or event.id or "")
    if eventID == "" then return true end
    if string.sub(eventID, 1, #Projection.DT_NATIVE_PREFIX) == Projection.DT_NATIVE_PREFIX then
        return true
    end
    if string.sub(eventID, 1, #Projection.EVENT_PREFIX) == Projection.EVENT_PREFIX then
        return true
    end
    local source = tostring(event.source or "")
    if source == Projection.EXCLUDE_SOURCE
        or source == "dynamictrading:market-events"
        or string.sub(source, 1, 3) == "dt-"
    then
        return true
    end
    return false
end

local function makeLocalProjectedID(coreID, settlementID)
    local candidate = Projection.EVENT_PREFIX .. coreID .. ":" .. settlementID
    if #candidate <= Projection.MAX_ID_LENGTH then
        return candidate
    end
    local digest = hashText(coreID .. "|" .. settlementID)
    local head = string.sub(Projection.EVENT_PREFIX .. coreID, 1, 130)
    local tail = string.sub(settlementID, 1, 32)
    return boundedText(head .. ":" .. digest .. ":" .. tail, Projection.MAX_ID_LENGTH)
end

local function projectedTargets(event)
    local coreID = boundedText(event.eventID or event.id, Projection.MAX_ID_LENGTH)
    if not coreID then return {} end
    local scope = tostring(event.scope or "")
    local targets = {}
    if scope == "local_area" then
        local affected = type(event.affectedSettlements) == "table"
            and event.affectedSettlements or {}
        local seen = {}
        local count = math.min(#affected, Projection.MAX_AFFECTED_SETTLEMENTS)
        for index = 1, count do
            local settlementID = boundedText(affected[index], 128)
            if settlementID and not seen[settlementID] then
                seen[settlementID] = true
                targets[#targets + 1] = {
                    eventID = makeLocalProjectedID(coreID, settlementID),
                    scope = { kind = "settlement", id = settlementID },
                }
            end
        end
        return targets
    end
    if scope ~= "global" and scope ~= "region" and scope ~= "faction" and scope ~= "settlement" then
        return {}
    end
    local scopeID = scope ~= "global" and boundedText(event.scopeID or event.scopeId, Projection.MAX_ID_LENGTH) or nil
    if scope ~= "global" and not scopeID then
        return {}
    end
    targets[1] = {
        eventID = boundedText(Projection.EVENT_PREFIX .. coreID, Projection.MAX_ID_LENGTH),
        scope = { kind = scope, id = scopeID },
    }
    return targets
end

local function buildModifiers(event)
    local effects = type(event.effects) == "table" and event.effects or {}
    local eventType = tostring(event.eventType or event.type or "generic")
    local modifiers = {}

    local foodPressure = finite(effects.foodAvailabilityPressure, 0)
        + 0.5 * finite(effects.tradeScarcity, 0)
        + 0.35 * (1 - finite(effects.scavengingYieldMultiplier, 1))
    if math.abs(foodPressure) <= 0.001 then
        if eventType == "food_crisis" then
            foodPressure = 0.5
        elseif eventType == "agricultural_surplus" then
            foodPressure = -0.5
        end
    end

    if foodPressure > 0.001 then
        modifiers[#modifiers + 1] = {
            marketTag = "Food",
            supplyDelta = clamp(-foodPressure * 0.4, -0.8, -0.05, -0.1),
            demandDelta = clamp(foodPressure * 0.35, 0.05, 0.8, 0.1),
            availabilityMultiplier = clamp(1 - foodPressure * 0.45, 0.25, 0.95, 0.75),
            priceMultiplier = clamp(1 + foodPressure * 0.35, 1.05, 2.5, 1.15),
        }
    elseif foodPressure < -0.001 then
        local surplus = -foodPressure
        modifiers[#modifiers + 1] = {
            marketTag = "Food",
            supplyDelta = clamp(surplus * 0.4, 0.05, 0.8, 0.1),
            demandDelta = clamp(-surplus * 0.3, -0.8, -0.05, -0.1),
            availabilityMultiplier = clamp(1 + surplus * 0.45, 1.05, 2.5, 1.25),
            priceMultiplier = clamp(1 - surplus * 0.25, 0.4, 0.95, 0.85),
        }
    end

    local caravanRisk = finite(effects.caravanRisk, 0)
    local travelRisk = finite(effects.travelRisk, 0)
    local hostilityDelta = math.max(0, finite(effects.hostileActivityMultiplier, 1) - 1)
    local tradeScarcity = finite(effects.tradeScarcity, 0)
    local medicalDemand = finite(effects.medicalDemand, 0)

    local routeRisk = math.max(caravanRisk, travelRisk) + hostilityDelta * 0.5
    if routeRisk == 0 and (eventType == "bandit_bonanza" or eventType == "trade_disruption") then
        routeRisk = 0.5
    end

    if routeRisk > 0.001 or hostilityDelta > 0.001 then
        local weaponPressure = clamp(math.max(0, routeRisk) * 0.6 + hostilityDelta * 0.4, 0.05, 1.5, 0.25)
        modifiers[#modifiers + 1] = {
            marketTag = "Weapon",
            supplyDelta = clamp(-weaponPressure * 0.25, -0.6, -0.02, -0.1),
            demandDelta = clamp(weaponPressure * 0.35, 0.05, 0.8, 0.15),
            availabilityMultiplier = clamp(1 - weaponPressure * 0.25, 0.4, 0.98, 0.85),
            priceMultiplier = clamp(1 + weaponPressure * 0.3, 1.02, 2.2, 1.15),
        }
    end

    local medPressure = clamp(medicalDemand + math.max(0, routeRisk) * 0.4 + hostilityDelta * 0.3, -1, 2, 0)
    if medPressure > 0.001 then
        modifiers[#modifiers + 1] = {
            marketTag = "Medical",
            supplyDelta = clamp(-medPressure * 0.2, -0.5, -0.02, -0.05),
            demandDelta = clamp(medPressure * 0.35, 0.05, 0.8, 0.15),
            availabilityMultiplier = clamp(1 - medPressure * 0.2, 0.4, 0.98, 0.85),
            priceMultiplier = clamp(1 + medPressure * 0.25, 1.02, 2.2, 1.1),
        }
    elseif medPressure < -0.001 then
        local medRelief = -medPressure
        modifiers[#modifiers + 1] = {
            marketTag = "Medical",
            supplyDelta = clamp(medRelief * 0.2, 0.02, 0.5, 0.05),
            demandDelta = clamp(-medRelief * 0.3, -0.6, -0.05, -0.1),
            availabilityMultiplier = clamp(1 + medRelief * 0.2, 1.02, 1.8, 1.1),
            priceMultiplier = clamp(1 - medRelief * 0.2, 0.5, 0.98, 0.9),
        }
    end

    if tradeScarcity > 0.001 and #modifiers < Projection.MAX_MODIFIERS - 2 then
        modifiers[#modifiers + 1] = {
            marketTag = "Tool",
            supplyDelta = clamp(-tradeScarcity * 0.25, -0.6, -0.02, -0.1),
            demandDelta = clamp(tradeScarcity * 0.2, 0.02, 0.6, 0.1),
            availabilityMultiplier = clamp(1 - tradeScarcity * 0.3, 0.35, 0.98, 0.85),
            priceMultiplier = clamp(1 + tradeScarcity * 0.25, 1.02, 2.0, 1.1),
        }
        modifiers[#modifiers + 1] = {
            marketTag = "Resource",
            supplyDelta = clamp(-tradeScarcity * 0.25, -0.6, -0.02, -0.1),
            demandDelta = clamp(tradeScarcity * 0.2, 0.02, 0.6, 0.1),
            availabilityMultiplier = clamp(1 - tradeScarcity * 0.3, 0.35, 0.98, 0.85),
            priceMultiplier = clamp(1 + tradeScarcity * 0.25, 1.02, 2.0, 1.1),
        }
    end

    if (routeRisk ~= 0 or caravanRisk ~= 0 or travelRisk ~= 0 or hostilityDelta > 0.001)
        and #modifiers < Projection.MAX_MODIFIERS
    then
        modifiers[#modifiers + 1] = {
            marketTag = "CaravanRisk",
            supplyDelta = clamp(-routeRisk, -1, 1, 0),
            demandDelta = clamp(routeRisk, -1, 1, 0),
            availabilityMultiplier = clamp(1 - routeRisk * 0.35, 0.1, 4, 1),
            priceMultiplier = clamp(1 + math.max(0, routeRisk), 0.1, 4, 1),
        }
    end

    return modifiers
end

local function buildPresentation(event)
    local eventType = boundedText(event.eventType or event.type or "generic", 64) or "generic"
    local severity = clamp(event.severity, 0, 1, 0.5)
    local importance = math.max(1, math.min(5, math.floor(severity * 4 + 1)))
    return {
        headlineKey = boundedText("DTHoomans_WorldEvent_" .. eventType .. "_Headline", Projection.MAX_KEY_LENGTH),
        descriptionKey = boundedText("DTHoomans_WorldEvent_" .. eventType .. "_Description", Projection.MAX_KEY_LENGTH),
        importance = importance,
    }
end

function Projection.ProjectEvent(event)
    if not allowsServerCode() then
        return false, "server_authority_required"
    end
    local events = marketEvents()
    if not events or type(events.Register) ~= "function" then
        return false, "market_event_registry_unavailable"
    end
    if isIgnoredEvent(event) then
        return false, "ignored_event"
    end

    local coreID = boundedText(event.eventID or event.id, Projection.MAX_ID_LENGTH)
    local targets = projectedTargets(event)
    if #targets == 0 then
        return false, "no_projected_targets"
    end

    local modifiers = buildModifiers(event)
    local presentation = buildPresentation(event)
    local startsAt = math.max(0, finite(event.startsAt, 0))
    local endsAt = event.endsAt ~= nil and math.max(startsAt, finite(event.endsAt, startsAt)) or nil
    local eventType = boundedText(event.eventType or event.type or "generic", 96) or "generic"

    local nextIDSet = {}
    for index = 1, #targets do
        nextIDSet[targets[index].eventID] = true
    end
    local previousIDs = _projectedByCoreID[coreID]
    if type(previousIDs) == "table" and type(events.Remove) == "function" then
        for index = 1, #previousIDs do
            local prevID = previousIDs[index]
            if not nextIDSet[prevID] then
                events.Remove(prevID)
            end
        end
    end

    local projectedIDs = {}
    for index = 1, #targets do
        local target = targets[index]
        local registered = events.Register(target.eventID, {
            schemaVersion = 1,
            eventID = target.eventID,
            type = eventType,
            startsAt = startsAt,
            endsAt = endsAt,
            scope = target.scope,
            modifiers = modifiers,
            presentation = presentation,
        })
        if registered then
            projectedIDs[#projectedIDs + 1] = target.eventID
        end
    end
    _projectedByCoreID[coreID] = projectedIDs
    return #projectedIDs > 0, projectedIDs
end

function Projection.ExpireEvent(event)
    if not allowsServerCode() then
        return false, "server_authority_required"
    end
    local events = marketEvents()
    if not events or type(events.Remove) ~= "function" then
        return false, "market_event_registry_unavailable"
    end
    if isIgnoredEvent(event) then
        return false, "ignored_event"
    end

    local coreID = boundedText(event.eventID or event.id, Projection.MAX_ID_LENGTH)
    local toRemove = {}
    local seen = {}

    local tracked = _projectedByCoreID[coreID]
    if type(tracked) == "table" then
        for index = 1, #tracked do
            local id = tracked[index]
            if id and not seen[id] then
                seen[id] = true
                toRemove[#toRemove + 1] = id
            end
        end
    end

    local targets = projectedTargets(event)
    for index = 1, #targets do
        local id = targets[index].eventID
        if id and not seen[id] then
            seen[id] = true
            toRemove[#toRemove + 1] = id
        end
    end

    local removed = 0
    for index = 1, #toRemove do
        if events.Remove(toRemove[index]) == true then
            removed = removed + 1
        end
    end
    _projectedByCoreID[coreID] = nil
    return true, removed
end

local function onEventRegistered(event)
    Projection.ProjectEvent(event)
end

local function onEventExpired(event)
    Projection.ExpireEvent(event)
end

function Projection.EnsureSubscribed()
    if not allowsServerCode() then
        return false, "server_authority_required"
    end
    local scoped = scopedRegistry()
    if not scoped
        or type(scoped.OnEventRegistered) ~= "function"
        or type(scoped.OnEventExpired) ~= "function"
    then
        return false, "scoped_world_events_unavailable"
    end
    if _subscribedRegistry == scoped and _tokens.registered and _tokens.expired then
        return true, "already_subscribed"
    end

    _tokens.registered = scoped.OnEventRegistered(onEventRegistered, {
        id = Projection.LISTENER_ID .. ":registered",
        owner = Projection.LISTENER_OWNER,
        excludeSource = Projection.EXCLUDE_SOURCE,
    })
    _tokens.expired = scoped.OnEventExpired(onEventExpired, {
        id = Projection.LISTENER_ID .. ":expired",
        owner = Projection.LISTENER_OWNER,
        excludeSource = Projection.EXCLUDE_SOURCE,
    })
    _subscribedRegistry = scoped
    return _tokens.registered ~= nil and _tokens.expired ~= nil
end

function Projection.Unsubscribe()
    if _subscribedRegistry and type(_subscribedRegistry.Unsubscribe) == "function" then
        if _tokens.registered then _subscribedRegistry.Unsubscribe(_tokens.registered) end
        if _tokens.expired then _subscribedRegistry.Unsubscribe(_tokens.expired) end
    end
    _tokens.registered = nil
    _tokens.expired = nil
    _subscribedRegistry = nil
end

function Projection.SyncActive(nowHours)
    if not allowsServerCode() then
        return 0, "server_authority_required"
    end
    local scoped = scopedRegistry()
    if not scoped or type(scoped.QueryActive) ~= "function" then
        return 0, "scoped_world_events_unavailable"
    end
    local active = scoped.QueryActive({}, nowHours)
    local projected = 0
    local limit = math.min(#(active or {}), Projection.MAX_ACTIVE_SYNC)
    for index = 1, limit do
        local ok = Projection.ProjectEvent(active[index])
        if ok then
            projected = projected + 1
        end
    end
    return projected
end

function Projection.ResetState()
    _projectedByCoreID = {}
    Projection.Unsubscribe()
end

Projection.EnsureSubscribed()

if Events and Events.OnGameStart
    and type(Events.OnGameStart.Add) == "function"
    and not Projection.StartHookRegistered
then
    Projection.StartHookRegistered = true
    Events.OnGameStart.Add(function()
        Projection.EnsureSubscribed()
        Projection.SyncActive()
    end)
end

return Projection
