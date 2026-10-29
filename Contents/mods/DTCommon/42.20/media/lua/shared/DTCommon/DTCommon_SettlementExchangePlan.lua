-- Builds a bounded settlement exchange plan without mutating stock or markets.

DTCommon = DTCommon or {}

local Plan = DTCommon.SettlementExchangePlan or {}
DTCommon.SettlementExchangePlan = Plan

local Storage = DTCommon.Storage
local Policy = DTCommon.CoreActorPolicy
local Market = DTCommon.SettlementMarket
local Candidates = require "DTCommon/DTCommon_SettlementExchangeCandidates"
local Exchange = DTCommon.SettlementExchange

local function authority()
    return Storage and type(Storage.IsAuthority) == "function"
        and Storage.IsAuthority() == true
end

local function integer(value, fallback)
    value = tonumber(value)
    return value and math.floor(value) or fallback
end

function Plan.Build(traderID, settlementID, options)
    local service = DTCommon.TraderService
    local record
    local market
    local store
    local reason
    local context
    local plan
    if not authority() then return nil, "server_authority_required" end
    if not service or type(service.GetRecord) ~= "function" then
        return nil, "trader_service_unavailable"
    end
    record = service.GetRecord(traderID)
    if not record then return nil, "trader_not_found" end
    if not Market or type(Market.Get) ~= "function" then
        return nil, "market_service_unavailable"
    end
    market, reason = Market.Get(settlementID)
    if not market then return nil, reason end
    if not Storage or type(Storage.LoadInventory) ~= "function" then
        return nil, "stock_storage_unavailable"
    end
    store, reason = Storage.LoadInventory(record)
    if not store then return nil, reason end
    options = type(options) == "table" and options or {}
    context = Policy and type(Policy.PriceContext) == "function"
        and Policy.PriceContext(record, nil) or {}
    plan = {
        traderID = traderID,
        settlementID = settlementID,
        marketRevision = market.revision,
        stockVersion = integer(record.v, 0),
        budgetBefore = math.max(0, integer(record.b, 0)),
        maxOperations = math.max(1, math.min(
            Exchange.MAX_OPERATIONS,
            integer(options.maxOperations, Exchange.MAX_OPERATIONS))),
        maxUnits = math.max(1, math.min(
            Exchange.MAX_UNITS,
            integer(options.maxUnits, Exchange.MAX_UNITS))),
        operationCount = 0,
        unitCount = 0,
        saleTotal = 0,
        purchaseTotal = 0,
        operations = {},
        disposals = {},
        deltas = {},
        market = market,
    }
    Candidates.PlanDisposals(plan, store, context)
    for index = 1, #plan.operations do
        local operation = plan.operations[index]
        if operation.direction == "dispose" then
            plan.disposals[operation.fullType] = true
        end
    end
    Candidates.PlanAcquisitions(plan, context)
    plan.budgetAfter = plan.budgetBefore + plan.saleTotal
        - plan.purchaseTotal
    return plan
end

return Plan
