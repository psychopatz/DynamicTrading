-- Bounded settlement logistics over exact persistent trader stock. A visit may
-- move a small number of MarketSense-backed goods, but never rerolls stock.

DTCommon = DTCommon or {}

local Exchange = DTCommon.SettlementExchange or {}
DTCommon.SettlementExchange = Exchange

local Planner = require "DTCommon/DTCommon_SettlementExchangePlan"
local Storage = DTCommon.Storage
local Stock = DTCommon.TraderStock
local Market = DTCommon.SettlementMarket
local Pricing = DTCommon.MarketPricing

Exchange.VERSION = 1
Exchange.MAX_OPERATIONS = 8
Exchange.MAX_UNITS = 8
Exchange.MAX_DISPOSAL_UNITS = 4
Exchange.MAX_ACQUISITION_UNITS = 4
Exchange.SUPPLY_DELTA_PER_UNIT = 0.05
Exchange.DEMAND_DELTA_PER_UNIT = 0.02

local function authority()
    return Storage and type(Storage.IsAuthority) == "function"
        and Storage.IsAuthority() == true
end

local function integer(value, fallback)
    value = tonumber(value)
    return value and math.floor(value) or fallback
end

function Exchange.Plan(traderID, settlementID, options)
    return Planner.Build(traderID, settlementID, options)
end

local function rollbackAdded(store, added)
    for index = #added, 1, -1 do
        local entry = added[index]
        if not store:remove(entry.fullType, entry.quantity) then
            return false
        end
    end
    return true
end

local function rollbackRemoved(store, removed)
    for index = #removed, 1, -1 do
        local records = removed[index]
        if type(records) ~= "table" then return false end
        for recordIndex = 1, #records do
            if not store:add(records[recordIndex]) then return false end
        end
    end
    return true
end

local function rollbackMutations(store, added, removed)
    return rollbackAdded(store, added) and rollbackRemoved(store, removed)
end

function Exchange.Execute(traderID, settlementID, options)
    local service = DTCommon.TraderService
    local record
    local plan
    local reason
    local store
    local previousInventory
    local previousBudget
    local previousVersion
    local removed = {}
    local added = {}
    local operation
    local result
    local saved
    local currentMarket
    local marketResult
    local marketReason
    if not authority() then return nil, "server_authority_required" end
    options = type(options) == "table" and options or {}
    plan, reason = Exchange.Plan(traderID, settlementID, options)
    if not plan then return nil, reason end
    if #plan.operations < 1 then
        return {
            changed = false,
            traderID = traderID,
            settlementID = settlementID,
            stockVersion = plan.stockVersion,
            marketRevision = plan.marketRevision,
            eventRevision = plan.eventRevision,
            quoteContextRevision = plan.quoteContextRevision,
            operations = {},
        }
    end
    if Pricing and type(Pricing.IsCurrent) == "function" then
        local contextOK, contextReason = Pricing.IsCurrent(
            plan.pricingContext)
        if not contextOK then return nil, contextReason end
    end
    record = service.GetRecord(traderID)
    if not record then return nil, "trader_not_found" end
    if integer(record.v, 0) ~= plan.stockVersion then
        return nil, "stock_version_conflict"
    end
    currentMarket, reason = Market.Get(settlementID)
    if not currentMarket then return nil, reason end
    if currentMarket.revision ~= plan.marketRevision then
        return nil, "market_revision_conflict"
    end
    store, reason = Storage.LoadInventory(record)
    if not store then return nil, reason end
    previousInventory = record.i
    previousBudget = math.max(0, integer(record.b, 0))
    previousVersion = integer(record.v, 0)
    for index = 1, #plan.operations do
        operation = plan.operations[index]
        if operation.direction == "dispose" then
            local ok
            local removedRecords
            ok, removedRecords = store:remove(
                operation.fullType, operation.quantity)
            if not ok or type(removedRecords) ~= "table" then
                if not rollbackMutations(store, added, removed) then
                    return nil, "exchange_rollback_failed"
                end
                return nil, type(removedRecords) == "string"
                    and removedRecords or "exchange_disposal_failed"
            end
            removed[#removed + 1] = removedRecords
        else
            local recordValue
            if not Stock or type(Stock.EncodeItem) ~= "function" then
                if not rollbackMutations(store, added, removed) then
                    return nil, "exchange_rollback_failed"
                end
                return nil, "stock_encoder_unavailable"
            end
            recordValue, reason = Stock.EncodeItem(
                operation.fullType, operation.quantity)
            if not recordValue then
                if not rollbackMutations(store, added, removed) then
                    return nil, "exchange_rollback_failed"
                end
                return nil, reason or "exchange_item_unavailable"
            end
            local ok
            ok, reason = store:add(recordValue)
            if not ok then
                if not rollbackMutations(store, added, removed) then
                    return nil, "exchange_rollback_failed"
                end
                return nil, reason or "exchange_acquisition_failed"
            end
            added[#added + 1] = {
                fullType = operation.fullType,
                quantity = operation.quantity,
            }
        end
    end
    record.b = math.max(0, math.floor(plan.budgetAfter))
    record.v = previousVersion + 1
    saved, reason = Storage.SaveInventory(record, store)
    if not saved then
        local rolledBack = rollbackMutations(store, added, removed)
        record.b = previousBudget
        record.v = previousVersion
        record.i = previousInventory
        if not rolledBack then return nil, "exchange_rollback_failed" end
        return nil, reason or "exchange_save_failed"
    end
    marketResult, marketReason = Market.ApplyDelta(settlementID, {
        categories = plan.deltas,
    }, {
        expectedRevision = plan.marketRevision,
        now = options.now,
    })
    if not marketResult then
        local rolledBack = rollbackMutations(store, added, removed)
        record.b = previousBudget
        record.v = previousVersion
        record.i = previousInventory
        if not rolledBack then return nil, "exchange_rollback_failed" end
        return nil, marketReason or "exchange_market_failed"
    end
    if Stock and type(Stock.SaveAndTransmit) == "function" then
        Stock.SaveAndTransmit()
    end
    result = {
        changed = true,
        traderID = traderID,
        settlementID = settlementID,
        stockVersion = record.v,
        marketRevision = marketResult.revision,
        eventRevision = plan.eventRevision,
        quoteContextRevision = plan.quoteContextRevision,
        budget = record.b,
        operations = plan.operations,
        saleTotal = plan.saleTotal,
        purchaseTotal = plan.purchaseTotal,
    }
    return result
end

return Exchange
