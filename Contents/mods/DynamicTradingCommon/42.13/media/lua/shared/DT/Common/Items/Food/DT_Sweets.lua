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

    -- [Food.NonPerishable.Sweets] [Rarity.Common] (1 item)
    { item="Base.HardCandies", basePrice=1258, tags={"Food.NonPerishable.Sweets", "Rarity.Common", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=3, max=22} },

    -- [Food.NonPerishable.Sweets] [Rarity.Rare] (30 items)
    { item="Base.CakeBatter", basePrice=2451, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.CandyCaramels", basePrice=2017, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyCorn", basePrice=2024, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyMolasses", basePrice=2017, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyNovapops", basePrice=2036, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.CandyPackage", basePrice=2455, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=4} },
    { item="Base.ChocoCakes", basePrice=2030, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chocolate", basePrice=2535, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Butterchunkers", basePrice=2089, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Crackle", basePrice=2089, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Deux", basePrice=2089, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_GalacticDairy", basePrice=2087, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_HeartBox", basePrice=2188, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=8} },
    { item="Base.Chocolate_RoysPBPucks", basePrice=2089, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Smirkers", basePrice=2091, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_SnikSnak", basePrice=2089, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.ChocolateChips", basePrice=2035, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.ChocolateCoveredCoffeeBeans", basePrice=2033, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=17} },
    { item="Base.CookieChocolateChip", basePrice=2037, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.CookieJelly", basePrice=2017, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookiesChocolate", basePrice=2037, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.CookiesOatmeal", basePrice=2006, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.CookiesShortbread", basePrice=2015, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookiesSugar", basePrice=2015, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.GummyBears", basePrice=2012, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.GummyWorms", basePrice=2012, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.MintCandy", basePrice=2006, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.QuaggaCakes", basePrice=2030, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.RockCandy", basePrice=2012, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ScoutCookies", basePrice=2104, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Sweets] [Rarity.Rare] (22 items)
    { item="Base.BakingTray_Muffin", basePrice=1664, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.BakingTray_Muffin_Recipe", basePrice=1664, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CakeBlackForest", basePrice=1171, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeCheeseCake", basePrice=1166, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeChocolate", basePrice=1192, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.CakePrep", basePrice=1676, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.CakeRaw", basePrice=1633, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.CakeRedVelvet", basePrice=1166, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeSlice", basePrice=1164, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CookieChocolateChipDough", basePrice=1699, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesChocolateDough", basePrice=1278, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesOatmealDough", basePrice=1613, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesShortbreadDough", basePrice=1670, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesSugarDough", basePrice=1670, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Cupcake", basePrice=1210, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.DoughnutChocolate", basePrice=1188, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.MuffinGeneric", basePrice=1175, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Muffintray_Biscuit", basePrice=1654, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pancakes", basePrice=1189, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PancakesCraft", basePrice=1193, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.PancakesRecipe", basePrice=1199, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieWholeRawSweet", basePrice=1190, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
})

print("[DynamicTrading] Sweets Registry Complete")
