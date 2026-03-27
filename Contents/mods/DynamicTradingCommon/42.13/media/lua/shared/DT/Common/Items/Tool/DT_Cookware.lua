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
    { item="Base.GridlePan", basePrice=55, tags={"Tool.Cookware", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=8} },
    { item="Base.TinOpener_Old", basePrice=54, tags={"Tool.Cookware", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=8} },

    -- [Tool.Cookware] [Rarity.Rare] (25 items)
    { item="Base.BakingPan", basePrice=74, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.BakingTray", basePrice=74, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.BastingBrush", basePrice=58, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BottleOpener", basePrice=58, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.BottleOpener_Keychain", basePrice=58, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=22} },
    { item="Base.CheeseGrater", basePrice=63, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Corkscrew", basePrice=59, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.CuttingBoardPlastic", basePrice=57, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.CuttingBoardWooden", basePrice=57, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.GrillBrush", basePrice=63, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.KitchenTongs", basePrice=60, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.Ladle", basePrice=63, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.MuffinTray", basePrice=74, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.OvenMitt", basePrice=58, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.P38", basePrice=58, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=22} },
    { item="Base.PizzaCutter", basePrice=63, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.RoastingPan", basePrice=74, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.SkewersWooden", basePrice=58, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.Spatula", basePrice=57, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Strainer", basePrice=63, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Timer", basePrice=60, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.TinOpener", basePrice=58, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Whisk", basePrice=63, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.WoodenFork", basePrice=61, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=11} },
    { item="Base.WoodenSpoon", basePrice=61, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=11} },
})

print("[DynamicTrading] Cookware Registry Complete")
