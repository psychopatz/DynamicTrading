local T = require "tests/support/test"

local function makeItem(id, fullType, options)
    options = options or {}
    local item = {
        id = tostring(id),
        fullType = fullType,
        favorite = options.favorite == true,
        equipped = options.equipped == true,
        count = options.count or 1,
    }
    function item:getID() return self.id end
    function item:getFullType() return self.fullType end
    function item:getCount() return self.count end
    function item:isFavorite() return self.favorite end
    function item:isEquipped() return self.equipped end
    function item:getModData() return {} end
    function item:getItemContainer() return nil end
    return item
end

local physical = {
    items = {
        makeItem("katana-1", "Base.Katana"),
    },
    currency = 20,
}
function physical:query(query)
    local result = {}
    for index = 1, #self.items do
        local item = self.items[index]
        local matches = query and query.predicate
            and query.predicate(item) or false
        if matches then result[#result + 1] = item end
    end
    return result
end
function physical:countCurrency() return self.currency end
function physical:removeCurrency(amount)
    if self.currency < amount then return false, "insufficient_currency" end
    self.currency = self.currency - amount
    local restored = false
    return true, "removed", {
        restore = function()
            if restored then return true end
            restored = true
            self.currency = self.currency + amount
            return true
        end,
    }
end
function physical:add(_, amount)
    self.currency = self.currency + amount
    local added = {}
    for index = 1, amount do
        added[index] = { currency = true, index = index }
    end
    return true, added
end
function physical:removeAdded(added)
    self.currency = self.currency - #added
    return true
end
function physical:restoreRemoved(details)
    return details and details.restore and details.restore() == true
end
function physical:getWeight() return 1 end
function physical:weightOf() return 1 end
function physical:canAdd(_, quantity, _, adjustment)
    local available = 100 - self:getWeight() + (adjustment or 0)
    if quantity > available then return false, "destination_capacity" end
    return true
end
function physical:iterate()
    local index = 0
    return function()
        index = index + 1
        return self.items[index]
    end
end

local stock = {
    counts = { ["Base.Bandage"] = 3 },
    getWeight = function() return 0 end,
    maxWeight = 100,
}
function stock:count(fullType) return self.counts[fullType] or 0 end
function stock:query(fullType)
    local count = self:count(fullType)
    if count < 1 then return {} end
    return { { [2] = count, [6] = 1 } }
end

local function removeByIdentity(list, wanted)
    for index = #list, 1, -1 do
        if list[index] == wanted then
            table.remove(list, index)
            return true
        end
    end
    return false
end

local transferSerial = 0
local inventoryAPI
inventoryAPI = {
    failNextBuy = false,
    wrapPhysicalInventory = function() return physical end,
    transfer = function(source, destination, query, quantity)
        transferSerial = transferSerial + 1
        local moved = {}
        if source == physical then
            local candidates = physical:query(query)
            if #candidates < quantity then return false, "item_unavailable" end
            for index = 1, quantity do
                local item = candidates[index]
                removeByIdentity(physical.items, item)
                stock.counts[item.fullType] = stock:count(item.fullType) + 1
                moved[#moved + 1] = item
            end
            local rolledBack = false
            return true, {
                rollback = function()
                    if rolledBack then return true end
                    rolledBack = true
                    for index = 1, #moved do
                        physical.items[#physical.items + 1] = moved[index]
                        stock.counts[moved[index].fullType] =
                            stock:count(moved[index].fullType) - 1
                    end
                    return true
                end,
            }
        end
        local fullType = query
        if inventoryAPI.failNextBuy then
            inventoryAPI.failNextBuy = false
            return false, "destination_add_failed"
        end
        if stock:count(fullType) < quantity then
            return false, "insufficient_stock"
        end
        stock.counts[fullType] = stock:count(fullType) - quantity
        for index = 1, quantity do
            moved[#moved + 1] = makeItem(
                "buy-" .. tostring(transferSerial) .. "-" .. tostring(index),
                fullType
            )
            physical.items[#physical.items + 1] = moved[index]
        end
        local rolledBack = false
        return true, {
            rollback = function()
                if rolledBack then return true end
                rolledBack = true
                for index = 1, #moved do
                    removeByIdentity(physical.items, moved[index])
                end
                stock.counts[fullType] = stock:count(fullType) + quantity
                return true
            end,
        }
    end,
}

package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] =
    function() return inventoryAPI end
package.preload["PsychopatzCore/Inventory/PsychopatzInventoryConstants"] =
    function() return { QUANTITY = 2 } end
package.preload["PsychopatzCore/Economy/PsychopatzCurrency"] =
    function() return {} end

local record = { v = 1, b = 100, a = 1 }
local snapshotCount = 0
local storageFailSave = false
DTCommon = {
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    STATUS_READY = "READY",
    MONEY_FULL_TYPE = "Base.Money",
    Storage = {
        IsAuthority = function() return true end,
        LoadInventory = function() return stock end,
        SaveInventory = function()
            if storageFailSave then return false, "save_failed" end
            return true
        end,
        Touch = function() return 1 end,
        Transmit = function() return true end,
    },
    TraderSupport = {
        Bounded = function(value)
            return tostring(value or "")
        end,
    },
    TraderStock = {
        Quote = function(fullType, operation, item)
            if item and item.fullType ~= fullType then
                return { ok = false, reason = "item_type_mismatch" }
            end
            local unitPrice = operation == "SELL" and 5 or 10
            if operation == "SELL" and item
                and item:getID() == "katana-3"
            then
                unitPrice = 7
            elseif operation == "SELL" and item
                and item:getID() == "katana-4"
            then
                unitPrice = 3
            end
            return {
                ok = true,
                fullType = fullType,
                operation = operation,
                unitPrice = unitPrice,
            }
        end,
        SnapshotItems = function()
            snapshotCount = snapshotCount + 1
            return {
                { fullType = "Base.Bandage", quantity = stock:count("Base.Bandage"), unitPrice = 10, sellPrice = 5 },
            }
        end,
        SnapshotSellRows = function() return {} end,
        SaveAndTransmit = function() end,
        EncodeItem = function() return { fullType = "Base.Money" } end,
    },
    TraderService = {
        GetRecord = function() return record end,
        Get = function(_, traderID)
            return {
                traderID = traderID,
                stockVersion = record.v,
                budget = record.b,
            }
        end,
    },
}

local Service = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_TraderService.lua"
)
local player = {
    getInventory = function() return {} end,
    getOnlineID = function() return 12 end,
}

local result = Service.ExecuteTradeBasket(player, {
    requestID = "basket-1",
    traderID = "trader-kestrel",
    observedStockVersion = 1,
    buyRows = {
        { fullType = "Base.Bandage", quantity = 2 },
    },
    sellRows = {
        { fullType = "Base.Katana", quantity = 1, itemIDs = { "katana-1" } },
    },
})
T.truthy(result.accepted, "mixed basket accepted")
T.equal(result.buyTotal, 20, "mixed basket buy total")
T.equal(result.sellTotal, 5, "mixed basket sell total")
T.equal(result.totalValue, 15, "mixed basket net total")
T.equal(record.b, 115, "trader budget conservation")
T.equal(record.v, 2, "stock version increments once")
T.equal(physical.currency, 5, "player currency netting")
T.equal(#physical.items, 2, "player item transfer")
T.equal(stock:count("Base.Bandage"), 1, "stock item transfer")
T.equal(stock:count("Base.Katana"), 1, "sold item enters stock")

physical.items[#physical.items + 1] = makeItem("katana-3", "Base.Katana")
physical.items[#physical.items + 1] = makeItem("katana-4", "Base.Katana")
local sameType = Service.ExecuteTradeBasket(player, {
    requestID = "basket-same-type",
    traderID = "trader-kestrel",
    observedStockVersion = 2,
    buyRows = {},
    sellRows = {
        { fullType = "Base.Katana", quantity = 1, itemIDs = { "katana-3" } },
        { fullType = "Base.Katana", quantity = 1, itemIDs = { "katana-4" } },
    },
})
T.truthy(sameType.accepted,
    "same full type with distinct instance quotes accepted")
T.equal(sameType.sellTotal, 10,
    "same full type rows preserve concrete MarketSense quotes")
T.equal(sameType.totalValue, -10, "sell-only basket has negative net total")
T.equal(physical.currency, 15, "sell-only basket credits player")
T.equal(record.b, 105, "sell-only basket debits trader budget")
T.equal(record.v, 3, "second basket increments stock version once")
T.equal(stock:count("Base.Katana"), 3,
    "both same-type identities enter stock")

local duplicate = Service.ExecuteTradeBasket(player, {
    requestID = "basket-1",
    traderID = "trader-kestrel",
    observedStockVersion = 3,
    buyRows = {
        { fullType = "Base.Bandage", quantity = 1 },
    },
    sellRows = {},
})
T.equal(duplicate.reason, "duplicate_request", "replay is rejected")
T.equal(record.v, 3, "replay leaves version unchanged")
T.equal(record.b, 105, "replay leaves budget unchanged")

local stale = Service.ExecuteTradeBasket(player, {
    requestID = "basket-stale",
    traderID = "trader-kestrel",
    observedStockVersion = 1,
    buyRows = {
        { fullType = "Base.Bandage", quantity = 1 },
    },
    sellRows = {},
})
T.equal(stale.reason, "stale_stock", "stale version is rejected")

physical.items[#physical.items + 1] = makeItem(
    "katana-favorite", "Base.Katana", { favorite = true }
)
local protected = Service.ExecuteTradeBasket(player, {
    requestID = "basket-protected",
    traderID = "trader-kestrel",
    observedStockVersion = 3,
    buyRows = {},
    sellRows = {
        { fullType = "Base.Katana", quantity = 1, itemIDs = { "katana-favorite" } },
    },
})
T.equal(protected.reason, "favorite", "protected item is rejected")
T.equal(record.v, 3, "protected rejection leaves version unchanged")

physical.items[#physical.items + 1] = makeItem("katana-2", "Base.Katana")
inventoryAPI.failNextBuy = true
local beforeCurrency = physical.currency
local beforeBudget = record.b
local rollback = Service.ExecuteTradeBasket(player, {
    requestID = "basket-rollback",
    traderID = "trader-kestrel",
    observedStockVersion = 3,
    buyRows = {
        { fullType = "Base.Bandage", quantity = 1 },
    },
    sellRows = {
        { fullType = "Base.Katana", quantity = 1, itemIDs = { "katana-2" } },
    },
})
T.equal(rollback.reason, "transfer_failed", "later transfer failure is reported")
T.equal(physical.currency, beforeCurrency, "rollback restores currency")
T.equal(record.b, beforeBudget, "rollback restores trader budget")
T.equal(record.v, 3, "rollback restores stock version")
T.equal(stock:count("Base.Bandage"), 1, "rollback restores buy stock")
T.equal(#physical:query({ predicate = function(item)
    return item:getID() == "katana-2"
end }), 1, "rollback restores sold item identity")

physical.items[#physical.items + 1] = makeItem("katana-save", "Base.Katana")
local beforeSaveFailureCurrency = physical.currency
local beforeSaveFailureBudget = record.b
storageFailSave = true
local saveFailure = Service.ExecuteTradeBasket(player, {
    requestID = "basket-save-failure",
    traderID = "trader-kestrel",
    observedStockVersion = 3,
    buyRows = {},
    sellRows = {
        { fullType = "Base.Katana", quantity = 1,
            itemIDs = { "katana-save" } },
    },
})
storageFailSave = false
T.equal(saveFailure.reason, "save_failed", "save failure is reported")
T.equal(physical.currency, beforeSaveFailureCurrency,
    "save failure removes credited currency")
T.equal(record.b, beforeSaveFailureBudget,
    "save failure restores trader budget")
T.equal(record.v, 3, "save failure restores stock version")
T.equal(stock:count("Base.Katana"), 3,
    "save failure restores stock item")
T.equal(#physical:query({ predicate = function(item)
    return item:getID() == "katana-save"
end }), 1, "save failure restores sold identity")

local noMoneyBeforeCurrency = physical.currency
physical.currency = 0
local noMoney = Service.ExecuteTradeBasket(player, {
    requestID = "basket-no-money",
    traderID = "trader-kestrel",
    observedStockVersion = 3,
    buyRows = { { fullType = "Base.Bandage", quantity = 1 } },
    sellRows = {},
})
T.equal(noMoney.reason, "insufficient_money", "insufficient funds rejected")
T.equal(physical.currency, 0, "insufficient funds do not mutate currency")
physical.currency = noMoneyBeforeCurrency

local beforeBudgetReject = record.b
record.b = 0
local noBudget = Service.ExecuteTradeBasket(player, {
    requestID = "basket-no-budget",
    traderID = "trader-kestrel",
    observedStockVersion = 3,
    buyRows = {},
    sellRows = {
        { fullType = "Base.Katana", quantity = 1,
            itemIDs = { "katana-save" } },
    },
})
T.equal(noBudget.reason, "trader_budget_exhausted", "budget rejection")
T.equal(record.b, 0, "budget rejection leaves budget unchanged")
T.equal(#physical:query({ predicate = function(item)
    return item:getID() == "katana-save"
end }), 1, "budget rejection leaves item unchanged")
record.b = beforeBudgetReject

local staleQuote = Service.ExecuteTradeBasket(player, {
    requestID = "basket-stale-quote",
    traderID = "trader-kestrel",
    observedStockVersion = 3,
    observedQuoteRevision = 2,
    buyRows = { { fullType = "Base.Bandage", quantity = 1 } },
    sellRows = {},
})
T.equal(staleQuote.reason, "stale_quote", "stale quote is rejected")

physical.items[#physical.items + 1] = makeItem(
    "katana-stack", "Base.Katana", { count = 5 })
local stacked = Service.ExecuteTradeBasket(player, {
    requestID = "basket-stacked",
    traderID = "trader-kestrel",
    observedStockVersion = 3,
    buyRows = {},
    sellRows = {
        { fullType = "Base.Katana", quantity = 1,
            itemIDs = { "katana-stack" } },
    },
})
T.equal(stacked.reason, "partial_stack_unsupported", "counted stack rejected")
T.equal(#physical:query({ predicate = function(item)
    return item:getID() == "katana-stack"
end }), 1, "counted stack remains in inventory")

