require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("Bandit", {
        meleeWeapons = {
            { item = "Base.BaseballBat", weight = 6 },
            { item = "Base.Crowbar", weight = 5 },
            { item = "Base.HuntingKnife", weight = 4 },
            { item = "Base.Machete", weight = 3 },
            { item = "Base.HandAxe", weight = 3 },
            { item = "Base.Nightstick", weight = 2 },
        },
        rangedWeapons = {
            { item = "Base.Pistol", ammoMin = 6, ammoMax = 24, weight = 5 },
            { item = "Base.Revolver", ammoMin = 6, ammoMax = 18, weight = 3 },
            { item = "Base.Shotgun", ammoMin = 4, ammoMax = 14, weight = 2 },
        },
        bags = {
            { item = "Base.Bag_DuffelBag", weight = 5 },
            { item = "Base.Bag_NormalHikingBag", weight = 4 },
            { item = "Base.Bag_Schoolbag", weight = 3 },
            { item = "Base.Bag_ALICEpack", weight = 2 },
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
