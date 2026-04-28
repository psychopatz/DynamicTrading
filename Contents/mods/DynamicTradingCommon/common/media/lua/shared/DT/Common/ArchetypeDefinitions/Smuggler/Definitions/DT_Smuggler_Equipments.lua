require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("Smuggler", {
        meleeWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.KitchenKnife", weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.HuntingKnife", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Crowbar", weight = 2 },
            { module = "DynamicTradingCommon",  item = "Base.BaseballBat", weight = 2 },
        },
        rangedWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.Pistol", ammoMin = 12, ammoMax = 36, weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Pistol2", ammoMin = 10, ammoMax = 30, weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Revolver_Short", ammoMin = 6, ammoMax = 18, weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Revolver", ammoMin = 6, ammoMax = 18, weight = 2 },
        },
        bags = {
            { module = "DynamicTradingCommon",  item = "Base.Bag_BurglarBag", weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_SheetSlingBag", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_Schoolbag_Travel", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_TennisBag", weight = 2 },
        },
        bagChance = 0.75,
        rangedChance = {
            shootingThreshold = 6,
            base = 0.14,
            perLevel = 0.05,
            max = 0.60,
        },
    })
end
