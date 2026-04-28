require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeEquipment then
    DynamicTrading.RegisterArchetypeEquipment("Sheriff", {
        meleeWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.Nightstick", weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Crowbar", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Hammer", weight = 2 },
            { module = "DynamicTradingCommon",  item = "Base.HuntingKnife", weight = 1 },
        },
        rangedWeapons = {
            { module = "DynamicTradingCommon",  item = "Base.Pistol", ammoMin = 18, ammoMax = 42, weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Revolver", ammoMin = 12, ammoMax = 30, weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Shotgun", ammoMin = 8, ammoMax = 24, weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Pistol2", ammoMin = 12, ammoMax = 30, weight = 2 },
        },
        bags = {
            { module = "DynamicTradingCommon",  item = "Base.Bag_Sheriff", weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_Police", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_SWAT", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_Schoolbag_Medical", weight = 1 },
        },
        bagChance = 0.85,
        rangedChance = {
            shootingThreshold = 5,
            base = 0.30,
            perLevel = 0.06,
            max = 0.85,
        },
    })
end
