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

    -- [Tool.Cookware] [Rarity.Common] (2 items)
    { item="Base.GridlePan", basePrice=35, tags={"Tool.Cookware", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=8} },
    { item="Base.TinOpener_Old", basePrice=34, tags={"Tool.Cookware", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=8} },

    -- [Tool.Cookware] [Rarity.Rare] (31 items)
    { item="Base.BakingPan", basePrice=37, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.BakingTray", basePrice=37, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.BastingBrush", basePrice=20, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BottleOpener", basePrice=20, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.BottleOpener_Keychain", basePrice=20, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=22} },
    { item="Base.CheeseGrater", basePrice=25, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Corkscrew", basePrice=22, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.CuttingBoardPlastic", basePrice=19, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.CuttingBoardWooden", basePrice=19, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.GrillBrush", basePrice=26, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Kettle", basePrice=31, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Kettle_Copper", basePrice=31, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.KitchenTongs", basePrice=22, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.Ladle", basePrice=25, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.MuffinTray", basePrice=37, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.OvenMitt", basePrice=20, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.P38", basePrice=20, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=22} },
    { item="Base.PizzaCutter", basePrice=26, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Pot", basePrice=33, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.PotForged", basePrice=33, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.RoastingPan", basePrice=36, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Saucepan", basePrice=42, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.SaucepanCopper", basePrice=42, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.SkewersWooden", basePrice=20, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.Spatula", basePrice=20, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Strainer", basePrice=25, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Timer", basePrice=22, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.TinOpener", basePrice=21, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Whisk", basePrice=25, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.WoodenFork", basePrice=23, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=11} },
    { item="Base.WoodenSpoon", basePrice=23, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=11} },
})

print("[DynamicTrading] Cookware Registry Complete")
