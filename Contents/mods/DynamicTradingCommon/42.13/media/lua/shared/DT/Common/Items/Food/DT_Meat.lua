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
    { item="Base.CandyGummyfish", basePrice=26, tags={"Food.NonPerishable.Fish", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.NonPerishable.Meat] [Rarity.Rare] (3 items)
    { item="Base.BeefJerky", basePrice=86, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=12} },
    { item="Base.DehydratedMeatStick", basePrice=37, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.PorkRinds", basePrice=45, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Fish] [Rarity.Rare] (13 items)
    { item="Base.BlueCatfish", basePrice=62, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.ChannelCatfish", basePrice=62, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.Crayfish", basePrice=36, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.FishFillet", basePrice=77, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=12} },
    { item="Base.FishFingers", basePrice=57, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.FishFried", basePrice=109, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=12} },
    { item="Base.FishRoeSac", basePrice=35, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.FlatheadCatfish", basePrice=62, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.Frozen_FishFingers", basePrice=24, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.GreenSunfish", basePrice=62, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.Paddlefish", basePrice=62, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.RedearSunfish", basePrice=62, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.SushiFish", basePrice=31, tags={"Food.Perishable.Fish", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Meat] [Rarity.Rare] (62 items)
    { item="Base.Bacon", basePrice=73, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BaconRashers", basePrice=36, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Beef", basePrice=143, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Bull_Head_Angus", basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Bull_Head_Holstein", basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Bull_Head_Simmental", basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Calf_Head_Angus", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Calf_Head_Holstein", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Calf_Head_Simmental", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Chicken", basePrice=96, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Chicken_Chick_Head", basePrice=33, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Chicken_Hen_Brown_Head", basePrice=33, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Chicken_Hen_White_Head", basePrice=33, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Chicken_Rooster_Head_Brown", basePrice=33, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Chicken_Rooster_Head_White", basePrice=33, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ChickenFillet", basePrice=89, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.ChickenFoot", basePrice=42, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ChickenFried", basePrice=56, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ChickenNuggets", basePrice=57, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.ChickenWhole", basePrice=199, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=5} },
    { item="Base.ChickenWings", basePrice=62, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Cow_Head_Angus", basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Cow_Head_Holstein", basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Cow_Head_Simmental", basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Deer_Buck_Head", basePrice=31, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Deer_Doe_Head", basePrice=31, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Deer_Fawn_Head", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.FrogMeat", basePrice=59, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Frozen_ChickenNuggets", basePrice=24, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.MeatDumpling", basePrice=36, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.MeatPatty", basePrice=126, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.MeatSteamBun", basePrice=68, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.MincedMeat", basePrice=115, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Pig_Boar_Head_Black", basePrice=31, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Pig_Boar_Head_Pink", basePrice=31, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Pig_Piglet_Head_Black", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Pig_Piglet_Head_Pink", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Pig_Sow_Head_Black", basePrice=31, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Pig_Sow_Head_Pink", basePrice=31, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Pork", basePrice=131, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=7} },
    { item="Base.PorkChop", basePrice=86, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Rabbit_Head_Appalachian", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Rabbit_Head_CottonTail", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Rabbit_Head_Swamp", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Rabbit_Kitten_Head_Appalachian", basePrice=33, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Rabbit_Kitten_Head_CottonTail", basePrice=33, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Rabbit_Kitten_Head_Swamp", basePrice=33, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Rabbitmeat", basePrice=116, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Raccoon_Boar_Head", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Raccoon_Kit_Head", basePrice=33, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Raccoon_Sow_Head", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Sheep_Ewe_Head_Black", basePrice=31, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Sheep_Ewe_Head_White", basePrice=31, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Sheep_Lamb_Head_Black", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Sheep_Lamb_Head_White", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Sheep_Ram_Head_Black", basePrice=31, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Sheep_Ram_Head_White", basePrice=31, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Smallanimalmeat", basePrice=53, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Smallbirdmeat", basePrice=55, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Turkey_Gobbler_Head", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Turkey_Hen_Head", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Turkey_Poult_Head", basePrice=32, tags={"Food.Perishable.Meat", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
})

print("[DynamicTrading] Meat Registry Complete")
