-- Bounded MarketSense-backed candidate selection for settlement exchange.

DTCommon = DTCommon or {}

local Candidates = DTCommon.SettlementExchangeCandidates or {}
DTCommon.SettlementExchangeCandidates = Candidates

local Exchange = DTCommon.SettlementExchange
local Inventory = require "PsychopatzCore/Inventory/PsychopatzInventory"
local C = require "PsychopatzCore/Inventory/PsychopatzInventoryConstants"
local Stock = DTCommon.TraderStock
local Catalog = DTCommon.MarketCatalog
local Pricing = DTCommon.MarketPricing

local function integer(value, fallback)
    value = tonumber(value)
    return value and math.floor(value) or fallback
end

local function sortedKeys(value)
    local keys = {}
    for key, _ in pairs(value or {}) do
        if type(key) == "string" and key ~= "" then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    return keys
end

local function categoryPressure(market, category)
    return market.categories and market.categories[category]
        or { supply = 0.5, demand = 0.5 }
end

local function appendDelta(deltas, category, supplyDelta, demandDelta)
    local entry = deltas[category]
    if not entry then
        entry = { supplyDelta = 0, demandDelta = 0 }
        deltas[category] = entry
    end
    entry.supplyDelta = entry.supplyDelta + supplyDelta
    entry.demandDelta = entry.demandDelta + demandDelta
end

local function quote(fullType, operation, context)
    if not Stock or type(Stock.Quote) ~= "function" then return nil end
    local result = Stock.Quote(fullType, operation, nil, context)
    if type(result) ~= "table" or result.ok ~= true then return nil end
    return math.max(1, integer(result.unitPrice, 1))
end

local function recordFullType(record)
    if not record or not Inventory
        or type(Inventory.getItemFullType) ~= "function"
    then
        return nil
    end
    return tostring(Inventory.getItemFullType(record[C.TYPE_ID]) or "")
end

local function addOperation(plan, operation)
    if plan.operationCount >= plan.maxOperations then return false end
    if plan.unitCount + operation.quantity > plan.maxUnits then return false end
    plan.operations[#plan.operations + 1] = operation
    plan.operationCount = plan.operationCount + 1
    plan.unitCount = plan.unitCount + operation.quantity
    if operation.direction == "dispose" then
        plan.saleTotal = plan.saleTotal
            + operation.unitPrice * operation.quantity
    else
        plan.purchaseTotal = plan.purchaseTotal
            + operation.unitPrice * operation.quantity
    end
    return true
end

local function availableCandidateLimit(candidates, context)
    local multiplier = 1
    local itemContext
    local limit
    if #candidates < 1 then return 0 end
    if Pricing and type(Pricing.GetItemContext) == "function" then
        itemContext = Pricing.GetItemContext(candidates[1], context)
        multiplier = tonumber(itemContext and itemContext.availabilityMultiplier)
            or 1
    end
    if multiplier <= 0 then return 0 end
    limit = math.floor(#candidates * math.min(4, multiplier) + 0.5)
    return math.max(1, math.min(#candidates, limit))
end

function Candidates.PlanDisposals(plan, store, context)
    local candidates = {}
    local seen = {}
    local iterator
    local record
    if not store or type(store.iterate) ~= "function" then return end
    iterator = store:iterate()
    record = iterator()
    while record do
        local fullType = recordFullType(record)
        if fullType ~= "" and not seen[fullType]
            and Catalog and type(Catalog.Get) == "function"
        then
            local fact = Catalog.Get(fullType)
            local pressure = fact and categoryPressure(plan.market, fact.category)
            if fact and fact.category
                and pressure.demand > pressure.supply
            then
                local unitPrice = quote(fullType, DTCommon.OP_SELL, context)
                local quantity = type(store.count) == "function"
                    and math.min(1, store:count(fullType)) or 1
                if unitPrice and quantity > 0 then
                    candidates[#candidates + 1] = {
                        category = fact.category,
                        fullType = fullType,
                        quantity = quantity,
                        unitPrice = unitPrice,
                    }
                end
            end
            seen[fullType] = true
        end
        record = iterator()
    end
    table.sort(candidates, function(left, right)
        return left.fullType < right.fullType
    end)
    local remaining = Exchange.MAX_DISPOSAL_UNITS
    for index = 1, #candidates do
        if remaining <= 0 then break end
        local candidate = candidates[index]
        candidate.quantity = math.min(candidate.quantity, remaining)
        if addOperation(plan, {
            direction = "dispose",
            category = candidate.category,
            fullType = candidate.fullType,
            quantity = candidate.quantity,
            unitPrice = candidate.unitPrice,
        }) then
            appendDelta(plan.deltas, candidate.category,
                Exchange.SUPPLY_DELTA_PER_UNIT * candidate.quantity,
                -Exchange.DEMAND_DELTA_PER_UNIT * candidate.quantity)
            remaining = remaining - candidate.quantity
        end
    end
end

function Candidates.PlanAcquisitions(plan, context)
    local categories = sortedKeys(plan.market.categories)
    local selected = {}
    local remaining = Exchange.MAX_ACQUISITION_UNITS
    local availableBudget = plan.budgetBefore + plan.saleTotal
    for index = 1, #categories do
        if remaining <= 0 or plan.operationCount >= plan.maxOperations then break end
        local category = categories[index]
        local pressure = categoryPressure(plan.market, category)
        if pressure.supply > pressure.demand
            and Catalog and type(Catalog.GetCandidates) == "function"
        then
            local candidates = Catalog.GetCandidates(category, {
                limit = 8,
                availableOnly = true,
            })
            local candidateLimit = availableCandidateLimit(
                candidates or {}, context)
            for candidateIndex = 1, candidateLimit do
                if remaining <= 0
                    or plan.operationCount >= plan.maxOperations
                then break end
                local fullType = tostring(candidates[candidateIndex] or "")
                if fullType ~= "" and not selected[fullType]
                    and not plan.disposals[fullType]
                then
                    local unitPrice = quote(fullType, DTCommon.OP_BUY, context)
                    local quantity = unitPrice and math.min(
                        1, remaining, math.floor(availableBudget / unitPrice)) or 0
                    if unitPrice and quantity > 0
                        and addOperation(plan, {
                            direction = "acquire",
                            category = category,
                            fullType = fullType,
                            quantity = quantity,
                            unitPrice = unitPrice,
                            availabilityMultiplier = Pricing
                                and type(Pricing.GetItemContext) == "function"
                                and (Pricing.GetItemContext(fullType, context)
                                    or {}).availabilityMultiplier or 1,
                        })
                    then
                        selected[fullType] = true
                        appendDelta(plan.deltas, category,
                            -Exchange.SUPPLY_DELTA_PER_UNIT * quantity,
                            Exchange.DEMAND_DELTA_PER_UNIT * quantity)
                        availableBudget = availableBudget
                            - unitPrice * quantity
                        remaining = remaining - quantity
                    end
                end
            end
        end
    end
end

return Candidates
