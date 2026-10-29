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
local modData = {}
local community = {
    id = "community_m9e_farm",
    factionID = "faction_m9e_settlement",
    name = "M9E Farm",
    mode = "settled",
    status = "active",
    siteID = "site_m9e_farm",
    capacity = { population = 12 },
    memberIDs = { npc_m9e_trader = true },
}
local faction = {
    id = community.factionID,
    status = "active",
    archetypeID = "settler",
    tags = { settlementType = "farm" },
    memberIDs = { npc_m9e_trader = true, npc_m9e_worker = true },
}
local members = {
    { npcID = "npc_m9e_trader", affiliation = { role = "trader" } },
    { npcID = "npc_m9e_worker", affiliation = { role = "worker" } },
}

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
}
PsychopatzCore = {
    RuntimeRole = { AllowsServerCode = function() return authority end },
}
ModData = {
    getOrCreate = function(key)
        modData[key] = modData[key] or {}
        return modData[key]
    end,
    transmit = function() end,
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
    GetItemAvailability = function()
        return { status = "obtainable" }
    end,
    GetPriceDetails = function(fullType)
        if fullType == "Base.CannedBeans" then return { price = 100 } end
        return nil
    end,
}

PNC = {
    Core = { DeepCopy = copy, IsAuthority = function() return authority end },
    FactionConstants = {
        MOBILE_TRAVEL_SETTLEMENT = "settlement",
        MOBILE_TRAVEL_PURPOSE_ADMISSION = "settlement_admission",
        MOBILE_TRAVEL_PURPOSE_HOSTILE_CONTACT = "hostile_contact",
    },
    DirectorConfig = { MOBILE_SETTLEMENT_VISIT_HOURS = 12 },
    Communities = {
        Get = function(id)
            return tostring(id) == community.id and copy(community) or nil
        end,
        GetForFaction = function(id)
            return tostring(id) == faction.id and { copy(community) } or {}
        end,
    },
    Factions = {
        Get = function(id)
            return tostring(id) == faction.id and faction or nil
        end,
        GetMembers = function(id)
            return tostring(id) == faction.id and members or {}
        end,
        GetRelation = function() return nil end,
        IsMobileGroup = function() return false end,
    },
    SettlementTraderStaffing = {
        TraderMember = function(id)
            return tostring(id) == faction.id and "npc_m9e_trader" or nil
        end,
    },
    Travel = { Arrivals = { StrictActionTypes = {} } },
    API = {
        Travel = {
            RegisterArrivalHandler = function() return true end,
        },
    },
}

function isServer() return true end
function isClient() return false end
function getGameTime()
    return { getWorldAgeHours = function() return 10 end }
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
    return typeID and { [1] = typeID, [2] = quantity } or nil
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

-- Load the same Hoomans-owned community/arrival bridge used by production.
DTHoomans = {}
local Settlement = loadSource(
    "DTHoomans", "server", "DTHoomans/DTHoomans_SettlementVisit.lua")
local TraderBinding = loadSource(
    "DTHoomans", "server", "DTHoomans/DTHoomans_SettlementTrader.lua")
T.truthy(Settlement.ProvisionMarket, "market provisioning seam is available")

T.falsy(DTCommon.SettlementMarket.Get(community.id),
    "resident acceptance starts with no pre-created DT market")
local bound, bindReason = TraderBinding.EnsureTraderForFaction(faction.id)
T.truthy(bound, bindReason)
T.equal(bindReason, "bound", "newly staffed resident binds once")

local traderID = TraderBinding.TraderIDFor(faction.id)
local record = DTCommon.TraderService.GetRecord(traderID)
local market = DTCommon.SettlementMarket.Get(community.id)
T.truthy(market, "resident binding provisions the canonical community market")
T.equal(market.settlementID, community.id, "market uses community.id")
T.equal(market.profileID, "farm", "market profile uses bounded Hoomans tags")
T.equal(record.ca.homeSettlementID, community.id,
    "home context stores the canonical community identity")
T.equal(record.ca.currentSettlementID, community.id,
    "first pricing context is the resident home market")
T.falsy(record.ca.lastSettlementID,
    "home binding does not fabricate a commercial visit")
T.equal(record.ca.visitCount, 0,
    "home binding does not increment commercial visit count")
T.falsy(record.ca.lastVisitID,
    "home binding does not fabricate a visit id")

local beforeStock = DTCommon.Storage.LoadInventory(record)
local beforeUnrelated = beforeStock:count("Base.Unrelated")
local beforeVersion = record.v
local beforeBudget = record.b
local beforePressure = market.categories.Food.supply
local context = DTCommon.MarketPricing.BuildContext(record, nil, { now = 10 })
local quote = DTCommon.MarketPricing.GetItemContext(
    "Base.CannedBeans", context)
T.equal(context.settlementID, community.id,
    "pricing resolves the local market without an explicit visit")
T.equal(quote.marketSupply, 0.85,
    "quote uses the resident farm market supply")
T.equal(quote.marketDemand, 0.25,
    "quote uses the resident farm market demand")
local snapshot = DTCommon.TraderService.Snapshot(traderID)
T.truthy(snapshot, "resident snapshot is available")
T.equal(snapshot.settlementID, community.id,
    "snapshot exposes the resident local market")

local repeated, repeatedReason = TraderBinding.EnsureTraderForFaction(faction.id)
T.truthy(repeated, repeatedReason)
T.equal(repeatedReason, "already_bound", "resident binding is idempotent")
local afterMarket = DTCommon.SettlementMarket.Get(community.id)
local afterRecord = DTCommon.TraderService.GetRecord(traderID)
local afterStock = DTCommon.Storage.LoadInventory(afterRecord)
T.equal(afterRecord.v, beforeVersion, "context refresh does not reroll stock")
T.equal(afterRecord.b, beforeBudget, "context refresh does not change budget")
T.equal(afterStock:count("Base.Unrelated"), beforeUnrelated,
    "context refresh preserves exact stock")
T.equal(afterMarket.categories.Food.supply, beforePressure,
    "context refresh does not mutate market pressure")
T.equal(afterRecord.ca.lastSettlementID, nil,
    "repeat resident binding still has no commercial history")
T.equal(afterRecord.ca.visitCount, 0,
    "repeat resident binding still has no visit count")

return T.finish("dt_m9e_resident_market_context_smoke")
