require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("RoadWarrior", {
        meleeWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.Crowbar", weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.Nightstick", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.BaseballBat", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Axe", weight = 2 },
        },
        rangedWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.Pistol", ammoMin = 18, ammoMax = 42, weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.Shotgun", ammoMin = 8, ammoMax = 24, weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Revolver", ammoMin = 6, ammoMax = 18, weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.DoubleBarrelShotgun", ammoMin = 8, ammoMax = 24, weight = 2 },
        },
        bags = {
            { module = "DynamicTradingCommon",  item = "Base.Bag_Military", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_ALICEpack", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_BigHikingBag", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_ShotgunDblBag", weight = 2 },
        },
        bagChance = 0.80,
        rangedChance = {
            shootingThreshold = 5,
            base = 0.22,
            perLevel = 0.055,
            max = 0.75,
        },
    })
end
