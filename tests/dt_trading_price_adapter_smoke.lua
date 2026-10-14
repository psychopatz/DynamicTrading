local T = require "tests/support/test"

package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] =
    function() return {} end

DTCommon = {
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    MONEY_FULL_TYPE = "Base.Money",
    Storage = {},
    TraderSupport = {},
    TraderStock = {},
}

MarketSense = {
    GetPriceDetails = function(fullType)
        if fullType == "Base.Unknown" then return nil end
        if fullType == "Base.Zero" then return { price = 0 } end
        return { price = 451 }
    end,
    GetPriceDetailsForInstance = function(_, item)
        return { price = item and item.condition }
    end,
}

local Stock = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_TraderStock.lua"
)

local buy = Stock.Quote("Base.Katana", "BUY")
T.truthy(buy.ok, "definition quote is available")
T.equal(buy.unitPrice, 451, "buy uses the integer intrinsic price")

local sell = Stock.Quote("Base.Katana", "SELL")
T.truthy(sell.ok, "definition sell quote is available")
T.equal(sell.unitPrice, 225, "sell applies one deterministic half-price floor")

local worn = Stock.Quote("Base.Katana", "SELL", { condition = 301 })
local damaged = Stock.Quote("Base.Katana", "SELL", { condition = 101 })
T.equal(worn.unitPrice, 150, "instance condition affects sell quote")
T.equal(damaged.unitPrice, 50, "instance quote is not a pristine definition quote")

local missing = Stock.Quote("Base.Unknown", "BUY")
T.falsy(missing.ok, "missing MarketSense price is unavailable")
T.equal(missing.reason, "price_details_unavailable", "missing price reason")

local zero = Stock.Quote("Base.Zero", "BUY")
T.falsy(zero.ok, "zero MarketSense price is unavailable")
T.equal(zero.reason, "price_unavailable", "zero price reason")

local currency = Stock.Quote("Base.Money", "BUY")
T.falsy(currency.ok, "settlement currency is not merchandise")
T.equal(currency.reason, "currency_not_tradeable", "currency rejection reason")

T.finish("dt_trading_price_adapter")
