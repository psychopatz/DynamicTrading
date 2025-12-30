require "DynamicTrading_Config"

if not DynamicTrading then return end

-- === BAGS (High Demand) ===
DynamicTrading.AddItem("BuySchoolBag", {
    item = "Base.Bag_Schoolbag",
    category = "Container",
    tags = {"Gear"},
    basePrice = 250,
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyDuffelBag", {
    item = "Base.Bag_DuffelBag",
    category = "Container",
    tags = {"Gear"},
    basePrice = 500,
    stockRange = { min=1, max=2 }
})

DynamicTrading.AddItem("BuyBigHikingBag", {
    item = "Base.Bag_BigHikingBag",
    category = "Container",
    tags = {"Gear", "Rare"},
    basePrice = 800,
    stockRange = { min=0, max=1 }
})

-- === CLOTHING ===
DynamicTrading.AddItem("BuyLeatherJacket", {
    item = "Base.JacketLong_Random",
    category = "Clothing",
    tags = {"Warm", "Armor"},
    basePrice = 40,
    stockRange = { min=1, max=2 }
})

DynamicTrading.AddItem("BuyMilitaryBoots", {
    item = "Base.Shoes_ArmyBoots",
    category = "Clothing",
    tags = {"Armor"},
    basePrice = 350,
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyWinterHat", {
    item = "Base.Hat_Beanie",
    category = "Clothing",
    tags = {"Warm"}, -- Tag 'Warm' could increase price in Winter
    basePrice = 10,
    stockRange = { min=2, max=5 }
})

DynamicTrading.AddItem("BuyPoncho", {
    item = "Base.PonchoYellow",
    category = "Clothing",
    tags = {"Rain"},
    basePrice = 15,
    stockRange = { min=1, max=3 }
})