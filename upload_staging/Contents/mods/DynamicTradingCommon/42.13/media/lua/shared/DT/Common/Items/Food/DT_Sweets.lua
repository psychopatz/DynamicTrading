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
    { item="Base.HardCandies", basePrice=78, tags={"Food.NonPerishable.Sweets", "Rarity.Common", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=3, max=22} },

    -- [Food.NonPerishable.Sweets] [Rarity.Rare] (30 items)
    { item="Base.CakeBatter", basePrice=159, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.CandyCaramels", basePrice=126, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyCorn", basePrice=133, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyMolasses", basePrice=126, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyNovapops", basePrice=145, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.CandyPackage", basePrice=162, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=4} },
    { item="Base.ChocoCakes", basePrice=139, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chocolate", basePrice=242, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Butterchunkers", basePrice=198, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Crackle", basePrice=198, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Deux", basePrice=199, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_GalacticDairy", basePrice=196, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_HeartBox", basePrice=297, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=8} },
    { item="Base.Chocolate_RoysPBPucks", basePrice=198, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Smirkers", basePrice=200, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_SnikSnak", basePrice=198, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.ChocolateChips", basePrice=145, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.ChocolateCoveredCoffeeBeans", basePrice=142, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=17} },
    { item="Base.CookieChocolateChip", basePrice=146, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.CookieJelly", basePrice=126, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookiesChocolate", basePrice=147, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.CookiesOatmeal", basePrice=115, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.CookiesShortbread", basePrice=125, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookiesSugar", basePrice=125, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.GummyBears", basePrice=122, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.GummyWorms", basePrice=122, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.MintCandy", basePrice=115, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.QuaggaCakes", basePrice=139, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.RockCandy", basePrice=122, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ScoutCookies", basePrice=213, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Sweets] [Rarity.Rare] (22 items)
    { item="Base.BakingTray_Muffin", basePrice=198, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.BakingTray_Muffin_Recipe", basePrice=198, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CakeBlackForest", basePrice=107, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeCheeseCake", basePrice=102, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeChocolate", basePrice=127, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.CakePrep", basePrice=210, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.CakeRaw", basePrice=167, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.CakeRedVelvet", basePrice=102, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeSlice", basePrice=99, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CookieChocolateChipDough", basePrice=233, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesChocolateDough", basePrice=214, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesOatmealDough", basePrice=147, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesShortbreadDough", basePrice=204, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesSugarDough", basePrice=204, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Cupcake", basePrice=146, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.DoughnutChocolate", basePrice=124, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.MuffinGeneric", basePrice=111, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Muffintray_Biscuit", basePrice=188, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pancakes", basePrice=125, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PancakesCraft", basePrice=129, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.PancakesRecipe", basePrice=134, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieWholeRawSweet", basePrice=126, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
})

print("[DynamicTrading] Sweets Registry Complete")
