require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("Scavenger", {
        meleeWeapons = {
            { item = "Base.Crowbar", weight = 6 },
            { item = "Base.LeadPipe", weight = 5 },
            { item = "Base.PipeWrench", weight = 4 },
            { item = "Base.Hammer", weight = 3 },
            { item = "Base.BaseballBat", weight = 2 },
        },
        rangedWeapons = {
            { item = "Base.Pistol", ammoMin = 8, ammoMax = 24, weight = 5 },
            { item = "Base.Revolver", ammoMin = 6, ammoMax = 18, weight = 3 },
            { item = "Base.DoubleBarrelShotgun", ammoMin = 4, ammoMax = 16, weight = 1 },
        },
        bags = {
            { item = "Base.Bag_BurglarBag", weight = 5 },
            { item = "Base.Bag_SheetSlingBag", weight = 4 },
            { item = "Base.Bag_Schoolbag_Patches", weight = 3 },
            { item = "Base.Bag_TarpSlingBag", weight = 2 },
        },
        bagChance = 0.65,
        rangedChance = {
            shootingThreshold = 9,
            base = 0.02,
            perLevel = 0.05,
            max = 0.30,
        },
    })
end
