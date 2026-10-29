local T = require "tests/support/test"
local loadSource = T.load

local TYPE_BY_ID = {
    [1] = "Base.Bandage",
    [2] = "Base.CannedBeans",
    [3] = "Base.Unrelated",
}
local ID_BY_TYPE = {
    ["Base.Bandage"] = 1,
    ["Base.CannedBeans"] = 2,
    ["Base.Unrelated"] = 3,
}

local function cloneRecord(record, quantity)
    return {
        [1] = record[1],
        [2] = quantity == nil and record[2] or quantity,
    }
end

local function newStore()
    local store = {
        rows = {
            { [1] = 1, [2] = 2 },
            { [1] = 3, [2] = 3 },
        },
    }

    function store:iterate()
        local index = 0
        return function()
            index = index + 1
            local record = self.rows[index]
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
        if self:count(fullType) < remaining then
            return false, "insufficient_quantity"
        end
        for index = #self.rows, 1, -1 do
            local record = self.rows[index]
            if record[1] == typeID and remaining > 0 then
                local take = math.min(remaining, record[2])
                removed[#removed + 1] = cloneRecord(record, take)
                record[2] = record[2] - take
                remaining = remaining - take
                if record[2] <= 0 then table.remove(self.rows, index) end
            end
        end
        return true, removed
    end

    function store:add(record)
        if type(record) ~= "table" or not record[1] or not record[2] then
            return false, "invalid_record"
        end
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

local function quantities(store)
    local output = {}
    for index = 1, #store.rows do
        local fullType = TYPE_BY_ID[store.rows[index][1]]
        output[fullType] = store.rows[index][2]
    end
    return output
end

local authority = true
local record = { v = 4, b = 5, i = { serialized = "old" } }
local currentStore = newStore()
local saveShouldFail = false
local saveCalls = 0
local stockTransmissions = 0
local marketApplyCalls = 0
local marketGets = 0
local marketRevisionRace = false
local stockVersionRace = false
local recordGets = 0
local market = {
    revision = 11,
    categories = {
        Food = { supply = 0.8, demand = 0.2 },
        Medical = { supply = 0.2, demand = 0.8 },
    },
}

local function copyMarket()
    return {
        revision = market.revision,
        categories = {
            Food = {
                supply = market.categories.Food.supply,
                demand = market.categories.Food.demand,
            },
            Medical = {
                supply = market.categories.Medical.supply,
                demand = market.categories.Medical.demand,
            },
        },
    }
end

local Inventory = {
    getItemFullType = function(typeID) return TYPE_BY_ID[typeID] end,
}
local Constants = { TYPE_ID = 1, QUANTITY = 2 }

DTCommon = {
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    Storage = {
        IsAuthority = function() return authority end,
        LoadInventory = function() return currentStore end,
        SaveInventory = function(target)
            saveCalls = saveCalls + 1
            if saveShouldFail then return false, "save_failed" end
            target.i = { serialized = "saved", rows = #currentStore.rows }
            return true
        end,
    },
    TraderStock = {
        Quote = function(fullType, operation)
            if not ID_BY_TYPE[fullType] then
                return { ok = false, reason = "unknown_item" }
            end
            return {
                ok = true,
                fullType = fullType,
                unitPrice = operation == "SELL" and 5 or 10,
            }
        end,
        EncodeItem = function(fullType, quantity)
            local typeID = ID_BY_TYPE[fullType]
            return typeID and { [1] = typeID, [2] = quantity } or nil,
                typeID and nil or "item_type_unavailable"
        end,
        SaveAndTransmit = function() stockTransmissions = stockTransmissions + 1 end,
    },
    TraderSupport = {},
    CoreActorPolicy = {
        PriceContext = function() return { relationshipModifier = 0 } end,
    },
    SettlementMarket = {
        Get = function()
            marketGets = marketGets + 1
            local value = copyMarket()
            if marketRevisionRace and marketGets >= 2 then
                value.revision = 12
            end
            return value
        end,
        ApplyDelta = function(_, delta, options)
            marketApplyCalls = marketApplyCalls + 1
            if options.expectedRevision ~= market.revision then
                return nil, "market_revision_conflict"
            end
            T.truthy(delta.categories.Food, "food pressure delta is present")
            T.truthy(delta.categories.Medical, "medical pressure delta is present")
            return { revision = market.revision + 1 }, true
        end,
    },
    MarketCatalog = {
        Get = function(fullType)
            if fullType == "Base.Bandage" then
                return { fullType = fullType, category = "Medical" }
            end
            if fullType == "Base.CannedBeans" then
                return { fullType = fullType, category = "Food" }
            end
            return nil
        end,
        GetCandidates = function(category)
            if category == "Food" then return { "Base.CannedBeans" } end
            return {}
        end,
    },
    TraderService = {
        GetRecord = function()
            recordGets = recordGets + 1
            if stockVersionRace and recordGets >= 2 then record.v = 5 end
            return record
        end,
    },
}

local savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventoryConstants" then
        return Constants
    end
    if moduleName == "DTCommon/DTCommon_SettlementExchangePlan" then
        return loadSource(
            "DTCommon", "shared",
            "DTCommon/DTCommon_SettlementExchangePlan.lua")
    end
    if moduleName == "DTCommon/DTCommon_SettlementExchangeCandidates" then
        return loadSource(
            "DTCommon", "shared",
            "DTCommon/DTCommon_SettlementExchangeCandidates.lua")
    end
    error("unexpected module in settlement exchange: " .. tostring(moduleName))
end
local Exchange = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementExchange.lua")
require = savedRequire

local plan, planReason = Exchange.Plan("trader:exchange", "community_farm", {
    maxOperations = 4,
    maxUnits = 4,
})
T.truthy(plan, planReason)
T.equal(#plan.operations, 2, "planner stays within the bounded exchange")
T.equal(plan.operations[1].direction, "dispose", "shortage stock is disposed first")
T.equal(plan.operations[1].fullType, "Base.Bandage",
    "disposal follows the MarketSense category")
T.equal(plan.operations[2].direction, "acquire", "surplus stock is acquired")
T.equal(plan.operations[2].fullType, "Base.CannedBeans",
    "acquisition follows the bounded category candidates")
T.equal(plan.budgetAfter, 0, "planned budget never goes negative")
T.equal(plan.deltas.Food.supplyDelta, -0.05,
    "acquisition records only its actual supply delta")
T.equal(plan.deltas.Medical.supplyDelta, 0.05,
    "disposal records only its actual supply delta")

marketGets = 0
recordGets = 0
saveCalls = 0
stockTransmissions = 0
marketApplyCalls = 0
currentStore = newStore()
record = { v = 4, b = 5, i = { serialized = "old" } }
local executed, executeReason = Exchange.Execute(
    "trader:exchange", "community_farm", { now = 24 })
T.truthy(executed, executeReason)
T.equal(executed.changed, true, "exchange commits actual operations")
T.equal(executed.stockVersion, 5, "exchange increments stock version once")
T.equal(executed.marketRevision, 12, "exchange returns the new market revision")
T.equal(record.v, 5, "persistent stock version increments once")
T.equal(record.b, 0, "persistent trader budget remains non-negative")
T.equal(saveCalls, 1, "exchange serializes stock once")
T.equal(stockTransmissions, 1, "exchange transmits stock once")
T.equal(marketApplyCalls, 1, "exchange applies market pressure once")
local afterExchange = quantities(currentStore)
T.equal(afterExchange["Base.Bandage"], 1,
    "exchange changes only one unit of shortage stock")
T.equal(afterExchange["Base.CannedBeans"], 1,
    "exchange acquires one bounded candidate")
T.equal(afterExchange["Base.Unrelated"], 3,
    "unrelated existing stock is preserved")

saveShouldFail = true
marketRevisionRace = false
stockVersionRace = false
marketGets = 0
recordGets = 0
saveCalls = 0
marketApplyCalls = 0
currentStore = newStore()
record = { v = 4, b = 5, i = { serialized = "old" } }
local failed, failedReason = Exchange.Execute(
    "trader:exchange", "community_farm", { now = 25 })
T.equal(failed, nil, "save failure rejects the exchange")
T.equal(failedReason, "save_failed", "save failure reason is preserved")
T.equal(record.v, 4, "save failure restores stock version")
T.equal(record.b, 5, "save failure restores budget")
local afterSaveFailure = quantities(currentStore)
T.equal(afterSaveFailure["Base.Bandage"], 2,
    "save failure restores disposed stock")
T.equal(afterSaveFailure["Base.CannedBeans"], nil,
    "save failure removes acquired stock")
T.equal(marketApplyCalls, 0, "save failure never mutates market pressure")

saveShouldFail = false
marketRevisionRace = true
marketGets = 0
recordGets = 0
currentStore = newStore()
record = { v = 4, b = 5, i = { serialized = "old" } }
local staleMarket, staleMarketReason = Exchange.Execute(
    "trader:exchange", "community_farm", { now = 26 })
T.equal(staleMarket, nil, "stale market plan is rejected before mutation")
T.equal(staleMarketReason, "market_revision_conflict",
    "stale market plan has an explicit reason")
T.equal(quantities(currentStore)["Base.Bandage"], 2,
    "stale market plan preserves stock")

marketRevisionRace = false
stockVersionRace = true
marketGets = 0
recordGets = 0
currentStore = newStore()
record = { v = 4, b = 5, i = { serialized = "old" } }
local staleStock, staleStockReason = Exchange.Execute(
    "trader:exchange", "community_farm", { now = 27 })
T.equal(staleStock, nil, "stale stock plan is rejected before mutation")
T.equal(staleStockReason, "stock_version_conflict",
    "stale stock plan has an explicit reason")
T.equal(quantities(currentStore)["Base.Bandage"], 2,
    "stale stock plan preserves exact stock")

stockVersionRace = false
market.categories.Food.supply = 0.5
market.categories.Food.demand = 0.5
market.categories.Medical.supply = 0.5
market.categories.Medical.demand = 0.5
marketGets = 0
recordGets = 0
saveCalls = 0
marketApplyCalls = 0
currentStore = newStore()
record = { v = 4, b = 5, i = { serialized = "old" } }
local unchanged, unchangedReason = Exchange.Execute(
    "trader:exchange", "community_farm", { now = 28 })
T.truthy(unchanged, unchangedReason)
T.equal(unchanged.changed, false, "balanced pressure produces no exchange")
T.equal(saveCalls, 0, "no-op exchange does not save stock")
T.equal(marketApplyCalls, 0, "no-op exchange does not mutate pressure")

authority = false
local denied, deniedReason = Exchange.Execute(
    "trader:exchange", "community_farm", {})
T.equal(denied, nil, "client cannot execute settlement exchange")
T.equal(deniedReason, "server_authority_required",
    "exchange authority rejection is explicit")

T.finish("dt_settlement_exchange")
