require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("Gunrunner", {
        meleeWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.Nightstick", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Crowbar", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.HuntingKnife", weight = 2 },
            { module = "DynamicTradingCommon",  item = "Base.BaseballBat", weight = 1 },
        },
        rangedWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.Pistol", ammoMin = 18, ammoMax = 48, weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Pistol2", ammoMin = 12, ammoMax = 36, weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.Revolver_Long", ammoMin = 6, ammoMax = 18, weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Shotgun", ammoMin = 10, ammoMax = 30, weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.VarmintRifle", ammoMin = 10, ammoMax = 30, weight = 2 },
        },
        bags = {
            { module = "DynamicTradingCommon",  item = "Base.Bag_ALICEpack_Army", weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_Police", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_ShotgunCaseCloth", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_RifleCaseCloth", weight = 3 },
        },
        bagChance = 0.90,
        rangedChance = {
            shootingThreshold = 4,
            base = 0.45,
            perLevel = 0.05,
            max = 0.95,
        },
    })
end
