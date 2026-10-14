-- Native adapter smoke: exercise the real MarketSense definition API through
-- DTCommon on the Project Zomboid server.  Player settlement remains a
-- separate SP/MP gate because this fixture has no live player inventory.

PZHarnessNativeTest = function()
    PZHarness.assertTrue(
        type(DTCommon) == "table"
            and type(DTCommon.TraderStock) == "table",
        "DTCommon trader stock boundary was not installed"
    )

    local intrinsic = DTCommon.TraderStock.Price("Base.Katana")
    PZHarness.assertTrue(
        intrinsic and intrinsic.ok == true
            and tonumber(intrinsic.intrinsicPrice) > 0,
        "MarketSense did not provide a positive Katana definition price"
    )

    local buy = DTCommon.TraderStock.Quote("Base.Katana", DTCommon.OP_BUY)
    local sell = DTCommon.TraderStock.Quote("Base.Katana", DTCommon.OP_SELL)
    PZHarness.assertEqual(
        buy.unitPrice,
        intrinsic.intrinsicPrice,
        "BUY quote did not preserve MarketSense intrinsic value"
    )
    PZHarness.assertEqual(
        sell.unitPrice,
        math.max(1, math.floor(intrinsic.intrinsicPrice * 0.5)),
        "SELL quote did not apply the bounded half-price margin"
    )

    local money = DTCommon.TraderStock.Price("Base.Money")
    PZHarness.assertTrue(
        money and money.ok ~= true and money.reason == "currency_not_tradeable",
        "currency was incorrectly admitted to the item quote boundary"
    )
end
