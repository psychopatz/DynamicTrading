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
    { item="Base.GridlePan", basePrice=430, tags={"Tool.Cookware", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=8} },
    { item="Base.TinOpener_Old", basePrice=429, tags={"Tool.Cookware", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=8} },

    -- [Tool.Cookware] [Rarity.Rare] (31 items)
    { item="Base.BakingPan", basePrice=798, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.BakingTray", basePrice=798, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.BastingBrush", basePrice=781, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BottleOpener", basePrice=781, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.BottleOpener_Keychain", basePrice=781, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=22} },
    { item="Base.CheeseGrater", basePrice=786, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Corkscrew", basePrice=783, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.CuttingBoardPlastic", basePrice=781, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.CuttingBoardWooden", basePrice=781, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.GrillBrush", basePrice=787, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Kettle", basePrice=792, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Kettle_Copper", basePrice=792, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.KitchenTongs", basePrice=784, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.Ladle", basePrice=787, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.MuffinTray", basePrice=798, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.OvenMitt", basePrice=781, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.P38", basePrice=781, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=22} },
    { item="Base.PizzaCutter", basePrice=787, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Pot", basePrice=795, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.PotForged", basePrice=795, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.RoastingPan", basePrice=798, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Saucepan", basePrice=804, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.SaucepanCopper", basePrice=804, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.SkewersWooden", basePrice=781, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.Spatula", basePrice=781, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Strainer", basePrice=786, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Timer", basePrice=783, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.TinOpener", basePrice=782, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Whisk", basePrice=787, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.WoodenFork", basePrice=784, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=11} },
    { item="Base.WoodenSpoon", basePrice=784, tags={"Tool.Cookware", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=11} },
})

print("[DynamicTrading] Cookware Registry Complete")
