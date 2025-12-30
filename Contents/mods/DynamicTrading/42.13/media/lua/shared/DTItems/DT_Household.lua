require "DynamicTrading_Config"

if not DynamicTrading then return end

-- === LITERATURE ===
DynamicTrading.AddItem("BuyCarpentryBook1", {
    item = "Base.BookCarpentry1",
    category = "Literature",
    tags = {"Skill"},
    basePrice = 30,
    stockRange = { min=0, max=1 }
})

DynamicTrading.AddItem("BuyCookingMag", {
    item = "Base.CookingMag1",
    category = "Literature",
    tags = {"Skill"},
    basePrice = 10,
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyComicBook", {
    item = "Base.ComicBook",
    category = "Entertainment",
    tags = {"Fun"},
    basePrice = 3,
    stockRange = { min=2, max=6 }
})

-- === HOUSEHOLD ===
DynamicTrading.AddItem("BuyCookingPot", {
    item = "Base.Pot",
    category = "Household",
    tags = {"Water", "Cook"},
    basePrice = 15,
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuySoap", {
    item = "Base.Soap",
    category = "Household",
    tags = {"Clean"},
    basePrice = 8,
    stockRange = { min=2, max=10 }
})

DynamicTrading.AddItem("BuyWaterBottle", {
    item = "Base.WaterBottleFull",
    category = "Fluid container",
    tags = {"Water"}, -- Price spikes during Water Shutoff
    basePrice = 8,
    stockRange = { min=5, max=20 }
})if not DynamicTrading then return end

-- === LITERATURE ===
DynamicTrading.AddItem("BuyCarpentryBook1", {
    item = "Base.BookCarpentry1",
    category = "Literature",
    tags = {"Skill"},
    basePrice = 30,
    stockRange = { min=0, max=1 }
})

DynamicTrading.AddItem("BuyCookingMag", {
    item = "Base.CookingMag1",
    category = "Literature",
    tags = {"Skill"},
    basePrice = 10,
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyComicBook", {
    item = "Base.ComicBook",
    category = "Entertainment",
    tags = {"Fun"},
    basePrice = 3,
    stockRange = { min=2, max=6 }
})

-- === HOUSEHOLD ===
DynamicTrading.AddItem("BuyCookingPot", {
    item = "Base.Pot",
    category = "Household",
    tags = {"Water", "Cook"},
    basePrice = 15,
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuySoap", {
    item = "Base.Soap",
    category = "Household",
    tags = {"Clean"},
    basePrice = 8,
    stockRange = { min=2, max=10 }
})

DynamicTrading.AddItem("BuyWaterBottle", {
    item = "Base.WaterBottleFull",
    category = "Fluid container",
    tags = {"Water"}, -- Price spikes during Water Shutoff
    basePrice = 8,
    stockRange = { min=5, max=20 }
})