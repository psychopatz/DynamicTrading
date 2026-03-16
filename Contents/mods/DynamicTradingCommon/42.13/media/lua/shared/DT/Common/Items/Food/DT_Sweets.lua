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
    { item="Base.HardCandies", basePrice=16, tags={"Food.NonPerishable.Sweets", "Rarity.Common", "Food.LowNutrition"}, stockRange={min=3, max=22} },

    -- [Food.NonPerishable.Sweets] [Rarity.Rare] (30 items)
    { item="Base.CakeBatter", basePrice=39, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.CandyCaramels", basePrice=28, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyCorn", basePrice=34, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyMolasses", basePrice=27, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyNovapops", basePrice=46, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.CandyPackage", basePrice=42, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=4} },
    { item="Base.ChocoCakes", basePrice=40, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chocolate", basePrice=122, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Butterchunkers", basePrice=99, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Crackle", basePrice=99, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Deux", basePrice=100, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_GalacticDairy", basePrice=98, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_HeartBox", basePrice=199, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=8} },
    { item="Base.Chocolate_RoysPBPucks", basePrice=99, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_Smirkers", basePrice=101, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Chocolate_SnikSnak", basePrice=99, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.ChocolateChips", basePrice=46, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.ChocolateCoveredCoffeeBeans", basePrice=43, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=17} },
    { item="Base.CookieChocolateChip", basePrice=48, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.CookieJelly", basePrice=27, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookiesChocolate", basePrice=48, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.CookiesOatmeal", basePrice=17, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.CookiesShortbread", basePrice=26, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookiesSugar", basePrice=26, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.GummyBears", basePrice=23, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.GummyWorms", basePrice=23, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.MintCandy", basePrice=17, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.QuaggaCakes", basePrice=40, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.RockCandy", basePrice=23, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ScoutCookies", basePrice=114, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Sweets] [Rarity.Rare] (22 items)
    { item="Base.BakingTray_Muffin", basePrice=121, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.BakingTray_Muffin_Recipe", basePrice=121, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CakeBlackForest", basePrice=52, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeCheeseCake", basePrice=47, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeChocolate", basePrice=72, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.CakePrep", basePrice=133, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.CakeRaw", basePrice=90, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.CakeRedVelvet", basePrice=47, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeSlice", basePrice=44, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CookieChocolateChipDough", basePrice=156, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesChocolateDough", basePrice=159, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesOatmealDough", basePrice=70, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesShortbreadDough", basePrice=127, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.CookiesSugarDough", basePrice=127, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Cupcake", basePrice=91, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.DoughnutChocolate", basePrice=69, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.MuffinGeneric", basePrice=56, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Muffintray_Biscuit", basePrice=111, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pancakes", basePrice=70, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PancakesCraft", basePrice=74, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.PancakesRecipe", basePrice=79, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieWholeRawSweet", basePrice=71, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
})

print("[DynamicTrading] Sweets Registry Complete")
