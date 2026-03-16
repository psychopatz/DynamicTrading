-- ============================================================================
-- Food Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Food.NonPerishable.Grain] [Rarity.Common] (1 item)
    { item="Base.Cereal", basePrice=1382, tags={"Food.NonPerishable.Grain", "Rarity.Common", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=4, max=23} },

    -- [Food.NonPerishable.Grain] [Rarity.Rare] (12 items)
    { item="Base.BarleySeed", basePrice=2011, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=24} },
    { item="Base.BarleySheafDried", basePrice=2009, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.CornSeed", basePrice=2004, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=29} },
    { item="Base.CrispyRiceSquare", basePrice=2011, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Gingerbreadman", basePrice=2017, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.HempBundleDried", basePrice=2009, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.LicoriceBlack", basePrice=2002, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.LicoriceRed", basePrice=2002, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Pasta", basePrice=2083, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.Popcorn", basePrice=2074, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.Rice", basePrice=2077, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.RicePaper", basePrice=2003, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },

    -- [Food.Perishable.Grain] [Rarity.Rare] (44 items)
    { item="Base.Acorn", basePrice=1190, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.BagelPlain", basePrice=1173, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BagelPoppy", basePrice=1193, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BagelSesame", basePrice=1173, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Baguette", basePrice=1643, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.BaguetteDough", basePrice=1638, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.BaguetteSandwich", basePrice=1183, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BarleySheaf", basePrice=1181, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Bread", basePrice=1673, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BreadDough", basePrice=1659, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.BreadSlices", basePrice=1177, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BunsHamburger", basePrice=1610, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BunsHamburger_single", basePrice=1177, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BunsHotdog", basePrice=1604, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BunsHotdog_single", basePrice=1177, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CerealBowl", basePrice=1226, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Corn", basePrice=1193, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.Cornbread", basePrice=1179, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Corndog", basePrice=1181, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CornFrozen", basePrice=1226, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.HempBundle", basePrice=1181, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.NoodleSoup", basePrice=1151, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Oatmeal", basePrice=1135, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.OatsRaw", basePrice=1280, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition", "Food.HighQuality"}, stockRange={min=0, max=6} },
    { item="Base.PastaBowl", basePrice=1152, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PastaBowlClay", basePrice=1152, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PastaPan", basePrice=1563, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.PastaPanCopper", basePrice=1563, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.PastaPot", basePrice=1562, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.PastaPotForged", basePrice=1562, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RiceBowl", basePrice=1149, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.RiceBowlClay", basePrice=1149, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.RicePan", basePrice=1566, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RicePanCopper", basePrice=1566, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RicePot", basePrice=1564, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RicePotForged", basePrice=1564, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotForgedPasta", basePrice=1618, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotForgedRice", basePrice=1615, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotPasta", basePrice=1618, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotRice", basePrice=1615, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanPasta", basePrice=1618, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanPastaCopper", basePrice=1618, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanRice", basePrice=1615, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanRiceCopper", basePrice=1615, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Grain Registry Complete")
