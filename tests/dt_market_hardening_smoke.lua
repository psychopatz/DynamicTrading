local T = require "tests/support/test"

local savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory"
        or moduleName == "PsychopatzCore/Inventory/PsychopatzInventoryConstants"
    then
        return {}
    end
    return savedRequire(moduleName)
end

local authority = true
local marketKey = "DTCommon.SettlementMarkets"
local eventKey = "DTCommon.MarketEvents"
local modData = {
    [marketKey] = {
        schemaVersion = 0,
        revision = -3,
        markets = {
            community_hardening = {
                profileID = "farm",
                categories = {
                    Food = { supply = 0.85, demand = 0.25 },
                },
                ignoredField = true,
            },
        },
        ignoredField = true,
    },
    [eventKey] = {
        schemaVersion = 0,
        revision = -2,
        events = {},
        ignoredField = true,
    },
}

DTCommon = {
    MARKET_MODDATA_KEY = marketKey,
    EVENT_MODDATA_KEY = eventKey,
    MONEY_FULL_TYPE = "Base.Money",
    OP_BUY = "BUY",
    OP_SELL = "SELL",
}
PsychopatzCore = {
    RuntimeRole = {
        AllowsServerCode = function() return authority end,
    },
}
ModData = {
    getOrCreate = function(key)
        modData[key] = modData[key] or {}
        return modData[key]
    end,
    transmit = function() end,
}
PNC = {
    Communities = {
        Get = function(id)
            if not id or id == "" then return nil end
            return { id = id, status = "active", regionID = "hardening" }
        end,
    },
}

local Schema = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua")
DTCommon.MarketSchema = Schema
local Storage = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
DTCommon.Storage = Storage
DTCommon.MarketProfiles = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketProfiles.lua")
local Market = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
DTCommon.SettlementMarket = Market
local Events = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEvents.lua")
DTCommon.MarketEvents = Events
local Catalog = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketCatalog.lua")
DTCommon.MarketCatalog = Catalog

local function countEntries(value)
    local count = 0
    for _, _ in pairs(value or {}) do count = count + 1 end
    return count
end

local marketData, marketReason = Storage.GetMarketData()
T.truthy(marketData, marketReason)
T.equal(marketData.schemaVersion, 1,
    "market storage migrates the legacy envelope before use")
T.equal(marketData.revision, 0,
    "market storage clamps a legacy negative revision")
T.equal(marketData.ignoredField, nil,
    "market storage drops unknown envelope fields")
T.equal(marketData.markets.community_hardening.ignoredField, nil,
    "market storage drops unknown record fields")
local eventData, eventReason = Storage.GetEventData()
T.truthy(eventData, eventReason)
T.equal(eventData.schemaVersion, 1,
    "event storage migrates the legacy envelope before use")
T.equal(eventData.revision, 0,
    "event storage clamps a legacy negative revision")
T.equal(eventData.ignoredField, nil,
    "event storage drops unknown envelope fields")

local market, marketGetReason = Market.GetOrCreate(
    "community_hardening", "farm")
T.truthy(market, marketGetReason)
local pressured, pressureReason = Market.ApplyDelta("community_hardening", {
    categories = {
        Food = { supplyDelta = -0.5, demandDelta = 0.5 },
    },
}, { expectedRevision = market.revision, now = 10 })
T.truthy(pressured, pressureReason)
local recovered, recoveryReason = Market.Recover("community_hardening", 1000000000, {
    now = Schema.MAX_TIMESTAMP,
})
T.truthy(recovered, recoveryReason)
T.equal(recovered.lastUpdateAt, Schema.MAX_TIMESTAMP,
    "recovery clamps a large timestamp to the schema bound")
T.equal(recovered.categories.Food.supply, 0.85,
    "large recovery reaches the profile supply baseline exactly")
T.equal(recovered.categories.Food.demand, 0.25,
    "large recovery reaches the profile demand baseline exactly")
local reversed, reversedChanged = Market.Recover("community_hardening", -100, {
    now = 0,
})
T.truthy(reversed, "negative recovery remains readable")
T.equal(reversedChanged, false,
    "negative or backwards recovery cannot move market time backwards")
T.equal(reversed.lastUpdateAt, Schema.MAX_TIMESTAMP,
    "backwards recovery preserves the latest market timestamp")

local window, windowReason = Events.Register("hardening:window", {
    type = "hardening_window",
    startsAt = 10,
    endsAt = 12,
    scope = { kind = "settlement", id = "community_hardening" },
    modifiers = {
        { marketTag = "Food", demandDelta = 0.2 },
    },
})
T.truthy(window, windowReason)
local zeroWindow, zeroWindowReason = Events.Register("hardening:zero", {
    type = "hardening_zero_window",
    startsAt = 12,
    endsAt = 12,
    scope = { kind = "settlement", id = "community_hardening" },
})
T.truthy(zeroWindow, zeroWindowReason)
local beforeWindow = Events.ResolveContext("community_hardening", nil, {
    now = 9,
})
local atWindow = Events.ResolveContext("community_hardening", nil, {
    now = 10,
})
local atExpiry = Events.ResolveContext("community_hardening", nil, {
    now = 12,
})
T.equal(beforeWindow.activeEventCount, 0,
    "event before-start resolution is empty")
