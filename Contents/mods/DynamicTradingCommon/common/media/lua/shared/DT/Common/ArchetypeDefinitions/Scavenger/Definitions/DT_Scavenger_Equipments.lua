require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("Scavenger", {
        meleeWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.Crowbar", weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.LeadPipe", weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.PipeWrench", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Hammer", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.BaseballBat", weight = 2 },
        },
        rangedWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.Pistol", ammoMin = 8, ammoMax = 24, weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.Revolver", ammoMin = 6, ammoMax = 18, weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.DoubleBarrelShotgun", ammoMin = 4, ammoMax = 16, weight = 1 },
        },
        bags = {
            { module = "DynamicTradingCommon",  item = "Base.Bag_BurglarBag", weight = 5 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_SheetSlingBag", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_Schoolbag_Patches", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_TarpSlingBag", weight = 2 },
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
