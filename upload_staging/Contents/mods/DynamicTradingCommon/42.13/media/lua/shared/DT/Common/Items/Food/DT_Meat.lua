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
    { item="Base.CandyGummyfish", basePrice=124, tags={"Food.NonPerishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.NonPerishable.Meat] [Rarity.Rare] (3 items)
    { item="Base.BeefJerky", basePrice=206, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=12} },
    { item="Base.DehydratedMeatStick", basePrice=135, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.PorkRinds", basePrice=143, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Fish] [Rarity.Rare] (13 items)
    { item="Base.BlueCatfish", basePrice=117, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.ChannelCatfish", basePrice=117, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.Crayfish", basePrice=91, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FishFillet", basePrice=154, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FishFingers", basePrice=112, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FishFried", basePrice=185, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FishRoeSac", basePrice=91, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.FlatheadCatfish", basePrice=117, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.Frozen_FishFingers", basePrice=79, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.GreenSunfish", basePrice=117, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.Paddlefish", basePrice=117, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.RedearSunfish", basePrice=117, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.SushiFish", basePrice=86, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },

    -- [Food.Perishable.Meat] [Rarity.Rare] (62 items)
    { item="Base.Bacon", basePrice=129, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BaconRashers", basePrice=91, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Beef", basePrice=199, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Bull_Head_Angus", basePrice=85, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Bull_Head_Holstein", basePrice=85, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Bull_Head_Simmental", basePrice=85, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Calf_Head_Angus", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Calf_Head_Holstein", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Calf_Head_Simmental", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Chicken", basePrice=173, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Chicken_Chick_Head", basePrice=88, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Chicken_Hen_Brown_Head", basePrice=88, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Chicken_Hen_White_Head", basePrice=88, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Chicken_Rooster_Head_Brown", basePrice=88, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Chicken_Rooster_Head_White", basePrice=88, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.ChickenFillet", basePrice=166, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.ChickenFoot", basePrice=97, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.ChickenFried", basePrice=111, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.ChickenNuggets", basePrice=112, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.ChickenWhole", basePrice=254, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.ChickenWings", basePrice=117, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Cow_Head_Angus", basePrice=85, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Cow_Head_Holstein", basePrice=85, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Cow_Head_Simmental", basePrice=85, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Deer_Buck_Head", basePrice=86, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Deer_Doe_Head", basePrice=86, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Deer_Fawn_Head", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.FrogMeat", basePrice=114, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Frozen_ChickenNuggets", basePrice=79, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.MeatDumpling", basePrice=91, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.MeatPatty", basePrice=203, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.MeatSteamBun", basePrice=123, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.MincedMeat", basePrice=192, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Pig_Boar_Head_Black", basePrice=86, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pig_Boar_Head_Pink", basePrice=86, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pig_Piglet_Head_Black", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pig_Piglet_Head_Pink", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pig_Sow_Head_Black", basePrice=86, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pig_Sow_Head_Pink", basePrice=86, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pork", basePrice=186, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PorkChop", basePrice=163, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Rabbit_Head_Appalachian", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Rabbit_Head_CottonTail", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Rabbit_Head_Swamp", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Rabbit_Kitten_Head_Appalachian", basePrice=88, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Rabbit_Kitten_Head_CottonTail", basePrice=88, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Rabbit_Kitten_Head_Swamp", basePrice=88, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Rabbitmeat", basePrice=193, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Raccoon_Boar_Head", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Raccoon_Kit_Head", basePrice=88, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Raccoon_Sow_Head", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Ewe_Head_Black", basePrice=86, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Ewe_Head_White", basePrice=86, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Lamb_Head_Black", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Lamb_Head_White", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Ram_Head_Black", basePrice=86, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Ram_Head_White", basePrice=86, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Smallanimalmeat", basePrice=108, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Smallbirdmeat", basePrice=111, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Turkey_Gobbler_Head", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Turkey_Hen_Head", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Turkey_Poult_Head", basePrice=87, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Meat Registry Complete")
