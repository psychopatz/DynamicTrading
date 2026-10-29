local T = require "tests/support/test"

local authority = true
local modData = {}
local marketKey = "DTCommon.SettlementMarkets"
local eventKey = "DTCommon.MarketEvents"
local traderKey = "DTCommon.Traders"

DTCommon = {
    MARKET_MODDATA_KEY = marketKey,
    EVENT_MODDATA_KEY = eventKey,
    MODDATA_KEY = traderKey,
    STATUS_READY = "READY",
}
PsychopatzCore = {
    RuntimeRole = { AllowsServerCode = function() return authority end },
}
ModData = {
    getOrCreate = function(key)
        modData[key] = modData[key] or {}
        return modData[key]
    end,
    transmit = function() return true end,
}
PNC = {
    Communities = {
        Get = function(id)
            if tostring(id) == "community_m9c" then
                return { id = id, status = "active", regionID = "region_m9c" }
            end
            return nil
        end,
    },
}
modData[traderKey] = {
    t = {
        ["trader:m9c"] = {
            s = "AWAY",
            v = 1,
            b = 100,
            ca = {},
            stockSentinel = "persistent",
        },
    },
}

local savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return {}
    end
    error("unexpected storage dependency: " .. tostring(moduleName))
end
DTCommon.MarketSchema = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua")
DTCommon.MarketProfiles = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketProfiles.lua")
DTCommon.Storage = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
require = savedRequire

DTCommon.MarketEvents = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEvents.lua")
DTCommon.MarketEventDefinitions = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEventDefinitions.lua")
DTCommon.SettlementMarket = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
DTCommon.MarketEventProducer = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEventProducer.lua")
DTCommon.MarketEventPresentation = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEventPresentation.lua")

DTCommon.TraderSupport = {
    Bounded = function(value, maximum)
        value = tostring(value or "")
        return #value > maximum and string.sub(value, 1, maximum) or value
    end,
}
DTCommon.CoreActorPolicy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.TraderStock = {
    SaveAndTransmit = function() return true end,
}

savedRequire = require
require = function(moduleName)
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return DTCommon.CoreActorPolicy
    end
    error("unexpected trader-registry dependency: " .. tostring(moduleName))
end
DTCommon.TraderService = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderRegistry.lua")
require = savedRequire

savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return {}
    end
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventoryConstants" then
        return {}
    end
    if moduleName == "PsychopatzCore/Economy/PsychopatzCurrency" then
        return {}
    end
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return DTCommon.CoreActorPolicy
    end
    error("unexpected trader-service dependency: " .. tostring(moduleName))
end
DTCommon.TraderService = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderService.lua")
require = savedRequire

DTCommon.MarketCatalog = {
    Get = function(fullType)
        if fullType == "Base.CannedBeans" then
            return { fullType = fullType, category = "Food" }
        end
        return nil
    end,
}
local Pricing = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketPricing.lua")

local market = DTCommon.SettlementMarket
local events = DTCommon.MarketEvents
local producer = DTCommon.MarketEventProducer
local service = DTCommon.TraderService
local settlementID = "community_m9c"
local traderID = "trader:m9c"

T.truthy(market.GetOrCreate(settlementID, "default"),
    "producer market fixture exists")
local shifted = market.ApplyDelta(settlementID, {
    categories = {
        Food = { supplyDelta = -0.3, demandDelta = 0.3 },
    },
}, { now = 10 })
T.truthy(shifted, "normal market mutation creates shortage conditions")
T.equal(shifted.categories.Food.supply, 0.2,
    "shortage producer reads persisted low supply")
T.equal(shifted.categories.Food.demand, 0.8,
    "shortage producer reads persisted high demand")

