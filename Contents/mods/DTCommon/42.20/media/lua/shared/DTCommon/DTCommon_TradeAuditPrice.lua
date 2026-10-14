-- MarketSense result and DTCommon quote-policy projections for TradeAudit.
DTCommon = DTCommon or {}

local Audit = DTCommon.TradeAudit
if type(Audit) ~= "table" then return nil end

local MAX_STRING = 160
local MAX_STAGES = 16
local MAX_FIELDS = 16
local boundedString = Audit.BoundedString
local number = Audit.Number
local copyValue = Audit.CopyValue
local safeItemValue = Audit.SafeItemValue

local function stateSummary(details, heuristic)
    local output = {}
    local count = 0
    local keys = {
        "conditionRatio", "remainingUsesRatio", "stateFactor",
        "weightPenalty", "isRotten", "isPoison", "isBurnt", "isDung",
        "useDelta", "maxUses", "foodState", "foodStateMultiplier",
    }
    for index = 1, #keys do
        local key = keys[index]
        local value = type(details) == "table" and details[key] or nil
        if value == nil and heuristic then value = heuristic[key] end
        if value ~= nil then
            output[key] = copyValue(value, 0, {})
            count = count + 1
        end
    end
    return count > 0 and output or nil
end

local function stageAudit(details)
    local source = type(details) == "table" and details.balanceAudit or nil
    local output
    local limit
    if type(source) ~= "table" then return nil end
    output = {}
    limit = math.min(#source, MAX_STAGES)
    for index = 1, limit do
        local stage = source[index]
        if type(stage) == "table" then
            local extra = stage.extra
            if extra == nil then
                extra = {}
                for key, value in pairs(stage) do
                    if key ~= "label" and key ~= "stage"
                        and key ~= "before" and key ~= "after"
                    then
                        extra[key] = value
                    end
                end
            end
            output[#output + 1] = {
                label = boundedString(stage.label or stage.stage or "stage", 100),
                before = number(stage.before),
                after = number(stage.after),
                extra = copyValue(extra, 0, {}),
            }
        end
    end
    if #source > MAX_STAGES then
        output[#output + 1] = { truncated = true }
    end
    return output
end

function Audit.RecordPrice(fullType, inventoryItem, result, details)
    if not Audit.Enabled then return false end
    local detailTable = type(details) == "table" and details or nil
    local heuristic = detailTable and detailTable.priceHeuristic
    local data = {
        fullType = boundedString(fullType, MAX_STRING),
        source = inventoryItem ~= nil and "instance" or "definition",
        status = result and result.status or "UNAVAILABLE",
        reason = result and result.reason,
        itemID = inventoryItem and boundedString(
            safeItemValue(inventoryItem, "getID"), 100) or nil,
        quantity = inventoryItem and number(
            safeItemValue(inventoryItem, "getCount")) or nil,
        marketSensePrice = detailTable and number(detailTable.price),
        intrinsicPrice = result and number(result.intrinsicPrice),
        rawScore = detailTable and number(detailTable.rawScore),
        category = detailTable and boundedString(detailTable.category, 80) or nil,
        primary = detailTable and boundedString(detailTable.primary, 80) or nil,
        confidence = detailTable and number(detailTable.confidence),
        detailsSource = detailTable and boundedString(detailTable.source, 80) or nil,
        state = stateSummary(detailTable, heuristic),
        balanceAudit = stageAudit(detailTable),
    }
    Audit.Increment("priceRequests")
    return Audit.Record("price", data)
end

function Audit.RecordQuote(fullType, operation, price)
    if not Audit.Enabled then return false end
    local ok = price and price.ok == true
    local intrinsic = ok and number(price.intrinsicPrice) or nil
    local multiplier
    if operation == DTCommon.OP_SELL then
        multiplier = 0.5
    elseif operation == DTCommon.OP_BUY then
        multiplier = 1.0
    end
    local rawQuote = intrinsic and multiplier and intrinsic * multiplier or nil
    local data = {
        fullType = boundedString(fullType or (price and price.fullType), MAX_STRING),
        source = price and price.source,
        operation = operation,
        status = price and price.status or "UNAVAILABLE",
        reason = price and price.reason,
        intrinsicPrice = intrinsic,
        multiplier = multiplier,
        rawQuote = rawQuote,
        rounding = operation == DTCommon.OP_SELL and "floor"
            or operation == DTCommon.OP_BUY and "integer" or nil,
        minimumPositive = operation == DTCommon.OP_SELL and 1 or nil,
        unitPrice = ok and number(price.unitPrice) or nil,
    }
    Audit.Increment("quotes")
    return Audit.Record("quote", data)
end

function Audit.RecordScan(kind, scanned, accepted, rows)
    if not Audit.Enabled then return false end
    Audit.Increment("snapshots")
    return Audit.Record("snapshot", {
        kind = boundedString(kind, 80),
        scanned = number(scanned) or 0,
        accepted = number(accepted) or 0,
        rows = number(rows) or 0,
    })
end

return Audit
