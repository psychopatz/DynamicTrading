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
    { item="Base.Cereal", basePrice=184, tags={"Food.NonPerishable.Grain", "Rarity.Common", "Food.HighNutrition"}, stockRange={min=2, max=12} },

    -- [Food.NonPerishable.Grain] [Rarity.Rare] (12 items)
    { item="Base.BarleySeed", basePrice=65, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=25} },
    { item="Base.BarleySheafDried", basePrice=5, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.CornSeed", basePrice=56, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=25} },
    { item="Base.CrispyRiceSquare", basePrice=48, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Gingerbreadman", basePrice=45, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.HempBundleDried", basePrice=5, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.LicoriceBlack", basePrice=15, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.LicoriceRed", basePrice=15, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Pasta", basePrice=29, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.HighNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.Popcorn", basePrice=81, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Rice", basePrice=54, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.RicePaper", basePrice=28, tags={"Food.NonPerishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Grain] [Rarity.Rare] (44 items)
    { item="Base.Acorn", basePrice=276, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.BagelPlain", basePrice=90, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BagelPoppy", basePrice=90, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BagelSesame", basePrice=90, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Baguette", basePrice=93, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BaguetteDough", basePrice=30, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.BaguetteSandwich", basePrice=65, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BarleySheaf", basePrice=10, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Bread", basePrice=146, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BreadDough", basePrice=58, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.BreadSlices", basePrice=92, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BunsHamburger", basePrice=46, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BunsHamburger_single", basePrice=92, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BunsHotdog", basePrice=53, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BunsHotdog_single", basePrice=92, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CerealBowl", basePrice=43, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Corn", basePrice=40, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.Cornbread", basePrice=99, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Corndog", basePrice=106, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CornFrozen", basePrice=65, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.HempBundle", basePrice=10, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.NoodleSoup", basePrice=12, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Oatmeal", basePrice=18, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.OatsRaw", basePrice=163, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.HighNutrition", "Food.HighQuality"}, stockRange={min=0, max=5} },
    { item="Base.PastaBowl", basePrice=18, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.PastaBowlClay", basePrice=18, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.PastaPan", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.PastaPanCopper", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Police", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.PastaPot", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.PastaPotForged", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.RiceBowl", basePrice=16, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.RiceBowlClay", basePrice=16, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.RicePan", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.RicePanCopper", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Police", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.RicePot", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.RicePotForged", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.WaterPotForgedPasta", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.WaterPotForgedRice", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.WaterPotPasta", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.WaterPotRice", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.WaterSaucepanPasta", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.WaterSaucepanPastaCopper", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Police", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.WaterSaucepanRice", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
    { item="Base.WaterSaucepanRiceCopper", basePrice=1, tags={"Food.Perishable.Grain", "Rarity.Rare", "Origin.Police", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Grain Registry Complete")
