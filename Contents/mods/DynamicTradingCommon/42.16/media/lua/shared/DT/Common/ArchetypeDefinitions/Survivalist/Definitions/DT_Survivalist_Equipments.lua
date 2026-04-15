require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("Survivalist", {
        meleeWeapons = {
            { item = "Base.HuntingKnife", weight = 5 },
            { item = "Base.Axe", weight = 4 },
            { item = "Base.Crowbar", weight = 3 },
            { item = "Base.WoodAxe", weight = 2 },
            { item = "Base.BaseballBat", weight = 2 },
        },
        rangedWeapons = {
            { item = "Base.VarmintRifle", ammoMin = 10, ammoMax = 30, weight = 4 },
            { item = "Base.HuntingRifle", ammoMin = 6, ammoMax = 18, weight = 3 },
            { item = "Base.DoubleBarrelShotgun", ammoMin = 8, ammoMax = 24, weight = 3 },
            { item = "Base.Pistol", ammoMin = 12, ammoMax = 30, weight = 2 },
        },
        bags = {
            { item = "Base.Bag_SurvivorBag", weight = 4 },
            { item = "Base.Bag_NormalHikingBag", weight = 4 },
            { item = "Base.Bag_ALICEpack", weight = 3 },
            { item = "Base.Bag_LeatherWaterBag", weight = 2 },
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
