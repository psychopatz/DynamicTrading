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

local authority = true
local modData = {}
local transmissions = {}
local travelStarts = 0
local sourceFaction
local targetFaction
local community
local npcRecord

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

local function copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = copy(item) end
    return output
end

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
    transmit = function(key) transmissions[#transmissions + 1] = key end,
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
    id = "community_m9a_farm",
    factionID = "faction_m9a_target",
    name = "M9A Farm",
    mode = "settled",
    status = "active",
    siteID = "site_m9a_farm",
    capacity = { population = 12 },
    memberIDs = {},
}
targetFaction = {
    id = "faction_m9a_target",
    status = "active",
    archetypeID = "settler",
    tags = { settlementType = "farm" },
    playerMemberKeys = { player_one = true },
    memberIDs = {},
}
sourceFaction = {
    id = "faction_m9a_caravan",
    status = "active",
    archetypeID = "trader",
    tags = { dynamicTrading = true, mobileGroup = true },
    mobile = { active = true },
    memberIDs = { npc_m9a_merchant = true },
}
npcRecord = {
    id = "npc_m9a_merchant",
    alive = true,
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
    API = {
        Travel = {
            RegisterArrivalHandler = function() return true end,
            Start = function()
                travelStarts = travelStarts + 1
                return nil, "not_used_by_normal_arrival"
            end,
        },
    },
    Travel = { Arrivals = { StrictActionTypes = {} } },
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
    caravanID = "caravan_m9a",
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
local stock = DTCommon.Storage.LoadInventory(record)
T.truthy(stock:add({ [1] = 2, [2] = 3 }), "unrelated carried stock is seeded")
T.truthy(DTCommon.Storage.SaveInventory(record, stock),
    "carried stock persists before arrival")
local startingVersion = record.v

-- Load the real Hoomans mobile-settlement service. The test only supplies
-- deterministic world/faction records; the admission/arrival implementation
-- is the production module used by the game.
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
    "DTHoomans observes the real Hoomans arrival service")
T.falsy(DTCommon.SettlementMarket.Get(community.id),
    "acceptance starts without a DT market")
T.equal(#DTCommon.SettlementMarket.List(16), 0,
    "no market fixture exists before normal arrival")
T.equal(Settlement.MarketProfileForCommunity(community), "farm",
    "bounded Hoomans faction tag selects the farm profile")
T.equal(Settlement.MarketProfileForCommunity({
    id = "community_unknown",
    factionID = "faction_unknown",
    mode = "settled",
}), "default", "unsupported Hoomans metadata falls back to default")

local target = {
    kind = "player_colony",
    factionID = targetFaction.id,
    communityID = community.id,
    locationID = "location_m9a_farm",
}
local travel = {
    kind = "settlement",
    purpose = "settlement_admission",
    revision = 17,
}
local group = { memberIds = { npcRecord.id } }
local arrived, arrivalReason = MobileSettlement.OnSettlementArrival(
    sourceFaction,
    target,
    travel,
    10,
    group,
    {}
)
T.truthy(arrived, arrivalReason)
T.equal(travelStarts, 0,
    "normal Hoomans arrival does not start a DT-owned journey")

local market = DTCommon.SettlementMarket.Get(community.id)
T.truthy(market, "normal Hoomans arrival provisions the market")
T.equal(market.settlementID, community.id,
    "market key is the Hoomans community id")
T.equal(market.profileID, "farm",
    "market profile is resolved from Hoomans metadata")
T.equal(#DTCommon.SettlementMarket.List(16), 1,
    "one market is provisioned")
T.equal(record.ca.lastSettlementID, community.id,
    "arrival forwards canonical settlement context")
T.equal(record.ca.visitCount, 1,
    "one normal arrival records one DT visit")
T.equal(record.v, startingVersion + 1,
    "arrival performs one bounded exchange")
local afterArrival = DTCommon.Storage.LoadInventory(record)
T.equal(afterArrival:count("Base.Unrelated"), 3,
    "settlement exchange preserves unrelated exact stock")
T.truthy(afterArrival:count("Base.CannedBeans") > 0,
    "settlement exchange acquires a MarketSense-backed food item")
local afterMarket = DTCommon.SettlementMarket.Get(community.id)
T.truthy(afterMarket.revision > market.revision - 1,
    "arrival exchange advances local market state")

-- Replay the same Hoomans travel revision. The observer may be notified again,
-- but DT's existing visit ledger makes the economic operation idempotent.
local replayed, replayReason = MobileSettlement.OnSettlementArrival(
    sourceFaction,
    target,
    travel,
    10,
    group,
    {}
)
T.truthy(replayed, replayReason)
T.equal(record.ca.visitCount, 1,
    "replayed Hoomans arrival does not increment DT visits")
T.equal(record.v, startingVersion + 1,
    "replayed Hoomans arrival does not repeat exchange")
T.equal(#DTCommon.SettlementMarket.List(16), 1,
    "replayed arrival does not duplicate the market")

return T.finish("dt_m9a_runtime_activation_smoke")
