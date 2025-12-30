require "DynamicTrading_Config"

if not DynamicTrading then return end

DynamicTrading.AddItem("BuyScrapMetal", {
    item = "Base.ScrapMetal",
    category = "Material",
    tags = {"Metal"},
    basePrice = 5,
    stockRange = { min=5, max=20 }
})

DynamicTrading.AddItem("BuyRubberDuck", {
    item = "Base.RubberDuck",
    category = "Junk",
    tags = {"Toy"},
    basePrice = 2,
    stockRange = { min=1, max=1 }
})