require "DynamicTrading_Config"

if not DynamicTrading then return end

-- === TOOLS ===
DynamicTrading.AddItem("BuyHammer", {
    item = "Base.Hammer",
    category = "Tool",
    tags = {"Build", "Essential"},
    basePrice = 15,
    stockRange = { min=2, max=5 }
})

DynamicTrading.AddItem("BuySaw", {
    item = "Base.Saw",
    category = "Tool",
    tags = {"Build", "Essential"},
    basePrice = 20,
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyScrewdriver", {
    item = "Base.Screwdriver",
    category = "Tool",
    tags = {"Build", "Electric"},
    basePrice = 8,
    stockRange = { min=3, max=8 }
})

DynamicTrading.AddItem("BuySledgehammer", {
    item = "Base.Sledgehammer",
    category = "Tool",
    tags = {"Build", "Heavy", "Rare"},
    basePrice = 200,
    stockRange = { min=0, max=1 }
})

-- === GARDENING / FARMING ===
DynamicTrading.AddItem("BuyTrowel", {
    item = "Base.HandShovel",
    category = "Gardening",
    tags = {"Crop"},
    basePrice = 12,
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyCarrotSeeds", {
    item = "farming.CarrotBagSeed",
    category = "Gardening",
    tags = {"Crop", "Food"},
    basePrice = 5,
    stockRange = { min=5, max=15 }
})

-- === CAMPING & FIRE ===
DynamicTrading.AddItem("BuyTentKit", {
    item = "camping.CampingTentKit",
    category = "Camping",
    tags = {"Survival"},
    basePrice = 60,
    stockRange = { min=0, max=2 }
})

DynamicTrading.AddItem("BuyLighter", {
    item = "Base.Lighter",
    category = "Fire source",
    tags = {"Survival", "Smoker"},
    basePrice = 4,
    stockRange = { min=5, max=15 }
})