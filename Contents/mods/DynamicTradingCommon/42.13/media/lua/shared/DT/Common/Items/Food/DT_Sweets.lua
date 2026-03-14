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
    { item="Base.HardCandies", basePrice=22, tags={"Food.NonPerishable.Sweets", "Rarity.Common", "Food.LowNutrition"}, stockRange={min=2, max=12} },

    -- [Food.NonPerishable.Sweets] [Rarity.Rare] (28 items)
    { item="Base.CakeBatter", basePrice=25, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.CandyCaramels", basePrice=46, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyCorn", basePrice=44, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyMolasses", basePrice=45, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyNovapops", basePrice=42, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandyPackage", basePrice=26, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=5} },
    { item="Base.ChocoCakes", basePrice=51, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chocolate", basePrice=164, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chocolate_Butterchunkers", basePrice=137, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chocolate_Crackle", basePrice=137, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chocolate_Deux", basePrice=138, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chocolate_GalacticDairy", basePrice=136, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chocolate_HeartBox", basePrice=134, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Chocolate_RoysPBPucks", basePrice=137, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chocolate_Smirkers", basePrice=139, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chocolate_SnikSnak", basePrice=137, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ChocolateChips", basePrice=44, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ChocolateCoveredCoffeeBeans", basePrice=37, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookieChocolateChip", basePrice=45, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookieJelly", basePrice=45, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookiesChocolate", basePrice=46, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookiesOatmeal", basePrice=41, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookiesShortbread", basePrice=42, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookiesSugar", basePrice=42, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.MintCandy", basePrice=18, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.QuaggaCakes", basePrice=51, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.RockCandy", basePrice=37, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ScoutCookies", basePrice=178, tags={"Food.NonPerishable.Sweets", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Sweets] [Rarity.Rare] (22 items)
    { item="Base.BakingTray_Muffin", basePrice=27, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=5} },
    { item="Base.BakingTray_Muffin_Recipe", basePrice=27, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=5} },
    { item="Base.CakeBlackForest", basePrice=53, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CakeCheeseCake", basePrice=44, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CakeChocolate", basePrice=53, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CakePrep", basePrice=81, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.CakeRaw", basePrice=46, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.CakeRedVelvet", basePrice=44, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CakeSlice", basePrice=40, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CookieChocolateChipDough", basePrice=23, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CookiesChocolateDough", basePrice=23, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CookiesOatmealDough", basePrice=21, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CookiesShortbreadDough", basePrice=22, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CookiesSugarDough", basePrice=22, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Cupcake", basePrice=108, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.DoughnutChocolate", basePrice=71, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.MuffinGeneric", basePrice=73, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Muffintray_Biscuit", basePrice=25, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Pancakes", basePrice=61, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.PancakesCraft", basePrice=11, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.PancakesRecipe", basePrice=73, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.PieWholeRawSweet", basePrice=1, tags={"Food.Perishable.Sweets", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
})

print("[DynamicTrading] Sweets Registry Complete")
