require "DynamicTrading_Config"

if not DynamicTrading then return end

DynamicTrading.AddItem("BuyBattery", {
    item = "Base.Battery",
    category = "Electronics",
    tags = {"Electric", "Fuel"}, -- 'Fuel' tag might trigger price hike if power is out
    basePrice = 10,
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyRadio", {
    item = "radio.RadioRed",
    category = "Communication",
    tags = {"Electric"},
    basePrice = 25,
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyWalkieTalkie", {
    item = "radio.WalkieTalkie4",
    category = "Communication",
    tags = {"Electric", "Military"},
    basePrice = 50,
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyGenerator", {
    item = "Base.Generator",
    category = "Electronics",
    tags = {"Electric", "Heavy", "Rare", "Fuel"},
    basePrice = 500,
    stockRange = { min=0, max=1 }
})

DynamicTrading.AddItem("BuyDigitalWatch", {
    item = "Base.Watch_DigitalBlack",
    category = "Electronics",
    tags = {"Electric"},
    basePrice = 10,
    stockRange = { min=2, max=5 }
})