T.equal(atWindow.activeEventCount, 1,
    "event start is inclusive")
T.equal(atExpiry.activeEventCount, 0,
    "event expiry is exclusive and zero-length windows stay inactive")
T.truthy(beforeWindow.revision ~= atWindow.revision,
    "event activation changes the effective revision")
T.truthy(atWindow.revision ~= atExpiry.revision,
    "event expiry changes the effective revision")

local reloadedStorage = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
DTCommon.Storage = reloadedStorage
local reloadedEvents = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEvents.lua")
DTCommon.MarketEvents = reloadedEvents
local persistedWindow, persistedWindowReason = reloadedEvents.Get(
    "hardening:window")
T.truthy(persistedWindow, persistedWindowReason)
T.equal(persistedWindow.startsAt, 10,
    "event start time survives a fresh registry load")
T.equal(persistedWindow.endsAt, 12,
    "event expiry time survives a fresh registry load")

local oversizedEvents = { schemaVersion = 0, events = {} }
for index = 1, Schema.MAX_EVENTS + 16 do
    oversizedEvents.events["hardening:bounded:" .. tostring(index)] = {
        type = "bounded",
        scope = { kind = "global" },
    }
end
local boundedEvents, boundedEventsReason = Schema.NewEventStore(oversizedEvents)
T.truthy(boundedEvents, boundedEventsReason)
T.equal(countEntries(boundedEvents.events), Schema.MAX_EVENTS,
    "event migration bounds the persisted event envelope")

local known = {
    ["Base.CannedBeans"] = {
        fullType = "Base.CannedBeans",
        category = "Food",
        tags = { "FoodPreserved" },
        availability = { status = "obtainable" },
    },
}
local knownCalls = 0
MarketSense = {
    EnsureRuntimeRegistryLoaded = function() return true end,
    GetAllKnownItems = function()
        knownCalls = knownCalls + 1
        return known
    end,
    GetTags = function()
        return { category = "Food", tags = { "Food" } }
    end,
    GetItemAvailability = function()
        return { status = "obtainable" }
    end,
    GetPriceDetails = function() return { price = 100 } end,
    GetPriceDetailsForInstance = function() return { price = 100 } end,
}

Catalog.Reset()
local built, builtReason = Catalog.Ensure()
T.truthy(built, builtReason)
T.equal(knownCalls, 1, "catalog warmup performs one registry scan")
for index = 1, Catalog.MAX_DYNAMIC_FACTS + 32 do
    T.truthy(Catalog.Get("Workshop.Dynamic" .. tostring(index)),
        "uncatalogued MarketSense fact remains available to a quote")
end
local dynamicDiagnostics = Catalog.Diagnostics()
T.equal(dynamicDiagnostics.dynamicCount, Catalog.MAX_DYNAMIC_FACTS,
    "ad hoc taxonomy cache is bounded")
for _ = 1, 6 do
    Catalog.GetCandidates("Food", { limit = 4 })
end
T.equal(knownCalls, 1,
    "warm catalog candidate queries do not rescan MarketSense")
Catalog.Invalidate()
local rebuilt, rebuiltReason = Catalog.GetCandidates("Food", { limit = 4 })
T.truthy(rebuilt, rebuiltReason)
T.equal(knownCalls, 2,
    "explicit catalog invalidation permits exactly one new scan")
Catalog.GetCandidates("Food", { limit = 4 })
T.equal(knownCalls, 2,
    "repeated post-invalidation candidate queries stay cached")

DTCommon.CoreActorPolicy = {
    Get = function(record) return record and record.ca end,
    PriceContext = function() return { relationshipModifier = 0 } end,
}
local Pricing = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketPricing.lua")
DTCommon.MarketPricing = Pricing
local Stock = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderStock.lua")
DTCommon.TraderStock = Stock
local pricingContext = Pricing.BuildContext({
    ca = { lastSettlementID = "community_hardening" },
}, nil, { now = 5 })
for _ = 1, 20 do
    local quote = Stock.Quote(
        "Base.CannedBeans", DTCommon.OP_BUY, nil, pricingContext)
    T.equal(quote.intrinsicPrice, 100,
        "warm catalog quote preserves MarketSense intrinsic value")
    T.equal(quote.unitPrice, 85,
        "warm catalog quote applies the bounded settlement context")
end
T.equal(knownCalls, 2,
    "repeated quotes never perform a full MarketSense registry scan")

