local T = require "tests/support/test"

-- The merchant stock is buy-side data only.  A player may still have an
-- authoritative MarketSense sell quote for a concrete item outside that
-- stock.
PNC = {
    InventoryTransferEndpoint = {},
    InventoryUIModel = {
        BuildTradeStockRows = function(items) return items end,
    },
    ColonyStorageViewModel = {},
}

T.addPackagePaths({
    { "ProjectHoomans", "client" },
})

local Endpoint = T.load(
    "ProjectHoomans",
    "client",
    "PNC/UI/Inventory/PNC_InventoryTransferEndpoint/_Trade.lua"
)

local endpoint = Endpoint.Trade("trader_kestrel", {
    snapshot = {
        stockVersion = 4,
        items = {
            {
                fullType = "Base.Bandage",
                quantity = 5,
                unitPrice = 30,
                sellPrice = 15,
            },
        },
        sellRows = {
            {
                fullType = "Base.Katana",
                itemIDs = { "katana-1" },
                quantity = 1,
                unitPrice = 225,
            },
        },
    },
})

T.equal(
    endpoint:priceFor("Base.Katana", "SELL"),
    225,
    "non-stocked Base.Katana keeps its MarketSense sell quote"
)

T.finish("dt_trading_t0_katana")
