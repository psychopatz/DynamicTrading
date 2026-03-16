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
    { item="Base.CandyGummyfish", basePrice=2015, tags={"Food.NonPerishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.NonPerishable.Meat] [Rarity.Rare] (3 items)
    { item="Base.BeefJerky", basePrice=2498, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=12} },
    { item="Base.DehydratedMeatStick", basePrice=2026, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.PorkRinds", basePrice=2034, tags={"Food.NonPerishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Fish] [Rarity.Rare] (13 items)
    { item="Base.BlueCatfish", basePrice=1181, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.ChannelCatfish", basePrice=1181, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.Crayfish", basePrice=1155, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FishFillet", basePrice=1620, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FishFingers", basePrice=1176, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FishFried", basePrice=1651, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FishRoeSac", basePrice=1155, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.FlatheadCatfish", basePrice=1181, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.Frozen_FishFingers", basePrice=1143, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.GreenSunfish", basePrice=1181, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.Paddlefish", basePrice=1181, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.RedearSunfish", basePrice=1181, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=3} },
    { item="Base.SushiFish", basePrice=1150, tags={"Food.Perishable.Fish", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },

    -- [Food.Perishable.Meat] [Rarity.Rare] (62 items)
    { item="Base.Bacon", basePrice=1193, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.BaconRashers", basePrice=1156, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Beef", basePrice=1263, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Bull_Head_Angus", basePrice=1150, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Bull_Head_Holstein", basePrice=1150, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Bull_Head_Simmental", basePrice=1150, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Calf_Head_Angus", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Calf_Head_Holstein", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Calf_Head_Simmental", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Chicken", basePrice=1639, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Chicken_Chick_Head", basePrice=1152, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Chicken_Hen_Brown_Head", basePrice=1152, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Chicken_Hen_White_Head", basePrice=1152, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Chicken_Rooster_Head_Brown", basePrice=1153, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Chicken_Rooster_Head_White", basePrice=1153, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.ChickenFillet", basePrice=1632, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.ChickenFoot", basePrice=1161, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.ChickenFried", basePrice=1175, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.ChickenNuggets", basePrice=1176, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.ChickenWhole", basePrice=1318, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.ChickenWings", basePrice=1182, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Cow_Head_Angus", basePrice=1150, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Cow_Head_Holstein", basePrice=1150, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Cow_Head_Simmental", basePrice=1150, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=1} },
    { item="Base.Deer_Buck_Head", basePrice=1150, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Deer_Doe_Head", basePrice=1150, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Deer_Fawn_Head", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.FrogMeat", basePrice=1178, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Frozen_ChickenNuggets", basePrice=1143, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.MeatDumpling", basePrice=1155, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.MeatPatty", basePrice=1669, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.MeatSteamBun", basePrice=1187, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.MincedMeat", basePrice=1658, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Pig_Boar_Head_Black", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pig_Boar_Head_Pink", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pig_Piglet_Head_Black", basePrice=1152, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pig_Piglet_Head_Pink", basePrice=1152, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pig_Sow_Head_Black", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pig_Sow_Head_Pink", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Pork", basePrice=1251, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PorkChop", basePrice=1629, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Rabbit_Head_Appalachian", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Rabbit_Head_CottonTail", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Rabbit_Head_Swamp", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Rabbit_Kitten_Head_Appalachian", basePrice=1152, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Rabbit_Kitten_Head_CottonTail", basePrice=1152, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Rabbit_Kitten_Head_Swamp", basePrice=1152, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Rabbitmeat", basePrice=1659, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Raccoon_Boar_Head", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Raccoon_Kit_Head", basePrice=1152, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Raccoon_Sow_Head", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Ewe_Head_Black", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Ewe_Head_White", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Lamb_Head_Black", basePrice=1152, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Lamb_Head_White", basePrice=1152, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Ram_Head_Black", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Sheep_Ram_Head_White", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Smallanimalmeat", basePrice=1173, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Smallbirdmeat", basePrice=1175, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Turkey_Gobbler_Head", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Turkey_Hen_Head", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Turkey_Poult_Head", basePrice=1151, tags={"Food.Perishable.Meat", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Meat Registry Complete")
