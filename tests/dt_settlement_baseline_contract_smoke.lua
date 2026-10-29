local T = require "tests/support/test"

local persistentStore = {
    records = {
        { fullType = "Base.Bandage", quantity = 4 },
        { fullType = "Base.CannedBeans", quantity = 2 },
    },
}
local record = {
    s = "READY",
    v = 7,
    b = 500,
    i = { version = 1, rows = 2 },
    ca = {},
}
local seedCalls = 0
local snapshotCalls = 0
local authority = true

DTCommon = {
    STATUS_READY = "READY",
    STATUS_AWAY = "AWAY",
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    MONEY_FULL_TYPE = "Base.Money",
    Storage = {
        IsAuthority = function() return authority end,
        LoadInventory = function() return persistentStore end,
    },
    TraderSupport = {},
    TraderStock = {
        New = function()
            seedCalls = seedCalls + 1
            error("snapshot must not seed stock")
        end,
        SnapshotItems = function(_, store)
            snapshotCalls = snapshotCalls + 1
            return store.records
        end,
    },
    TraderService = {},
    DEFAULT_STOCK = {},
}
DTCommon.TraderSupport.Bounded = function(value, maximum)
    value = tostring(value or "")
    return #value > maximum and string.sub(value, 1, maximum) or value
end

local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
local savedRequire = require
require = function(moduleName)
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return Policy
    end
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory"
        or moduleName == "PsychopatzCore/Inventory/PsychopatzInventoryConstants"
        or moduleName == "PsychopatzCore/Economy/PsychopatzCurrency"
    then
        return {}
    end
    error("unexpected module in settlement baseline: " .. tostring(moduleName))
end
local Service = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderService.lua")
require = savedRequire
Service.GetRecord = function() return record end
Service.Get = function(traderID)
    return {
        traderID = traderID,
        stockVersion = record.v,
        items = {},
    }
end

local first, firstReason = Service.Snapshot("trader:persistent")
T.truthy(first, firstReason)
T.equal(#first.items, 2, "first snapshot exposes persisted stock")
local second, secondReason = Service.Snapshot("trader:persistent")
T.truthy(second, secondReason)
T.equal(#second.items, 2, "reopening exposes the same stock")
T.equal(seedCalls, 0, "opening a trader never rerolls stock")
T.equal(snapshotCalls, 2, "snapshots load the existing inventory each time")
T.equal(record.i.rows, 2, "serialized stock envelope remains untouched")

local missingContext, missingContextReason = Policy.MarkVisit(record, {
    authority = "server",
    atSettlement = true,
    visitID = "visit:missing-context",
})
T.equal(missingContext, nil, "visit without a settlement identity is rejected")
T.equal(missingContextReason, "settlement_required",
    "missing settlement identity has an explicit reason")

local visit, visitReason = Policy.MarkVisit(record, {
    authority = "server",
    atSettlement = true,
    settlementID = "community_alpha",
    visitID = "visit:alpha:1",
    now = 12,
})
T.truthy(visit, visitReason)
T.equal(visit.lastSettlementID, "community_alpha",
    "visit stores the supplied settlement context")
local duplicate, duplicateReason = Policy.MarkVisit(record, {
    authority = "server",
    atSettlement = true,
    settlementID = "community_alpha",
    visitID = "visit:alpha:1",
    now = 12,
})
T.equal(duplicate, nil, "duplicate visit is rejected")
T.equal(duplicateReason, "duplicate_visit", "duplicate visit reason is stable")

authority = false
local rejected = Service.ExecuteTradeBasket(nil, {
    traderID = "trader:persistent",
    requestID = "trade:client",
    observedStockVersion = record.v,
    buyRows = { { fullType = "Base.Bandage", quantity = 1 } },
    sellRows = {},
})
T.equal(rejected.accepted, false, "client-side trade execution is rejected")
T.equal(rejected.reason, "server_authority_required",
    "trade authority rejection is explicit")

T.finish("dt_settlement_baseline_contract")
