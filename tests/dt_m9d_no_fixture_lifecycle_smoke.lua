local T = require "tests/support/test"
local loadSource = T.load

local TYPE_BY_ID = {
    [1] = "Base.CannedBeans",
    [2] = "Base.Unrelated",
}
local ID_BY_TYPE = {
    ["Base.CannedBeans"] = 1,
    ["Base.Unrelated"] = 2,
}

local function cloneRecord(record, quantity)
    return {
        [1] = record[1],
        [2] = quantity == nil and record[2] or quantity,
    }
end

local function newStore(rows)
    local store = { rows = {} }
    local index
    for index = 1, #(rows or {}) do
        store.rows[#store.rows + 1] = cloneRecord(rows[index])
    end

    function store:iterate()
        local cursor = 0
        return function()
            cursor = cursor + 1
            local record = self.rows[cursor]
            return record and cloneRecord(record) or nil
        end
    end

    function store:count(fullType)
        local typeID = ID_BY_TYPE[fullType]
        local total = 0
        for index = 1, #self.rows do
            if self.rows[index][1] == typeID then
                total = total + self.rows[index][2]
            end
        end
        return total
    end

    function store:remove(fullType, quantity)
        local typeID = ID_BY_TYPE[fullType]
        local remaining = math.floor(tonumber(quantity) or 0)
        local removed = {}
        local record
        local take
        if self:count(fullType) < remaining then
            return false, "insufficient_quantity"
        end
        for index = #self.rows, 1, -1 do
            record = self.rows[index]
            if record[1] == typeID and remaining > 0 then
                take = math.min(remaining, record[2])
                removed[#removed + 1] = cloneRecord(record, take)
                record[2] = record[2] - take
                remaining = remaining - take
                if record[2] <= 0 then table.remove(self.rows, index) end
            end
        end
        return true, removed
    end

    function store:add(record)
        for index = 1, #self.rows do
            if self.rows[index][1] == record[1] then
                self.rows[index][2] = self.rows[index][2] + record[2]
                return true
            end
        end
        self.rows[#self.rows + 1] = cloneRecord(record)
        return true
    end

    return store
end

local function copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = copy(item) end
    return output
end

local authority = true
local currentTime = 10
local modData = {}
local travelStarts = 0
local sourceFaction
local targetFaction
local community
local npcRecord
local radioProvider

local Inventory = {
    getItemFullType = function(typeID) return TYPE_BY_ID[typeID] end,
}
Inventory.Serializer = {
    serialize = function(store)
        local rows = {}
        local iterator = store:iterate()
        local item = iterator()
        while item do
            rows[#rows + 1] = cloneRecord(item)
            item = iterator()
        end
        return { rows = rows }
    end,
    deserialize = function(payload)
        return newStore(payload and payload.rows or {})
    end,
}
Inventory.createVirtualInventory = function() return newStore() end

DTCommon = {
    MODDATA_KEY = "DTCommon.Traders",
    MARKET_MODDATA_KEY = "DTCommon.SettlementMarkets",
    EVENT_MODDATA_KEY = "DTCommon.MarketEvents",
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    MONEY_FULL_TYPE = "Base.Money",
    DEFAULT_STOCK = {},
    DEFAULT_TRADER_NAME = "Caravan Trader",
    DEFAULT_TRADER_ROLE = "trader",
    DEFAULT_CARAVAN_ID = "debug_caravan",
    STATUS_READY = "READY",
    T = function(_, fallback) return fallback end,
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

MarketSense = {
    GetAllKnownItems = function()
        return {
            ["Base.CannedBeans"] = {
                fullType = "Base.CannedBeans",
                category = "Food",
                availability = { status = "obtainable" },
            },
        }
    end,
    GetTags = function(fullType)
        if fullType == "Base.CannedBeans" then
            return { category = "Food", tags = { "food" } }
        end
        return nil
    end,
    GetItemAvailability = function(fullType)
        if fullType == "Base.CannedBeans" then
            return { status = "obtainable" }
        end
        return { status = "unknown" }
    end,
    GetPriceDetails = function(fullType)
        if fullType == "Base.CannedBeans" then return { price = 100 } end
        if fullType == "Base.Unrelated" then return { price = 25 } end
        return nil
    end,
}

community = {
    id = "community_m9d_farm",
    factionID = "faction_m9d_target",
    name = "M9D Farm",
    mode = "settled",
    status = "active",
    siteID = "site_m9d_farm",
    capacity = { population = 12 },
    memberIDs = {},
}
targetFaction = {
    id = "faction_m9d_target",
    status = "active",
    archetypeID = "settler",
    tags = { settlementType = "farm" },
    playerMemberKeys = { player_one = true },
    memberIDs = {},
}
sourceFaction = {
    id = "faction_m9d_caravan",
    status = "active",
    archetypeID = "trader",
    tags = { dynamicTrading = true, mobileGroup = true },
    mobile = { active = true },
    memberIDs = { npc_m9d_merchant = true },
}
npcRecord = {
    id = "npc_m9d_merchant",
    alive = true,
    getX = function() return 0 end,
    getY = function() return 0 end,
    isDead = function() return false end,
    hostility = { attackPlayers = false },
    affiliation = {
        factionID = sourceFaction.id,
        role = "trader",
        rank = "member",
        membershipStatus = "member",
    },
}

PNC = {
    Core = { DeepCopy = copy, IsAuthority = function() return authority end },
    FactionConstants = {
        MOBILE_TRAVEL_SETTLEMENT = "settlement",
        MOBILE_TRAVEL_PURPOSE_ADMISSION = "settlement_admission",
        MOBILE_TRAVEL_PURPOSE_HOSTILE_CONTACT = "hostile_contact",
    },
    DirectorConfig = {
        MOBILE_SETTLEMENT_VISIT_HOURS = 12,
        MOBILE_SETTLEMENT_AI_JOIN_CHANCE = 0,
    },
    Registry = {
        Get = function(id)
            return tostring(id) == npcRecord.id and npcRecord or nil
        end,
        GetLiveZombie = function(id)
            return tostring(id) == npcRecord.id and npcRecord or nil
        end,
    },
    Communities = {
        Get = function(id)
            return tostring(id) == community.id and copy(community) or nil
        end,
        GetForFaction = function(id)
            if tostring(id) == targetFaction.id then
                return { copy(community) }
            end
            return {}
        end,
    },
    Factions = {
        Get = function(id)
            if tostring(id) == sourceFaction.id then return sourceFaction end
            if tostring(id) == targetFaction.id then return targetFaction end
            return nil
        end,
        GetRelation = function() return nil end,
        GetFactionID = function(record)
            return record and record.affiliation
                and record.affiliation.factionID or nil
        end,
        GetNPCAffiliation = function(id)
            return tostring(id) == npcRecord.id
                and npcRecord.affiliation or nil
        end,
        UpdateMobileGroup = function(id, patch)
            local faction = id == sourceFaction.id and sourceFaction or nil
            if not faction then return false, "faction_not_found" end
            for key, value in pairs(patch or {}) do
                faction.mobile[key] = copy(value)
            end
            return true, "updated", copy(faction.mobile)
        end,
    },
    AbstractWorldStore = { Registry = { encounters = {} } },
    Travel = { Arrivals = { StrictActionTypes = {} } },
    API = {
        Travel = {
            RegisterArrivalHandler = function() return true end,
            Start = function()
                travelStarts = travelStarts + 1
                return nil, "not_used_by_normal_arrival"
            end,
        },
    },
}

function isServer() return true end
function isClient() return false end
function getGameTime()
    return { getWorldAgeHours = function() return currentTime end }
end
function getSpecificPlayer()
    return {
        getX = function() return 0 end,
        getY = function() return 0 end,
    }
end

local savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    error("unexpected dependency while loading DTCommon: " .. tostring(moduleName))
end
DTCommon.MarketSchema = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua")
DTCommon.MarketProfiles = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketProfiles.lua")
DTCommon.Storage = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
require = savedRequire

DTCommon.TraderSupport = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderSupport.lua")
DTCommon.CoreActorPolicy = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.MarketCatalog = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketCatalog.lua")
DTCommon.MarketCatalog.Reset()
DTCommon.SettlementMarket = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
DTCommon.MarketEvents = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEvents.lua")
DTCommon.MarketEventDefinitions = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEventDefinitions.lua")
DTCommon.MarketEventProducer = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEventProducer.lua")
DTCommon.MarketEventPresentation = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEventPresentation.lua")
DTCommon.MarketPricing = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketPricing.lua")

savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    error("unexpected dependency while loading stock: " .. tostring(moduleName))
end
DTCommon.TraderStock = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderStock.lua")
require = savedRequire
DTCommon.TraderStock.EncodeItem = function(fullType, quantity)
    local typeID = ID_BY_TYPE[fullType]
    if not typeID then return nil, "item_type_unavailable" end
    return { [1] = typeID, [2] = quantity }
end
DTCommon.TraderStock.SaveAndTransmit = function() return true end

savedRequire = require
require = function(moduleName)
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return DTCommon.CoreActorPolicy
    end
    error("unexpected dependency while loading registry: " .. tostring(moduleName))
end
DTCommon.TraderService = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderRegistry.lua")
require = savedRequire

savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventoryConstants" then
        return { TYPE_ID = 1, QUANTITY = 2 }
    end
    if moduleName == "PsychopatzCore/Economy/PsychopatzCurrency" then
        return {}
    end
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return DTCommon.CoreActorPolicy
    end
    error("unexpected dependency while loading service: " .. tostring(moduleName))
end
DTCommon.TraderService = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderService.lua")
require = savedRequire

savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventoryConstants" then
        return { TYPE_ID = 1, QUANTITY = 2 }
    end
    if moduleName == "DTCommon/DTCommon_SettlementExchangePlan" then
        return loadSource(
            "DTCommon", "shared", "DTCommon/DTCommon_SettlementExchangePlan.lua")
    end
    if moduleName == "DTCommon/DTCommon_SettlementExchangeCandidates" then
        return loadSource(
            "DTCommon", "shared", "DTCommon/DTCommon_SettlementExchangeCandidates.lua")
    end
    error("unexpected dependency while loading exchange: " .. tostring(moduleName))
end
DTCommon.SettlementExchange = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementExchange.lua")
require = savedRequire

local traderID, record = DTCommon.TraderService.Create({
    traderID = "dt_" .. sourceFaction.id,
    caravanID = "caravan_m9d",
    budget = 200,
    abstractAccessEnabled = false,
})
T.truthy(traderID, "bound trader fixture exists")
T.truthy(DTCommon.TraderService.BindFaction(
    traderID,
    sourceFaction.id,
    npcRecord.id,
    { npcRecord.id }
), "bound trader fixture uses the Hoomans faction")
DTCommon.CoreActorPolicy.Bind(record, "actor_m9d", {
    provider = "DTHoomans",
    providerState = "materialized",
    providerBodyID = npcRecord.id,
    providerLeaseID = "lease_m9d",
    providerRevision = 1,
})
local stock = DTCommon.Storage.LoadInventory(record)
T.truthy(stock:add({ [1] = 2, [2] = 3 }),
    "unrelated carried stock is seeded")
T.truthy(DTCommon.Storage.SaveInventory(record, stock),
    "carried stock persists before arrival")
DTCommon.Storage.Touch()
DTCommon.Storage.Transmit()
local startingVersion = record.v

local hoomansServerPath = T.path("ProjectHoomans", "server", "?.lua")
local hoomansSharedPath = T.path("ProjectHoomans", "shared", "?.lua")
package.path = hoomansServerPath .. ";" .. hoomansSharedPath
    .. ";" .. package.path
local MobileSettlement = loadSource(
    "ProjectHoomans", "server",
    "PNC/Director/PNC_MobileSettlementVisitService.lua")
T.truthy(type(MobileSettlement.RegisterArrivalListener) == "function",
    "real Hoomans service exposes the arrival observer")

DTHoomans = {}
local Settlement = loadSource(
    "DTHoomans", "server", "DTHoomans/DTHoomans_SettlementVisit.lua")
T.truthy(Settlement.HoomansArrivalListenerRegistered,
    "DT observes the real Hoomans arrival service")
T.falsy(DTCommon.SettlementMarket.Get(community.id),
    "flagship starts without a DT market")
T.equal(#DTCommon.MarketEvents.List({ activeOnly = true, now = currentTime }), 0,
    "flagship starts without a pre-registered proof event")

local target = {
    kind = "player_colony",
    factionID = targetFaction.id,
    communityID = community.id,
    locationID = "location_m9d_farm",
}
local group = { memberIds = { npcRecord.id } }
local travel = {
    kind = "settlement",
    purpose = "settlement_admission",
    revision = 17,
}
local arrived, arrivalReason = MobileSettlement.OnSettlementArrival(
    sourceFaction, target, travel, 10, group, {})
T.truthy(arrived, arrivalReason)
T.equal(travelStarts, 0,
    "normal Hoomans arrival does not start DT-owned travel")

local market = DTCommon.SettlementMarket.Get(community.id)
T.truthy(market, "normal Hoomans arrival provisions the market")
T.equal(market.settlementID, community.id,
    "market identity is the active Hoomans community id")
T.equal(market.profileID, "farm",
    "initial profile resolves from bounded Hoomans faction metadata")
T.equal(#DTCommon.SettlementMarket.List(16), 1,
    "automatic provisioning creates exactly one market")
T.equal(record.ca.lastSettlementID, community.id,
    "arrival forwards the canonical settlement context")
T.equal(record.ca.visitCount, 1,
    "normal arrival records one DT visit")
T.equal(record.v, startingVersion + 1,
    "normal arrival performs one bounded exchange")
local afterArrival = DTCommon.Storage.LoadInventory(record)
T.equal(afterArrival:count("Base.Unrelated"), 3,
    "exchange preserves unrelated exact stock")
T.truthy(afterArrival:count("Base.CannedBeans") > 0,
    "exchange acquires a MarketSense-backed food item")

local producer = DTCommon.MarketEventProducer
local eventID = producer.EventID(community.id)
local firstEvent, firstEventReason = DTCommon.MarketEvents.Get(eventID)
T.truthy(firstEvent, firstEventReason)
T.equal(firstEvent.type, "agricultural_surplus",
    "arrival conditions trigger a data-driven production event")
T.equal(firstEvent.startsAt, 10,
    "production event starts from the authoritative arrival time")
T.equal(firstEvent.endsAt, 22,
    "production event has bounded duration")

local firstRecord = DTCommon.TraderService.GetRecord(traderID)
local firstContext = DTCommon.MarketPricing.BuildContext(firstRecord, nil, {
    settlementID = community.id,
    now = 10,
})
local firstQuote = DTCommon.MarketPricing.GetItemContext(
    "Base.CannedBeans", firstContext)
T.equal(firstQuote.eventCount, 1,
    "quote reacts immediately to the production event")
T.equal(firstQuote.eventPriceMultiplier, 0.85,
    "surplus event changes the commercial quote")
T.equal(firstQuote.availabilityMultiplier, 1.35,
    "surplus event changes bounded availability")
local firstPresentation = DTCommon.MarketEventPresentation.Summary(
    community.id, firstRecord, { now = 10 })
T.equal(firstPresentation.activeEventCount, 1,
    "presentation exposes the active arrival event")

-- Move pressure away from the farm baseline through the normal market
-- mutation API, then let a later Hoomans arrival drive lazy recovery.
local beforeRecovery = DTCommon.SettlementMarket.ApplyDelta(community.id, {
    categories = {
        Food = { supplyDelta = -0.4, demandDelta = 0.4 },
    },
}, { now = 12 })
T.truthy(beforeRecovery, "normal market action moves pressure away from baseline")
local recoverySupply = beforeRecovery.categories.Food.supply
local recoveryDemand = beforeRecovery.categories.Food.demand
currentTime = 24
local secondTravel = {
    kind = "settlement",
    purpose = "settlement_admission",
    revision = 18,
}
local secondArrival, secondArrivalReason = MobileSettlement.OnSettlementArrival(
    sourceFaction, target, secondTravel, currentTime, group, {})
T.truthy(secondArrival, secondArrivalReason)
local afterRecovery = DTCommon.SettlementMarket.Get(community.id)
T.truthy(afterRecovery.categories.Food.supply > recoverySupply,
    "later normal arrival recovers supply toward the farm baseline")
T.truthy(afterRecovery.categories.Food.demand < recoveryDemand,
    "later normal arrival recovers demand toward the farm baseline")
T.equal(afterRecovery.lastUpdateAt, currentTime,
    "lazy recovery records authoritative world time")
T.equal(record.ca.visitCount, 2,
    "a new Hoomans travel revision records one new visit")
T.equal(#DTCommon.MarketEventPresentation.Summary(
    community.id, record, { now = currentTime }).events, 0,
    "the first event expires through normal runtime time resolution")

-- Persist a new severe condition, then let the next normal Hoomans arrival
-- register the shortage after the prior event's cooldown has elapsed.
local shortageFixture = DTCommon.SettlementMarket.ApplyDelta(community.id, {
    categories = {
        Food = { supplyDelta = -0.7, demandDelta = 0.68 },
    },
}, { now = 36 })
T.truthy(shortageFixture, "normal market action creates shortage conditions")
currentTime = 37
local thirdTravel = {
    kind = "settlement",
    purpose = "settlement_admission",
    revision = 19,
}
local thirdArrival, thirdArrivalReason = MobileSettlement.OnSettlementArrival(
    sourceFaction, target, thirdTravel, currentTime, group, {})
T.truthy(thirdArrival, thirdArrivalReason)
local shortage, shortageReason = DTCommon.MarketEvents.Get(eventID)
T.truthy(shortage, shortageReason)
T.equal(shortage.type, "food_shortage",
    "normal Hoomans arrival registers the later shortage event")
T.equal(shortage.startsAt, 37,
    "shortage starts through production runtime rather than test registration")

local stockAfterEvent = DTCommon.Storage.LoadInventory(record)
local stockVersionAfterEvent = record.v
local replayed, replayReason = MobileSettlement.OnSettlementArrival(
    sourceFaction, target, thirdTravel, currentTime, group, {})
T.truthy(replayed, replayReason)
local stockAfterReplay = DTCommon.Storage.LoadInventory(record)
T.equal(stockAfterReplay:count("Base.CannedBeans"),
    stockAfterEvent:count("Base.CannedBeans"),
    "replayed arrival keeps exact stock unchanged")
T.equal(record.v, stockVersionAfterEvent,
    "replayed arrival does not apply a second exchange")
T.equal(record.ca.visitCount, 3,
    "replayed arrival does not increment the visit ledger")

local shortageContext = DTCommon.MarketPricing.BuildContext(record, nil, {
    settlementID = community.id,
    now = currentTime,
})
local shortageQuote = DTCommon.MarketPricing.GetItemContext(
    "Base.CannedBeans", shortageContext)
T.equal(shortageQuote.eventPriceMultiplier, 1.2,
    "later shortage immediately changes the quote presentation")
T.equal(shortageQuote.availabilityMultiplier, 0.65,
    "later shortage immediately changes availability presentation")
local shortagePresentation = DTCommon.MarketEventPresentation.Summary(
    community.id, record, { now = currentTime })
T.equal(shortagePresentation.activeEventCount, 1,
    "later shortage is visible in the common event presentation")
T.equal(shortagePresentation.events[1].eventType, "food_shortage",
    "common presentation exposes the later typed event")

-- Exercise the existing WorldKnowledge adapter with a deterministic Core
-- ledger double; the adapter remains the production presentation boundary.
local publishedFacts = {}
package.preload["PsychopatzCore/WorldKnowledge/PsychopatzWorldKnowledge"] =
    function()
        return {
            Publish = function(specification)
                publishedFacts[specification.factID] = specification
                return { factID = specification.factID }
            end,
            Acquire = function(actorID, factID)
                return { actorID = actorID, factID = factID }
            end,
            Context = function() return { references = {} } end,
            Reset = function() return true end,
        }
    end
local WorldKnowledge = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_WorldKnowledge.lua")
local synced, syncReason = WorldKnowledge.SyncMarketEvents(traderID, {
    settlementID = community.id,
    now = currentTime,
})
T.truthy(synced, syncReason)
T.equal(synced.activeEventCount, 1,
    "WorldKnowledge receives the active production event")
T.equal(#synced.facts, 1,
    "WorldKnowledge publishes one bounded market-event fact")

-- Exercise the physical Radio OS provider, which consumes the same bounded
-- MarketEventPresentation projection as the WorldKnowledge path.
package.preload["PsychopatzCore/UI/Radio/OS/PsychopatzRadioOS"] = function()
    return {
        UnregisterContactProvider = function() end,
        RegisterContactProvider = function(definition)
            radioProvider = definition
            return true
        end,
    }
end
local radioDefinition = loadSource(
    "DTHoomans", "client", "DTHoomans/DTHoomans_RadioOS.lua")
T.truthy(radioDefinition and radioProvider,
    "physical radio registers its production contact provider")
local radioRows = radioDefinition.list(nil, { limit = 4 })
T.equal(#radioRows.contacts, 1,
    "physical radio lists the bound Hoomans trader")
T.equal(radioRows.contacts[1].marketEvents[1].eventType,
    "food_shortage",
    "physical radio presents the active production event")

-- Reload the authoritative DT persistence readers over the same ModData
-- envelope and prove that market, event, and exact stock state survive.
local savedRequireForReload = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    error("unexpected dependency while reloading DTCommon: " .. tostring(moduleName))
end
local reloadedStorage = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
require = savedRequireForReload
DTCommon.Storage = reloadedStorage
DTCommon.MarketEvents = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEvents.lua")
DTCommon.SettlementMarket = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
DTCommon.MarketEventPresentation = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEventPresentation.lua")
local reloadedMarket = DTCommon.SettlementMarket.Get(community.id)
local reloadedEvent, reloadedEventReason = DTCommon.MarketEvents.Get(eventID)
T.truthy(reloadedMarket, "reloaded market remains persisted")
T.truthy(reloadedEvent, reloadedEventReason)
T.equal(reloadedMarket.profileID, "farm",
    "reloaded market preserves its bounded profile")
T.equal(reloadedEvent.type, "food_shortage",
    "reloaded event preserves its typed definition")
T.equal(reloadedEvent.startsAt, shortage.startsAt,
    "reloaded event preserves its timing")
local reloadedStock = reloadedStorage.LoadInventory(record)
T.equal(reloadedStock:count("Base.Unrelated"),
    stockAfterReplay:count("Base.Unrelated"),
    "reloaded stock preserves unrelated inventory")

return T.finish("dt_m9d_no_fixture_lifecycle_smoke")
