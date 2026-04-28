require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("Survivalist", {
        meleeWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.HuntingKnife", weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.Axe", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Crowbar", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.WoodAxe", weight = 2 },
            { module = "DynamicTradingCommon",  item = "Base.BaseballBat", weight = 2 },
        },
        rangedWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.VarmintRifle", ammoMin = 10, ammoMax = 30, weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.HuntingRifle", ammoMin = 6, ammoMax = 18, weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.DoubleBarrelShotgun", ammoMin = 8, ammoMax = 24, weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Pistol", ammoMin = 12, ammoMax = 30, weight = 2 },
        },
        bags = {
            { module = "DynamicTradingCommon",  item = "Base.Bag_SurvivorBag", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_NormalHikingBag", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_ALICEpack", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_LeatherWaterBag", weight = 2 },
        },
        bagChance = 0.80,
        rangedChance = {
            shootingThreshold = 7,
            base = 0.10,
            perLevel = 0.055,
            max = 0.55,
        },
    })
end
