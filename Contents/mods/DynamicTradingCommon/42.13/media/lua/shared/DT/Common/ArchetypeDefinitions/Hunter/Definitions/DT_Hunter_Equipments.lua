require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("Hunter", {
        meleeWeapons = {
            { item = "Base.HuntingKnife", weight = 6 },
            { item = "Base.Axe", weight = 3 },
            { item = "Base.Crowbar", weight = 2 },
            { item = "Base.Nightstick", weight = 1 },
        },
        rangedWeapons = {
            { item = "Base.HuntingRifle", ammoMin = 8, ammoMax = 24, weight = 5 },
            { item = "Base.VarmintRifle", ammoMin = 12, ammoMax = 36, weight = 4 },
            { item = "Base.DoubleBarrelShotgun", ammoMin = 10, ammoMax = 26, weight = 3 },
            { item = "Base.Pistol", ammoMin = 12, ammoMax = 30, weight = 2 },
        },
        bags = {
            { item = "Base.Bag_ALICEpack", weight = 4 },
            { item = "Base.Bag_NormalHikingBag", weight = 4 },
            { item = "Base.Bag_SurvivorBag", weight = 3 },
            { item = "Base.Bag_RifleCaseClothCamo", weight = 2 },
        },
        bagChance = 0.85,
        rangedChance = {
            shootingThreshold = 6,
            base = 0.25,
            perLevel = 0.055,
            max = 0.80,
        },
    })
end
