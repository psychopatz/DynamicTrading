require "DynamicTrading_Config"

if not DynamicTrading then return end

-- === BASIC MATERIALS ===
DynamicTrading.AddItem("BuyNailsBox", {
    item = "Base.NailsBox",
    category = "Material",
    tags = {"Build"},
    basePrice = 15,
    stockRange = { min=5, max=20 }
})

DynamicTrading.AddItem("BuyWoodGlue", {
    item = "Base.Woodglue",
    category = "Material",
    tags = {"Build"},
    basePrice = 12,
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyDuctTape", {
    item = "Base.DuctTape",
    category = "Material",
    tags = {"Build", "Repair"},
    basePrice = 12,
    stockRange = { min=3, max=10 }
})

-- === FUEL ===
DynamicTrading.AddItem("BuyPetrolCan", {
    item = "Base.PetrolCan",
    category = "Fuel",
    tags = {"Fuel"}, -- Price spikes when electricity is out (Environment Logic)
    basePrice = 45,
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyPropaneTank", {
    item = "Base.PropaneTank",
    category = "Fuel",
    tags = {"Fuel", "Heavy"},
    basePrice = 60,
    stockRange = { min=1, max=4 }
})

-- === VEHICLE PARTS ===
DynamicTrading.AddItem("BuyCarBattery", {
    item = "Base.CarBattery1",
    category = "Vehicle part",
    tags = {"Car", "Electric", "Heavy"},
    basePrice = 80,
    stockRange = { min=0, max=2 }
})

DynamicTrading.AddItem("BuyWrench", {
    item = "Base.Wrench",
    category = "Tool", -- Often used for vehicles
    tags = {"Car", "Tool"},
    basePrice = 18,
    stockRange = { min=1, max=3 }
})