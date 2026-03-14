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

    -- [Food.NonPerishable.Fish] [Rarity.Rare] (1 item)
    { item="Base.CandyGummyfish", basePrice=41, tags={"Food.NonPerishable.Fish", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.NonPerishable.Meat] [Rarity.Rare] (3 items)
    { item="Base.BeefJerky", basePrice=145, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=12} },
    { item="Base.DehydratedMeatStick", basePrice=75, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.PorkRinds", basePrice=118, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Fish] [Rarity.Rare] (14 items)
    { item="Base.BlueCatfish", basePrice=1, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.ChannelCatfish", basePrice=1, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.Crayfish", basePrice=49, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.FishFillet", basePrice=120, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=12} },
    { item="Base.FishFingers", basePrice=59, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.FishFried", basePrice=146, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=12} },
    { item="Base.FishGuts", basePrice=1, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.FishRoeSac", basePrice=1, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.FlatheadCatfish", basePrice=1, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.Frozen_FishFingers", basePrice=2, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.GreenSunfish", basePrice=1, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.Paddlefish", basePrice=1, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.RedearSunfish", basePrice=1, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.SushiFish", basePrice=64, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Meat] [Rarity.Rare] (26 items)
    { item="Base.Bacon", basePrice=78, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BaconRashers", basePrice=41, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Beef", basePrice=171, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Chicken", basePrice=113, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Chicken_Chick_Head", basePrice=6, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Chicken_Hen_Brown_Head", basePrice=6, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Chicken_Hen_White_Head", basePrice=6, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Chicken_Rooster_Head_Brown", basePrice=10, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chicken_Rooster_Head_White", basePrice=10, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ChickenFillet", basePrice=104, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.ChickenFoot", basePrice=95, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ChickenFried", basePrice=128, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ChickenNuggets", basePrice=59, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ChickenWhole", basePrice=158, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=5} },
    { item="Base.ChickenWings", basePrice=68, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.FrogMeat", basePrice=56, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Frozen_ChickenNuggets", basePrice=2, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.MeatDumpling", basePrice=78, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.MeatPatty", basePrice=146, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.MeatSteamBun", basePrice=113, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.MincedMeat", basePrice=137, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Pork", basePrice=128, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=7} },
    { item="Base.PorkChop", basePrice=101, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Rabbitmeat", basePrice=126, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Smallanimalmeat", basePrice=56, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Smallbirdmeat", basePrice=58, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
})

print("[DynamicTrading] Meat Registry Complete")
