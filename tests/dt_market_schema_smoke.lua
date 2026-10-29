local T = require "tests/support/test"

DTCommon = {}
local Schema = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua")
local function countEntries(value)
    local count = 0
    for _, _ in pairs(value or {}) do count = count + 1 end
    return count
end

local empty = Schema.NewSettlementMarket("community_empty")
T.truthy(empty, "empty market gets a schema default")
T.equal(empty.schemaVersion, 1, "market schema version is explicit")
T.equal(empty.settlementID, "community_empty", "market identity is explicit")
T.equal(empty.profileID, "default", "partial market gets a default profile")
T.equal(empty.revision, 0, "partial market gets a zero revision")
T.equal(empty.wealth, 0.5, "partial market gets neutral wealth")
T.equal(countEntries(empty.categories), 0, "partial market has no item ledger")

local market, marketReason = Schema.NormalizeMarket({
    schemaVersion = 0,
    settlementID = "community_partial",
    profileID = "farm",
    revision = -4,
    lastUpdateAt = -2,
    wealth = 2,
    categories = {
        food = { supply = 2, demand = -1 },
        unknown_market_tag = { supply = 0.25, demand = 0.75 },
    },
    ignoredField = "dropped",
})
T.truthy(market, marketReason)
T.equal(market.schemaVersion, 1, "old market version migrates")
T.equal(market.revision, 0, "market revision clamps at zero")
T.equal(market.lastUpdateAt, 0, "market timestamp clamps at zero")
T.equal(market.wealth, 1, "market wealth clamps to one")
T.equal(market.categories.food.supply, 1, "category supply clamps")
T.equal(market.categories.food.demand, 0, "category demand clamps")
T.equal(market.categories.unknown_market_tag.supply, 0.25,
    "unknown categories remain generic data")
T.equal(market.ignoredField, nil, "unknown market fields are not persisted")

local missingID, missingIDReason = Schema.NormalizeMarket({})
T.equal(missingID, nil, "market identity is required")
T.equal(missingIDReason, "settlement_id_required",
    "missing market identity has a stable reason")
local futureMarket, futureMarketReason = Schema.NormalizeMarket({
    schemaVersion = 99,
    settlementID = "community_future",
})
T.equal(futureMarket, nil, "future market schemas are not silently accepted")
T.equal(futureMarketReason, "market_schema_version_unsupported",
    "future market schema has a stable reason")

local marketStore = Schema.NewMarketStore({
    schemaVersion = 0,
    revision = -2,
    markets = {
        community_a = { profileID = "farm" },
        community_b = { profileID = "military", wealth = 0.8 },
    },
    ignoredField = true,
})
T.truthy(marketStore, "market store has a default envelope")
T.equal(marketStore.schemaVersion, 1, "market store schema is explicit")
T.equal(marketStore.revision, 0, "market store revision clamps")
T.equal(marketStore.markets.community_a.settlementID, "community_a",
    "market store supplies the map identity")
T.equal(marketStore.markets.community_b.profileID, "military",
    "market store keeps bounded records")
T.equal(marketStore.ignoredField, nil, "unknown store fields are dropped")
local emptyMarketStore = Schema.NewMarketStore()
T.equal(emptyMarketStore.schemaVersion, 1,
    "absent market store gets a schema default")
T.equal(countEntries(emptyMarketStore.markets), 0,
    "absent market store has no item ledger")

local event, eventReason = Schema.NewEvent({
    schemaVersion = 0,
    eventID = "event_shortage",
    type = "food_shortage",
    startsAt = 10,
    endsAt = 3,
    scope = { kind = "settlement", id = "community_a" },
    modifiers = {
        {
            marketTag = "food",
            supplyDelta = -2,
            demandDelta = 2,
            availabilityMultiplier = 8,
            priceMultiplier = -1,
        },
        { category = "medical", demandDelta = 0.25 },
    },
    presentation = { headlineKey = "UI_shortage", importance = 9 },
    ignoredField = "dropped",
})
T.truthy(event, eventReason)
T.equal(event.schemaVersion, 1, "old event version migrates")
T.equal(event.endsAt, 10, "event expiry cannot precede its start")
T.equal(event.scope.kind, "settlement", "event scope is typed")
T.equal(event.scope.id, "community_a", "event scope carries its identity")
T.equal(event.modifiers[1].supplyDelta, -1, "event supply delta clamps")
T.equal(event.modifiers[1].demandDelta, 1, "event demand delta clamps")
T.equal(event.modifiers[1].availabilityMultiplier, 4,
    "availability multiplier clamps")
T.equal(event.modifiers[1].priceMultiplier, 0,
    "price multiplier clamps")
T.equal(event.modifiers[2].marketTag, "medical",
    "event category aliases remain data-driven")
T.equal(event.presentation.importance, 5, "event importance clamps")
T.equal(event.ignoredField, nil, "unknown event fields are dropped")

local generic = Schema.NewEvent("event_generic")
T.truthy(generic, "event identity can be supplied by the registry")
T.equal(generic.type, "generic", "partial event gets a generic type")
T.equal(generic.scope.kind, "global", "partial event defaults to global scope")
T.equal(#generic.modifiers, 0, "partial event has no modifiers")

local invalidScope, invalidScopeReason = Schema.NewEvent({
    eventID = "event_invalid_scope",
    scope = { kind = "item", id = "Base.Bandage" },
})
T.equal(invalidScope, nil, "unknown event scope is rejected")
T.equal(invalidScopeReason, "event_scope_invalid",
    "unknown event scope has a stable reason")
local missingEventID, missingEventIDReason = Schema.NewEvent({})
T.equal(missingEventID, nil, "event identity is required")
T.equal(missingEventIDReason, "event_id_required",
    "missing event identity has a stable reason")
local futureEvent, futureEventReason = Schema.NewEvent({
    schemaVersion = 99,
    eventID = "event_future",
})
T.equal(futureEvent, nil, "future event schemas are not silently accepted")
T.equal(futureEventReason, "event_schema_version_unsupported",
    "future event schema has a stable reason")

local eventStore = Schema.NewEventStore({
    schemaVersion = 0,
    revision = 4,
    events = {
        event_one = { type = "generic" },
        event_two = { type = "generic", scope = { kind = "global" } },
    },
})
T.truthy(eventStore, "event store has a default envelope")
T.equal(eventStore.schemaVersion, 1, "event store schema is explicit")
T.equal(eventStore.revision, 4, "event store revision persists")
T.equal(eventStore.events.event_one.eventID, "event_one",
    "event store supplies the map identity")
T.equal(eventStore.events.event_two.scope.kind, "global",
    "event store keeps generic scope data")
local emptyEventStore = Schema.NewEventStore()
T.equal(emptyEventStore.schemaVersion, 1,
    "absent event store gets a schema default")
T.equal(countEntries(emptyEventStore.events), 0,
    "absent event store has no active events")

T.finish("dt_market_schema")