local firstVisit, firstReason = service.MarkSettlementVisit(traderID, {
    authority = "server",
    atSettlement = true,
    settlementID = settlementID,
    visitID = "visit:m9c:one",
    now = 10,
})
T.truthy(firstVisit, firstReason)
local eventID = producer.EventID(settlementID)
local shortage, shortageReason = events.Get(eventID)
T.truthy(shortage, shortageReason)
T.equal(shortage.type, "food_shortage",
    "ordinary visit runtime registers the generic shortage definition")
T.equal(shortage.startsAt, 10, "producer event starts at the visit time")
T.equal(shortage.endsAt, 22, "producer event has a bounded duration")

local record = service.GetRecord(traderID)
T.equal(record.stockSentinel, "persistent",
    "event start does not mutate exact trader stock")
local context = Pricing.BuildContext(record, nil, {
    settlementID = settlementID,
    now = 10,
})
local quote = Pricing.GetItemContext("Base.CannedBeans", context)
T.equal(quote.eventCount, 1, "quote sees the production event modifier")
T.equal(quote.eventPriceMultiplier, 1.2,
    "quote price presentation reacts to the shortage event")
T.equal(quote.availabilityMultiplier, 0.65,
    "quote availability reacts to the shortage event")

local presentation = DTCommon.MarketEventPresentation.Summary(
    settlementID, record, { now = 10 })
T.equal(presentation.activeEventCount, 1,
    "shared event presentation exposes the production event")
T.equal(presentation.events[1].eventType, "food_shortage",
    "presentation carries the data-driven event type")

local revisionBeforeReplay = DTCommon.Storage.GetEventData().revision
local replay, replayReason = service.MarkSettlementVisit(traderID, {
    authority = "server",
    atSettlement = true,
    settlementID = settlementID,
    visitID = "visit:m9c:two",
    now = 11,
})
T.truthy(replay, replayReason)
T.equal(DTCommon.Storage.GetEventData().revision, revisionBeforeReplay,
    "sustained conditions do not recreate the event on every visit")

local neutral = market.ApplyDelta(settlementID, {
    categories = {
        Food = { supplyDelta = 0.35, demandDelta = -0.35 },
    },
}, { now = 12 })
T.truthy(neutral, "normal market mutation clears shortage conditions")
local cleared, clearedReason = service.MarkSettlementVisit(traderID, {
    authority = "server",
    atSettlement = true,
    settlementID = settlementID,
    visitID = "visit:m9c:three",
    now = 12,
})
T.truthy(cleared, clearedReason)
local expired, expiredReason = events.Get(eventID)
T.truthy(expired, expiredReason)
T.equal(expired.endsAt, 12,
    "producer clears the active event through the normal visit runtime")
T.equal(#events.List({ activeOnly = true, now = 12 }), 0,
    "cleared event is absent from active presentation")

local reentered = market.ApplyDelta(settlementID, {
    categories = {
        Food = { supplyDelta = -0.35, demandDelta = 0.35 },
    },
}, { now = 13 })
T.truthy(reentered, "normal market mutation re-enters shortage conditions")
local cooldown, cooldownReason = service.MarkSettlementVisit(traderID, {
    authority = "server",
    atSettlement = true,
    settlementID = settlementID,
    visitID = "visit:m9c:four",
    now = 13,
})
T.truthy(cooldown, cooldownReason)
T.equal(#events.List({ activeOnly = true, now = 13 }), 0,
    "cooldown prevents immediate event recreation")

local advanced = market.ApplyDelta(settlementID, {
    categories = {},
}, { now = 25 })
T.truthy(advanced, "normal market access advances the persisted timestamp")
local restarted, restartedReason = service.MarkSettlementVisit(traderID, {
    authority = "server",
    atSettlement = true,
    settlementID = settlementID,
    visitID = "visit:m9c:five",
    now = 25,
})
T.truthy(restarted, restartedReason)
local newShortage, newShortageReason = events.Get(eventID)
T.truthy(newShortage, newShortageReason)
T.equal(newShortage.startsAt, 25,
    "producer can re-enter after the persisted cooldown")

return T.finish("dt_m9c_event_producer_runtime_smoke")
