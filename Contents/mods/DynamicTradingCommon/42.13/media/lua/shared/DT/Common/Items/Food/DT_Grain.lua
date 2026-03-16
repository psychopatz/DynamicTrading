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
    { item="Base.Cereal", basePrice=140, tags={"Food.NonPerishable.Grain", "Rarity.Common", "Food.HighNutrition"}, stockRange={min=4, max=23} },

    -- [Food.NonPerishable.Grain] [Rarity.Rare] (12 items)
    { item="Base.BarleySeed", basePrice=22, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=24} },
    { item="Base.BarleySheafDried", basePrice=20, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.CornSeed", basePrice=14, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=29} },
    { item="Base.CrispyRiceSquare", basePrice=22, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Gingerbreadman", basePrice=27, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.HempBundleDried", basePrice=20, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.LicoriceBlack", basePrice=12, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.LicoriceRed", basePrice=12, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Pasta", basePrice=94, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.HighNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.Popcorn", basePrice=85, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.Rice", basePrice=88, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.RicePaper", basePrice=14, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },

    -- [Food.Perishable.Grain] [Rarity.Rare] (44 items)
    { item="Base.Acorn", basePrice=70, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.BagelPlain", basePrice=53, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BagelPoppy", basePrice=74, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BagelSesame", basePrice=53, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Baguette", basePrice=100, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.BaguetteDough", basePrice=95, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.BaguetteSandwich", basePrice=64, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BarleySheaf", basePrice=61, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Bread", basePrice=131, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BreadDough", basePrice=116, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.BreadSlices", basePrice=57, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BunsHamburger", basePrice=67, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BunsHamburger_single", basePrice=57, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BunsHotdog", basePrice=61, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BunsHotdog_single", basePrice=57, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CerealBowl", basePrice=107, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Corn", basePrice=73, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.Cornbread", basePrice=60, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Corndog", basePrice=62, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CornFrozen", basePrice=107, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.HempBundle", basePrice=61, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.NoodleSoup", basePrice=31, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Oatmeal", basePrice=15, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.OatsRaw", basePrice=161, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.HighNutrition", "Food.HighQuality"}, stockRange={min=0, max=6} },
    { item="Base.PastaBowl", basePrice=33, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PastaBowlClay", basePrice=33, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PastaPan", basePrice=21, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.PastaPanCopper", basePrice=22, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Police", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.PastaPot", basePrice=19, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.PastaPotForged", basePrice=19, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RiceBowl", basePrice=30, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.RiceBowlClay", basePrice=30, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.RicePan", basePrice=23, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RicePanCopper", basePrice=25, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Police", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RicePot", basePrice=21, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RicePotForged", basePrice=21, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotForgedPasta", basePrice=75, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotForgedRice", basePrice=72, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotPasta", basePrice=75, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotRice", basePrice=72, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanPasta", basePrice=75, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanPastaCopper", basePrice=81, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Police", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanRice", basePrice=72, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanRiceCopper", basePrice=78, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Police", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Grain Registry Complete")
