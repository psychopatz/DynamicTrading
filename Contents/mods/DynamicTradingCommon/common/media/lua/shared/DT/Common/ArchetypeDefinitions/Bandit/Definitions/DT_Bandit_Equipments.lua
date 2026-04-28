require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("Bandit", {
        meleeWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.BaseballBat", weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Crowbar", weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.HuntingKnife", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Machete", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.HandAxe", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Nightstick", weight = 2 },
        },
        rangedWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.Pistol", ammoMin = 6, ammoMax = 24, weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.Revolver", ammoMin = 6, ammoMax = 18, weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Shotgun", ammoMin = 4, ammoMax = 14, weight = 2 },
        },
        bags = {
            { module = "DynamicTradingCommon",  item = "Base.Bag_DuffelBag", weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_NormalHikingBag", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_Schoolbag", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_ALICEpack", weight = 2 },
        },
        bagChance = 0.7,
        rangedChance = {
            shootingThreshold = 7,
            base = 0.12,
            perLevel = 0.04,
            max = 0.45,
        },
    })
end
