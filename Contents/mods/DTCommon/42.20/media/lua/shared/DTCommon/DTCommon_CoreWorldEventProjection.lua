-- Standalone Core-owned scoped world-event projection into DTCommon.MarketEvents.
-- Consumes PsychopatzCore.ScopedWorldEvents directly so DynamicTrading operates
-- independently of ProjectHoomans while remaining loop-free and save/reload safe.
-- Kahlua2-safe Lua 5.1: zero pcall, zero next(), zero SettlementDirectory scans.

DTCommon = DTCommon or {}
DTCommon.CoreWorldEventProjection = DTCommon.CoreWorldEventProjection or {}

local Projection = DTCommon.CoreWorldEventProjection

Projection.VERSION = 1
Projection.EVENT_PREFIX = "core-world-event:"
Projection.DT_NATIVE_PREFIX = "dt-market-condition:"
Projection.HOOMANS_PREFIX = "hoomans-world-event:"
Projection.EXCLUDE_SOURCE = "dt-market-condition"
Projection.LISTENER_ID = "dt_common_core_world_event_projection"
Projection.LISTENER_OWNER = "DTCommon"
Projection.MAX_AFFECTED_SETTLEMENTS = 32
Projection.MAX_ACTIVE_SYNC = 32
Projection.MAX_ID_LENGTH = 192
Projection.MAX_MODIFIERS = 16
Projection.MAX_KEY_LENGTH = 128

local NON_ECONOMIC_TYPES = {
    ambient_dog_bark = true,
    ["ambient.dog_bark"] = true,
    ambient_wildlife_owl = true,
    ["ambient.wildlife_owl"] = true,
    ambient_wildlife_wolf = true,
    ["ambient.wildlife_wolf"] = true,
    weather_thunder_clap = true,
    ["weather.thunder_clap"] = true,
    discovery_zone_story_campsite = true,
    ["discovery.zone_story.campsite"] = true,
    discovery_zone_story_recreation_scene = true,
    ["discovery.zone_story.recreation_scene"] = true,
    discovery_zone_story_grave_site = true,
    ["discovery.zone_story.grave_site"] = true,
    discovery_zone_story_hermit_camp = true,
    ["discovery.zone_story.hermit_camp"] = true,
    discovery_zone_story_gathering_site = true,
    ["discovery.zone_story.gathering_site"] = true,
    discovery_vehicle_story_roadkill = true,
    ["discovery.vehicle_story.roadkill"] = true,
}

local _projectedByCoreID = {}
local _tokens = { registered = nil, expired = nil, loaded = nil }
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

local function canonicalType(event)
    local raw = tostring(event and (event.eventType or event.type) or "")
    local meta = type(event and event.metadata) == "table" and event.metadata or {}
    local payload = type(event and event.payload) == "table" and event.payload or {}
    local sem = tostring(meta.semanticType or payload.semanticType or "")
    if sem ~= "" then return string.lower(sem), string.lower(raw) end
    return string.lower(raw), string.lower(raw)
end

local function hoomansProjectionOwns(event)
    if type(event) ~= "table" then return false end
    if tostring(event.source or "") ~= "hoomans-world-event" then
        return false
    end
    local ho = DTHoomans and DTHoomans.WorldEventProjection or nil
    return type(ho) == "table" and type(ho.IsSubscribed) == "function" and ho.IsSubscribed() == true
end

