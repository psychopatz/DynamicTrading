local T = require "tests/support/test"

package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] =
    function() return {} end

DTCommon = {}
PsychopatzCore = {
    RuntimeRole = {
        AllowsServerCode = function() return true end,
    },
}

local Constants = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_Constants.lua")
local Schema = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua")
local Storage = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
local Events = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEvents.lua")

local function register(eventID, definition)
    local event, created = Events.Register(eventID, definition)
    T.truthy(event, "event registered: " .. tostring(eventID))
    T.truthy(created, "new event is reported as created")
    return event
end

register("event:global", {
    type = "synthetic_global",
    startsAt = 10,
    endsAt = 20,
    scope = { kind = "global" },
    modifiers = {
        {
            marketTag = "Food",
            demandDelta = 0.1,
            availabilityMultiplier = 0.9,
            priceMultiplier = 1.1,
        },
    },
})
register("event:faction", {
    type = "synthetic_faction",
    startsAt = 10,
    endsAt = 20,
    scope = { kind = "faction", id = "faction-a" },
    modifiers = {
        { marketTag = "Food", supplyDelta = 0.1 },
    },
})
register("event:region", {
    type = "synthetic_region",
    startsAt = 10,
    endsAt = 20,
    scope = { kind = "region", id = "region-a" },
    modifiers = {
        { marketTag = "Food", demandDelta = 0.1 },
    },
})
register("event:settlement-a", {
    type = "synthetic_settlement",
    startsAt = 10,
    endsAt = 20,
    scope = { kind = "settlement", id = "settlement-a" },
    modifiers = {
        {
            marketTag = "Food",
            supplyDelta = -0.2,
            demandDelta = 0.2,
            availabilityMultiplier = 0.7,
            priceMultiplier = 1.2,
        },
    },
})

local record = { g = "faction-a", unchanged = true }
local active = Events.ResolveContext("settlement-a", record, {
    regionID = "region-a",
    now = 15,
})
T.equal(active.activeEventCount, 4,
    "all matching global, region, faction, settlement events resolve")
T.equal(#active.modifiers, 1, "same category modifiers aggregate")
T.truthy(math.abs(active.modifiers[1].supplyDelta + 0.1) < 0.000001,
    "scoped supply deltas aggregate deterministically")
T.truthy(math.abs(active.modifiers[1].demandDelta - 0.4) < 0.000001,
    "scoped demand deltas aggregate deterministically")
T.truthy(math.abs(active.modifiers[1].availabilityMultiplier - 0.63)
    < 0.000001, "availability factors stay bounded and compose")
T.truthy(math.abs(active.modifiers[1].priceMultiplier - 1.32)
    < 0.000001, "price factors stay bounded and compose")
T.truthy(active.revision > 0, "active context has a deterministic revision")

local factionOnly = Events.ResolveContext("settlement-b", record, {
    regionID = "region-a",
    now = 15,
})
T.equal(factionOnly.activeEventCount, 3,
    "settlement scope does not leak to another settlement")

local globalOnly = Events.ResolveContext("settlement-b", {
    g = "faction-b",
}, {
    regionID = "region-b",
    now = 15,
})
T.equal(globalOnly.activeEventCount, 1,
    "global scope remains available without matching local scopes")

local beforeStart = Events.ResolveContext("settlement-a", record, {
    regionID = "region-a",
    now = 5,
})
local afterExpiry = Events.ResolveContext("settlement-a", record, {
    regionID = "region-a",
    now = 20,
})
T.equal(beforeStart.activeEventCount, 0, "future events are inactive")
T.equal(afterExpiry.activeEventCount, 0,
    "end timestamp is an exclusive deterministic expiry")
T.truthy(beforeStart.revision ~= active.revision,
    "event activation changes context revision")
T.truthy(afterExpiry.revision ~= active.revision,
    "event expiry changes context revision")

local badVersion, badVersionReason = Events.Register("event:future", {
    schemaVersion = 2,
    scope = { kind = "global" },
})
T.equal(badVersion, nil, "future event schema is rejected")
T.equal(badVersionReason, "event_schema_version_unsupported",
    "future event schema reason is explicit")
local badScope, badScopeReason = Events.Register("event:scope-missing", {
    scope = { kind = "settlement" },
})
T.equal(badScope, nil, "non-global scope requires an identity")
T.equal(badScopeReason, "event_scope_id_required",
    "missing event scope identity reason is explicit")

local stored = Storage.GetEventData()
T.truthy(stored.events["event:settlement-a"],
    "event registry persists in its separate envelope")
T.truthy(stored.revision >= 4, "event writes advance the event revision")
T.equal(record.unchanged, true,
    "event registration does not rewrite trader state")

DTCommon.CoreActorPolicy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.MarketSchema = Schema
DTCommon.MarketEvents = Events
DTCommon.SettlementMarket = {
    Get = function()
        return {
            revision = 2,
            categories = { Food = { supply = 0.5, demand = 0.5 } },
        }
    end,
}
DTCommon.MarketCatalog = {
    Get = function(fullType)
        return fullType == "Base.CannedBeans"
            and { fullType = fullType, category = "Food" } or nil
    end,
}
MarketSense = {
    GetPriceDetails = function() return { price = 100 } end,
    GetPriceDetailsForInstance = function() return { price = 100 } end,
}
local Pricing = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketPricing.lua")
local Stock = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderStock.lua")
local pricedRecord = {
    g = "faction-a",
    ca = DTCommon.CoreActorPolicy.New({
        lastSettlementID = "settlement-a",
    }),
}
local pricedContext = Pricing.BuildContext(pricedRecord, nil, {
    regionID = "region-a",
    now = 15,
})
local priced = Stock.Quote("Base.CannedBeans", DTCommon.OP_BUY, nil,
    pricedContext)
T.equal(priced.unitPrice, 149,
    "generic scoped event modifiers reach the existing quote boundary")
T.equal(priced.availabilityMultiplier, 0.63,
    "generic event availability reaches the quote context")
T.equal(priced.explanation.eventCount, 1,
    "quote explanation reports the aggregated active event context")
T.equal(priced.explanation.activeEventCount, 4,
    "quote explanation reports all matching active events")
T.truthy(Pricing.IsCurrent(pricedContext),
    "pricing context is current at its deterministic timestamp")

local expiredContext = Pricing.BuildContext(pricedRecord, nil, {
    regionID = "region-a",
    now = 20,
})
local expiredQuote = Stock.Quote("Base.CannedBeans", DTCommon.OP_BUY, nil,
    expiredContext)
T.equal(expiredQuote.unitPrice, 100,
    "event expiry restores the neutral market context")
T.equal(expiredQuote.activeEventCount, 0,
    "expired events no longer reach commercial quotes")

local worldHours = 15
getGameTime = function()
    return {
        getWorldAgeHours = function() return worldHours end,
    }
end
local timedContext = Pricing.BuildContext(pricedRecord)
worldHours = 20
local timedCurrent, timedReason = Pricing.IsCurrent(timedContext)
T.falsy(timedCurrent, "time-window change invalidates a live quote context")
T.equal(timedReason, "stale_event", "stale event reason is explicit")
getGameTime = nil

local removed, removeReason = Events.Remove("event:settlement-a")
T.truthy(removed, removeReason)
local afterRemove = Events.ResolveContext("settlement-a", record, {
    regionID = "region-a",
    now = 15,
})
T.equal(afterRemove.activeEventCount, 3,
    "removing a typed event updates only the effective context")

T.finish("dt_market_events")