local coreRepository = T.repository .. "/../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path
local Json = require "PsychopatzCore/Serialization/PsychopatzJson"
local representativeMarkets = { schemaVersion = 1, revision = 64, markets = {} }
for settlementIndex = 1, 64 do
    local categories = {}
    for categoryIndex = 1, 8 do
        categories["category_" .. tostring(categoryIndex)] = {
            supply = 0.25,
            demand = 0.75,
        }
    end
    representativeMarkets.markets["community_" .. tostring(settlementIndex)] = {
        schemaVersion = 1,
        settlementID = "community_" .. tostring(settlementIndex),
        profileID = "default",
        revision = settlementIndex,
        lastUpdateAt = 10,
        wealth = 0.5,
        categories = categories,
    }
end
local representativeEvents = { schemaVersion = 1, revision = 32, events = {} }
for eventIndex = 1, 32 do
    local modifiers = {}
    for modifierIndex = 1, 4 do
        modifiers[modifierIndex] = {
            marketTag = "category_" .. tostring(modifierIndex),
            supplyDelta = -0.1,
            demandDelta = 0.1,
            availabilityMultiplier = 0.9,
            priceMultiplier = 1.1,
        }
    end
    representativeEvents.events["event_" .. tostring(eventIndex)] = {
        schemaVersion = 1,
        eventID = "event_" .. tostring(eventIndex),
        type = "bounded",
        startsAt = 10,
        endsAt = 20,
        scope = { kind = "global" },
        modifiers = modifiers,
    }
end
local marketBytes = #Json.Encode(representativeMarkets, {
    maxCollection = 4096,
})
local eventBytes = #Json.Encode(representativeEvents, {
    maxCollection = 4096,
})
T.truthy(marketBytes > 0, "representative market envelope has a byte estimate")
T.truthy(eventBytes > 0, "representative event envelope has a byte estimate")
T.falsy(string.find(Json.Encode(representativeMarkets), "Base.CannedBeans", 1, true),
    "market persistence estimate contains no item definitions")
print("dt_market_hardening: settlements=64 market_bytes="
    .. tostring(marketBytes) .. " events=32 event_bytes="
    .. tostring(eventBytes))

local audit = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TradeAudit.lua")
local metrics = {
    audit.METRIC_MARKET_CONTEXT,
    audit.METRIC_EVENT_RESOLUTION,
    audit.METRIC_EVENT_PRESENTATION,
    audit.METRIC_CATALOG_QUERY,
    audit.METRIC_MARKET_RECOVERY,
    audit.METRIC_SETTLEMENT_VISIT,
    audit.METRIC_SETTLEMENT_EXCHANGE,
}
local registeredDefinition
local savedProfilerRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Profiler/PsychopatzProfilerFeatureRegistry"
    then
        return {
            Register = function(definition)
                registeredDefinition = definition
                return true
            end,
        }
    end
    return savedProfilerRequire(moduleName)
end

DTCommon = {
    TradeAudit = audit,
    TraderStock = {
        Price = function() end,
        Quote = function() end,
        SnapshotItems = function() end,
        SnapshotSellRows = function() end,
    },
    TraderService = {
        Snapshot = function() end,
        ExecuteTradeBasket = function() end,
        MarkSettlementVisit = function() end,
    },
    MarketPricing = { BuildContext = function() end },
    MarketEvents = {
        ResolveContext = function() end,
        ListActive = function() end,
    },
    MarketCatalog = { GetCandidates = function() end },
    SettlementMarket = { Recover = function() end },
    SettlementExchange = { Execute = function() end },
}
T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TradeAuditProfiler.lua")
require = savedProfilerRequire
T.truthy(registeredDefinition, "trade profiler feature registers")
local wrapped = {}
local wrapperCalls = {}
local profiler = {
    Wrap = function(name, callback)
        local wrapper = function(...)
            wrapperCalls[name] = (wrapperCalls[name] or 0) + 1
            return callback(...)
        end
        wrapped[name] = wrapper
        return wrapper
    end,
}
local cleanup = registeredDefinition.install(profiler)
T.truthy(audit.PerformanceEnabled,
    "trade profiler enables performance capture only when installed")
for index = 1, #metrics do
    T.truthy(wrapped[metrics[index]],
        "profiler exposes bounded market metric " .. tostring(metrics[index]))
end
DTCommon.MarketPricing.BuildContext()
DTCommon.MarketEvents.ResolveContext()
DTCommon.MarketEvents.ListActive()
DTCommon.MarketCatalog.GetCandidates()
DTCommon.SettlementMarket.Recover()
DTCommon.TraderService.MarkSettlementVisit()
DTCommon.SettlementExchange.Execute()
for index = 1, #metrics do
    T.equal(wrapperCalls[metrics[index]], 1,
        "installed profiler wrapper records " .. tostring(metrics[index]))
end
T.truthy(cleanup, "trade profiler returns a cleanup boundary")
cleanup()
T.falsy(audit.PerformanceEnabled,
    "trade profiler cleanup disables performance capture")
T.equal(audit.Profiler, nil,
    "trade profiler cleanup releases the profiler reference")

T.finish("dt_market_hardening")