local function isIgnoredEvent(event)
    if type(event) ~= "table" then return true end
    local eventID = tostring(event.eventID or event.id or "")
    if eventID == "" then return true end
    if string.sub(eventID, 1, #Projection.DT_NATIVE_PREFIX) == Projection.DT_NATIVE_PREFIX then
        return true
    end
    if string.sub(eventID, 1, #Projection.HOOMANS_PREFIX) == Projection.HOOMANS_PREFIX then
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
        local seen = {}
        local affected = type(event.affectedSettlements) == "table"
            and event.affectedSettlements or {}
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
        if #targets == 0 then
            local loc = type(event.location) == "table" and event.location or nil
            local payload = type(event.payload) == "table" and event.payload or nil
            local resolvedSettlement = boundedText(
                (loc and loc.settlementID) or (payload and payload.settlementID), 128
            )
            if resolvedSettlement then
                targets[1] = {
                    eventID = makeLocalProjectedID(coreID, resolvedSettlement),
                    scope = { kind = "settlement", id = resolvedSettlement },
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

local function pushModifier(modifiers, tag, supplyDelta, demandDelta, availMult, priceMult)
    if #modifiers >= Projection.MAX_MODIFIERS then return end
    modifiers[#modifiers + 1] = {
        marketTag = tag,
        supplyDelta = clamp(supplyDelta, -1, 1, 0),
        demandDelta = clamp(demandDelta, -1, 1, 0),
        availabilityMultiplier = clamp(availMult, 0.1, 4, 1),
        priceMultiplier = clamp(priceMult, 0.1, 4, 1),
    }
end

local function addTypedVanillaModifiers(modifiers, semType, rawType, effects)
    local match = semType ~= "" and semType or rawType
    match = string.gsub(match, "%.", "_")

    if match == "utility_electricity_cutoff" then
        pushModifier(modifiers, "Fuel", -0.25, 0.35, 0.75, 1.25)
        pushModifier(modifiers, "Tool", -0.10, 0.20, 0.85, 1.15)
        pushModifier(modifiers, "Food", -0.10, 0.15, 0.90, 1.12)
        return true
    elseif match == "utility_water_cutoff" then
        pushModifier(modifiers, "Water", -0.30, 0.40, 0.70, 1.30)
        pushModifier(modifiers, "Food", -0.05, 0.20, 0.88, 1.15)
        pushModifier(modifiers, "Medical", 0, 0.15, 0.92, 1.12)
        return true
    elseif match == "world_helicopter_overflight" then
        pushModifier(modifiers, "Weapon", -0.10, 0.20, 0.88, 1.16)
        pushModifier(modifiers, "Medical", -0.05, 0.15, 0.92, 1.12)
        pushModifier(modifiers, "CaravanRisk", -0.45, 0.45, 0.84, 1.45)
        return true
    elseif match == "ambient_gunfire" then
        pushModifier(modifiers, "Weapon", -0.10, 0.22, 0.88, 1.18)
        pushModifier(modifiers, "CaravanRisk", -0.35, 0.35, 0.88, 1.35)
        return true
    elseif match == "world_house_alarm" or match == "world_fire_outbreak" or match == "weather_severe_storm" then
        local risk = match == "weather_severe_storm" and 0.40 or 0.30
        pushModifier(modifiers, "Tool", -0.10, 0.15, 0.90, 1.10)
        pushModifier(modifiers, "CaravanRisk", -risk, risk, 1 - risk * 0.35, 1 + risk)
        return true
    elseif match == "discovery_vehicle_story_ambulance_crash" or match == "discovery_building_scene_clinic_medical" then
        pushModifier(modifiers, "Medical", 0.20, 0.10, 1.20, 0.90)
        pushModifier(modifiers, "CaravanRisk", -0.20, 0.20, 0.93, 1.20)
        return true
    elseif match == "discovery_vehicle_story_bandit_road"
        or match == "discovery_vehicle_story_police_blockade"
        or match == "discovery_vehicle_story_crash_horde"
        or match == "discovery_dead_survivor_bandit_raid"
        or match == "discovery_building_scene_gunstore_siege"
        or match == "discovery_building_scene_police_siege"
    then
        local risk = (match == "discovery_vehicle_story_bandit_road" or match == "discovery_dead_survivor_bandit_raid") and 0.55 or 0.40
        pushModifier(modifiers, "Weapon", -0.15, 0.25, 0.85, 1.22)
        pushModifier(modifiers, "CaravanRisk", -risk, risk, 1 - risk * 0.35, 1 + risk)
        return true
    elseif match == "discovery_ranch_livestock"
        or match == "discovery_vehicle_story_road_livestock"
        or match == "discovery_zone_story_animal_site"
    then
        pushModifier(modifiers, "Food", 0.25, -0.15, 1.25, 0.88)
        return true
    elseif match == "discovery_building_scene_looted_structure" then
        pushModifier(modifiers, "Tool", -0.15, 0.15, 0.85, 1.15)
        return true
    end
    return false
end

local function buildModifiers(event)
    local semType, rawType = canonicalType(event)
    if NON_ECONOMIC_TYPES[semType] or NON_ECONOMIC_TYPES[rawType] then
        return {}
    end

    local effects = type(event.effects) == "table" and event.effects or {}
    local modifiers = {}
    addTypedVanillaModifiers(modifiers, semType, rawType, effects)
    if #modifiers > 0 then
        return modifiers
    end

    local foodPressure = finite(effects.foodAvailabilityPressure, 0)
        + 0.5 * finite(effects.tradeScarcity, 0)
        + 0.35 * (1 - finite(effects.scavengingYieldMultiplier, 1))
    if math.abs(foodPressure) <= 0.001 then
        if rawType == "food_crisis" then
            foodPressure = 0.5
        elseif rawType == "agricultural_surplus" then
            foodPressure = -0.5
        end
    end
    if foodPressure > 0.001 then
        pushModifier(modifiers, "Food", -foodPressure * 0.4, foodPressure * 0.35, 1 - foodPressure * 0.45, 1 + foodPressure * 0.35)
    elseif foodPressure < -0.001 then
        local surplus = -foodPressure
        pushModifier(modifiers, "Food", surplus * 0.4, -surplus * 0.3, 1 + surplus * 0.45, 1 - surplus * 0.25)
    end

    local caravanRisk = finite(effects.caravanRisk, 0)
    local travelRisk = finite(effects.travelRisk, 0)
    local hostilityDelta = math.max(0, finite(effects.hostileActivityMultiplier, 1) - 1)
    local tradeScarcity = finite(effects.tradeScarcity, 0)
    local medicalDemand = finite(effects.medicalDemand, 0)
    local routeRisk = math.max(caravanRisk, travelRisk) + hostilityDelta * 0.5
    if routeRisk == 0 and (rawType == "bandit_bonanza" or rawType == "trade_disruption") then
        routeRisk = 0.5
    end
    if routeRisk > 0.001 or hostilityDelta > 0.001 then
        local weaponPressure = clamp(math.max(0, routeRisk) * 0.6 + hostilityDelta * 0.4, 0.05, 1.5, 0.25)
        pushModifier(modifiers, "Weapon", -weaponPressure * 0.25, weaponPressure * 0.35, 1 - weaponPressure * 0.25, 1 + weaponPressure * 0.3)
    end
    local medPressure = clamp(medicalDemand + math.max(0, routeRisk) * 0.4 + hostilityDelta * 0.3, -1, 2, 0)
    if medPressure > 0.001 then
        pushModifier(modifiers, "Medical", -medPressure * 0.2, medPressure * 0.35, 1 - medPressure * 0.2, 1 + medPressure * 0.25)
    elseif medPressure < -0.001 then
        local medRelief = -medPressure
        pushModifier(modifiers, "Medical", medRelief * 0.2, -medRelief * 0.3, 1 + medRelief * 0.2, 1 - medRelief * 0.2)
    end
    if tradeScarcity > 0.001 and #modifiers < Projection.MAX_MODIFIERS - 2 then
        pushModifier(modifiers, "Tool", -tradeScarcity * 0.25, tradeScarcity * 0.2, 1 - tradeScarcity * 0.3, 1 + tradeScarcity * 0.25)
        pushModifier(modifiers, "Resource", -tradeScarcity * 0.25, tradeScarcity * 0.2, 1 - tradeScarcity * 0.3, 1 + tradeScarcity * 0.25)
    end
    if routeRisk ~= 0 or caravanRisk ~= 0 or travelRisk ~= 0 or hostilityDelta > 0.001 then
        pushModifier(modifiers, "CaravanRisk", -routeRisk, routeRisk, 1 - routeRisk * 0.35, 1 + math.max(0, routeRisk))
    end
    return modifiers
end

local function buildPresentation(event)
    local eventType = boundedText(event.eventType or event.type or "generic", 64) or "generic"
    local severity = clamp(event.severity, 0, 1, 0.5)
    local importance = math.max(1, math.min(5, math.floor(severity * 4 + 1)))
    return {
        headlineKey = boundedText("DTCommon_WorldEvent_" .. eventType .. "_Headline", Projection.MAX_KEY_LENGTH),
        descriptionKey = boundedText("DTCommon_WorldEvent_" .. eventType .. "_Description", Projection.MAX_KEY_LENGTH),
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
    if hoomansProjectionOwns(event) then
        return false, "delegated_to_dt_hoomans"
    end

    local coreID = boundedText(event.eventID or event.id, Projection.MAX_ID_LENGTH)
    local modifiers = buildModifiers(event)
    if #modifiers == 0 then
        return false, "not_economically_relevant"
    end

    local targets = projectedTargets(event)
    if #targets == 0 then
        return false, "no_projected_targets"
    end

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

function Projection.ReconcileSnapshot(activeEvents)
    if not allowsServerCode() then
        return 0, "server_authority_required"
    end
    local events = marketEvents()
    local activeSet = {}
    local list = type(activeEvents) == "table" and activeEvents or {}
    for index = 1, math.min(#list, Projection.MAX_ACTIVE_SYNC) do
        local ev = list[index]
        local coreID = type(ev) == "table" and boundedText(ev.eventID or ev.id, Projection.MAX_ID_LENGTH) or nil
        if coreID then activeSet[coreID] = true end
    end
    local trackedKeys = {}
    for coreID in pairs(_projectedByCoreID) do
        if not activeSet[coreID] then
            trackedKeys[#trackedKeys + 1] = coreID
        end
    end
    for index = 1, #trackedKeys do
        local coreID = trackedKeys[index]
        local ids = _projectedByCoreID[coreID]
        if events and type(events.Remove) == "function" and type(ids) == "table" then
            for j = 1, #ids do
                events.Remove(ids[j])
            end
        end
        _projectedByCoreID[coreID] = nil
    end

    local projected = 0
    for index = 1, math.min(#list, Projection.MAX_ACTIVE_SYNC) do
        local ok = Projection.ProjectEvent(list[index])
        if ok then
            projected = projected + 1
        end
    end
    return projected
end

local function onEventRegistered(event)
    Projection.ProjectEvent(event)
end

local function onEventExpired(event)
    Projection.ExpireEvent(event)
end

local function onStateLoaded(snapshot)
    local active = type(snapshot) == "table" and snapshot.activeEvents or nil
    if type(active) == "table" then
        Projection.ReconcileSnapshot(active)
    else
        Projection.SyncActive()
    end
end

function Projection.IsSubscribed()
    return _subscribedRegistry ~= nil and _tokens.registered ~= nil
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
    if type(scoped.OnStateLoaded) == "function" then
        _tokens.loaded = scoped.OnStateLoaded(onStateLoaded, {
            id = Projection.LISTENER_ID .. ":loaded",
            owner = Projection.LISTENER_OWNER,
        })
    end
    _subscribedRegistry = scoped
    return _tokens.registered ~= nil and _tokens.expired ~= nil
end

function Projection.Unsubscribe()
    if _subscribedRegistry and type(_subscribedRegistry.Unsubscribe) == "function" then
        if _tokens.registered then _subscribedRegistry.Unsubscribe(_tokens.registered) end
        if _tokens.expired then _subscribedRegistry.Unsubscribe(_tokens.expired) end
        if _tokens.loaded then _subscribedRegistry.Unsubscribe(_tokens.loaded) end
    end
    _tokens.registered = nil
    _tokens.expired = nil
    _tokens.loaded = nil
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
    return Projection.ReconcileSnapshot(active)
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
