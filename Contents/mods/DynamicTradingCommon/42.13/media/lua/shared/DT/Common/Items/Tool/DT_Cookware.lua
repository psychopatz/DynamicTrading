-- ============================================================================
-- Tool Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Tool.Cookware] [Rarity.Common] (3 items)
    { item="Base.GridlePan", basePrice=13, tags={"Tool.Cookware", "Rarity.Common", "Tool.Fragile"}, stockRange={min=2, max=10} },
    { item="Base.Mugl", basePrice=2, tags={"Tool.Cookware", "Rarity.Common"}, stockRange={min=5, max=25} },
    { item="Base.TinOpener_Old", basePrice=33, tags={"Tool.Cookware", "Rarity.Common", "Tool.Fragile"}, stockRange={min=2, max=10} },

    -- [Tool.Cookware] [Rarity.Rare] (39 items)
    { item="Base.BakingPan", basePrice=34, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.BakingTray", basePrice=34, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.BastingBrush", basePrice=113, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.BottleOpener", basePrice=170, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.BottleOpener_Keychain", basePrice=340, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Bowl", basePrice=3, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.CheeseGrater", basePrice=34, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.ClayBowl", basePrice=3, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.ClayMug", basePrice=4, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.CopperCup", basePrice=4, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Police"}, stockRange={min=0, max=6} },
    { item="Base.Corkscrew", basePrice=170, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.CuttingBoardPlastic", basePrice=34, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.CuttingBoardWooden", basePrice=34, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.GoldCup", basePrice=4, tags={"Tool.Cookware", "Rarity.Rare", "Quality.Luxury"}, stockRange={min=0, max=6} },
    { item="Base.GrillBrush", basePrice=113, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Kettle", basePrice=6, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Kettle_Copper", basePrice=6, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Police"}, stockRange={min=0, max=4} },
    { item="Base.KitchenTongs", basePrice=6, tags={"Tool.Cookware", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.Ladle", basePrice=57, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.MetalCup", basePrice=4, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.MuffinTray", basePrice=34, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.MugWhite", basePrice=4, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.OvenMitt", basePrice=113, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.P38", basePrice=340, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.PizzaCutter", basePrice=68, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Pot", basePrice=6, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.PotForged", basePrice=6, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.RoastingPan", basePrice=26, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Saucepan", basePrice=4, tags={"Tool.Cookware", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.SaucepanCopper", basePrice=4, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Police", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.SilverCup", basePrice=4, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.SkewersWooden", basePrice=170, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Spatula", basePrice=57, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Strainer", basePrice=34, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Timer", basePrice=113, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.TinOpener", basePrice=57, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Whisk", basePrice=57, tags={"Tool.Cookware", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.WoodenFork", basePrice=34, tags={"Tool.Cookware", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=10} },
    { item="Base.WoodenSpoon", basePrice=34, tags={"Tool.Cookware", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Cookware Registry Complete")
