local T = require "tests/support/test"

-- PsychopatzCore's physical currency adapter returns the rollback handle as
-- its third result.  DTCommon must retain that handle, not the first boolean,
-- when a later transfer fails.
local record = { v = 7, b = 100, a = 1 }
local stock = {
    count = function(_, fullType)
        return fullType == "Base.Bandage" and 1 or 0
    end,
    getWeight = function() return 0 end,
}
local restorationCalls = 0
local physical = {
    countCurrency = function() return 100 end,
    removeCurrency = function(_, amount)
        T.equal(amount, 10, "currency removal amount")
        return true, "removed", {
            currency = true,
            restore = function()
                restorationCalls = restorationCalls + 1
                return true
            end,
        }
    end,
    restoreRemoved = function(_, details)
        if type(details) ~= "table" then
            error("rollback requires the Core currency details table")
        end
        return details.restore() == true
    end,
}

local inventoryAPI = {
    wrapPhysicalInventory = function() return physical end,
    transfer = function(source)
        if source == stock then
            return false, "destination_add_failed"
        end
        return true
    end,
}

package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] =
    function() return inventoryAPI end
package.preload["PsychopatzCore/Economy/PsychopatzCurrency"] =
    function() return {} end

DTCommon = {
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    MONEY_FULL_TYPE = "Base.Money",
    Storage = {
        IsAuthority = function() return true end,
        LoadInventory = function() return stock end,
    },
    TraderStock = {
        Quote = function(_, fullType, operation)
            return {
                ok = true,
                fullType = fullType,
                operation = operation,
                unitPrice = 10,
            }
        end,
        MarketPrice = function() return 10 end,
    },
    TraderSupport = {
        Bounded = function(value) return tostring(value or "") end,
        PositiveInteger = function(value) return math.floor(tonumber(value) or 1) end,
    },
    TraderService = {
        GetRecord = function() return record end,
    },
}

local Service = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_TraderService.lua"
)
local ok, result = pcall(Service.ExecuteTrade, {
    getInventory = function() return {} end,
}, {
    traderID = "trader_kestrel",
    requestID = "t0-currency-rollback",
    observedStockVersion = 7,
    operation = "BUY",
    fullType = "Base.Bandage",
    quantity = 1,
})

T.truthy(ok, "currency rollback does not throw after transfer failure")
T.equal(result and result.accepted, false, "failed transfer is rejected")
T.equal(result and result.reason, "transfer_failed", "transfer failure reason")
T.equal(restorationCalls, 1, "currency rollback handle is invoked")

T.finish("dt_trading_t0_currency_rollback")
