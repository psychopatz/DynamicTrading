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
    { item="Base.Cereal", basePrice=202, tags={"Food.NonPerishable.Grain", "Rarity.Common", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=4, max=23} },

    -- [Food.NonPerishable.Grain] [Rarity.Rare] (12 items)
    { item="Base.BarleySeed", basePrice=120, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=24} },
    { item="Base.BarleySheafDried", basePrice=119, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.CornSeed", basePrice=113, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=29} },
    { item="Base.CrispyRiceSquare", basePrice=120, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Gingerbreadman", basePrice=126, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.HempBundleDried", basePrice=119, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.LicoriceBlack", basePrice=111, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.LicoriceRed", basePrice=111, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Pasta", basePrice=192, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.Popcorn", basePrice=184, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.Rice", basePrice=187, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.RicePaper", basePrice=113, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },

    -- [Food.Perishable.Grain] [Rarity.Rare] (44 items)
    { item="Base.Acorn", basePrice=126, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.BagelPlain", basePrice=108, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BagelPoppy", basePrice=129, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BagelSesame", basePrice=108, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Baguette", basePrice=177, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.BaguetteDough", basePrice=172, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.BaguetteSandwich", basePrice=119, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BarleySheaf", basePrice=116, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Bread", basePrice=207, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BreadDough", basePrice=193, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.BreadSlices", basePrice=112, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BunsHamburger", basePrice=144, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BunsHamburger_single", basePrice=112, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BunsHotdog", basePrice=138, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BunsHotdog_single", basePrice=112, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CerealBowl", basePrice=162, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Corn", basePrice=128, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.Cornbread", basePrice=115, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Corndog", basePrice=117, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CornFrozen", basePrice=162, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.HempBundle", basePrice=116, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.NoodleSoup", basePrice=86, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Oatmeal", basePrice=70, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.OatsRaw", basePrice=216, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition", "Food.HighQuality"}, stockRange={min=0, max=6} },
    { item="Base.PastaBowl", basePrice=88, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PastaBowlClay", basePrice=88, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PastaPan", basePrice=97, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.PastaPanCopper", basePrice=97, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.PastaPot", basePrice=96, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.PastaPotForged", basePrice=96, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RiceBowl", basePrice=85, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.RiceBowlClay", basePrice=85, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.RicePan", basePrice=100, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RicePanCopper", basePrice=100, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RicePot", basePrice=98, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.RicePotForged", basePrice=98, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotForgedPasta", basePrice=152, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotForgedRice", basePrice=149, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotPasta", basePrice=152, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterPotRice", basePrice=149, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanPasta", basePrice=152, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanPastaCopper", basePrice=152, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanRice", basePrice=149, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
    { item="Base.WaterSaucepanRiceCopper", basePrice=149, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Grain Registry Complete")
