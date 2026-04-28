require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("General", {
        meleeWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.BaseballBat", weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Crowbar", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.LeadPipe", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Nightstick", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Hammer", weight = 2 },
            { module = "DynamicTradingCommon",  item = "Base.KitchenKnife", weight = 2 },
        },
        rangedWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.Pistol", ammoMin = 12, ammoMax = 36, weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Revolver", ammoMin = 6, ammoMax = 18, weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Pistol2", ammoMin = 8, ammoMax = 24, weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Revolver_Short", ammoMin = 6, ammoMax = 18, weight = 2 },
        },
        bags = {
            { module = "DynamicTradingCommon",  item = "Base.Bag_Schoolbag", weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_BurglarBag", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_SheetSlingBag", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_NormalHikingBag", weight = 2 },
        },
        bagChance = 0.55,
        rangedChance = {
            shootingThreshold = 8,
            base = 0.02,
            perLevel = 0.045,
            max = 0.35,
        },
    })
end