physical.items[#physical.items + 1] = makeItem(
    "katana-equipped", "Base.Katana", { equipped = true })
local equipped = Service.ExecuteTradeBasket(player, {
    requestID = "basket-equipped",
    traderID = "trader-kestrel",
    observedStockVersion = 3,
    buyRows = {},
    sellRows = {
        { fullType = "Base.Katana", quantity = 1,
            itemIDs = { "katana-equipped" } },
    },
})
T.equal(equipped.reason, "equipped", "equipped item rejected")

physical.items[#physical.items + 1] = makeItem("katana-capacity", "Base.Katana")
physical.canAdd = function(_, quantity)
    return false, "destination_capacity"
end
local capacity = Service.ExecuteTradeBasket(player, {
    requestID = "basket-capacity",
    traderID = "trader-kestrel",
    observedStockVersion = 3,
    buyRows = { { fullType = "Base.Bandage", quantity = 1 } },
    sellRows = {},
})
T.equal(capacity.reason, "destination_capacity",
    "destination capacity rejected before settlement")
T.equal(record.v, 3, "capacity rejection leaves version unchanged")
physical.canAdd = function(_, quantity, _, adjustment)
    local available = 100 - physical:getWeight() + (adjustment or 0)
    if quantity > available then return false, "destination_capacity" end
    return true
end

T.truthy(snapshotCount > 0, "accepted trade refreshes snapshot")
T.finish("dt_trading_basket")
