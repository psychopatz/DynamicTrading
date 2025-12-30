require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================
-- SKILL BOOKS (XP Multipliers)
-- Balancing: Vol 1 is expensive, Vol 5 is a fortune.
-- ==========================================

local skills = {
    {id="Carpentry", tag="Build", item="BookCarpentry"},
    {id="Cooking", tag="Food", item="BookCooking"},
    {id="Farming", tag="Farmer", item="BookFarming"},
    {id="FirstAid", tag="Medical", item="BookFirstAid"},
    {id="Foraging", tag="Survival", item="BookForaging"},
    {id="Fishing", tag="Survival", item="BookFishing"},
    {id="Trapping", tag="Survival", item="BookTrapping"},
    {id="Mechanics", tag="Mechanic", item="BookMechanic"},
    {id="Metalworking", tag="Build", item="BookMetalWelding"},
    {id="Tailoring", tag="Clothing", item="BookTailoring"},
    {id="Electrical", tag="Electric", item="BookElectric"}
}

local tiers = {
    {suffix="1", label="Beginner", price=150},
    {suffix="2", label="Intermediate", price=220},
    {suffix="3", label="Advanced", price=300},
    {suffix="4", label="Expert", price=400},
    {suffix="5", label="Master", price=600}
}

for _, skill in ipairs(skills) do
    for _, tier in ipairs(tiers) do
        DynamicTrading.AddItem("BuyBook"..skill.id..tier.suffix, {
            item = "Base."..skill.item..tier.suffix,
            category = "Literature",
            tags = {"Literature", "Skill", skill.tag},
            basePrice = tier.price,
            stockRange = { min=0, max=1 } -- Books are unique and rare
        })
    end
end

-- ==========================================
-- ESSENTIAL RECIPE MAGAZINES (Gatekeepers)
-- ==========================================

-- The Herbalist: Life-saving for foraging and treating poison.
DynamicTrading.AddItem("BuyHerbalistMag", {
    item = "Base.HerbalistMag",
    category = "Literature",
    tags = {"Literature", "Survival", "Medical", "Rare"},
    basePrice = 450,
    stockRange = { min=0, max=1 }
})

-- How to Use Generators: Requirement for electricity.
DynamicTrading.AddItem("BuyGeneratorManual", {
    item = "Base.ElectronicsMag4",
    category = "Literature",
    tags = {"Literature", "Electric", "Rare"},
    basePrice = 500,
    stockRange = { min=0, max=1 }
})

-- Mechanics Magazines: Required to repair specific car types.
DynamicTrading.AddItem("BuyMechanicMagStandard", {
    item = "Base.MechanicMag1",
    category = "Literature",
    tags = {"Literature", "Mechanic", "Car"},
    basePrice = 180,
    stockRange = { min=0, max=2 }
})

DynamicTrading.AddItem("BuyMechanicMagCommercial", {
    item = "Base.MechanicMag2",
    category = "Literature",
    tags = {"Literature", "Mechanic", "Car"},
    basePrice = 200,
    stockRange = { min=0, max=1 }
})

DynamicTrading.AddItem("BuyMechanicMagPerformance", {
    item = "Base.MechanicMag3",
    category = "Literature",
    tags = {"Literature", "Mechanic", "Car", "Rare"},
    basePrice = 350,
    stockRange = { min=0, max=1 }
})

-- ==========================================
-- CRAFTING MAGAZINES (Recipes)
-- ==========================================

-- Metalworking Magazines
for i=1, 4 do
    DynamicTrading.AddItem("BuyMetalMag"..i, {
        item = "Base.MetalworkMag"..i,
        category = "Literature",
        tags = {"Literature", "Build"},
        basePrice = 120,
        stockRange = { min=0, max=1 }
    })
end

-- Electronics Magazines (Scrap/Sensors/Remotes)
for i=1, 3 do -- excluding 4 which is the generator
    DynamicTrading.AddItem("BuyElectricMag"..i, {
        item = "Base.ElectronicsMag"..i,
        category = "Literature",
        tags = {"Literature", "Electric"},
        basePrice = 100,
        stockRange = { min=0, max=1 }
    })
end

-- Wilderness Survival (Traps/Fishing gear)
for i=1, 5 do
    DynamicTrading.AddItem("BuySurvivalMag"..i, {
        item = "Base.HuntingMag"..i,
        category = "Literature",
        tags = {"Literature", "Survival"},
        basePrice = 110,
        stockRange = { min=0, max=1 }
    })
end

-- ==========================================
-- ENTERTAINMENT & STRESS RELIEF
-- ==========================================

DynamicTrading.AddItem("BuyComicBook", {
    item = "Base.ComicBook",
    category = "Literature",
    tags = {"Literature", "Junk"},
    basePrice = 45,
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyHottieZ", {
    item = "Base.Hynes", -- Internal name for HottieZ
    category = "Literature",
    tags = {"Literature", "Rare"},
    basePrice = 150, -- High value for heavy stress reduction
    stockRange = { min=0, max=1 }
})

DynamicTrading.AddItem("BuyNewspaper", {
    item = "Base.Newspaper",
    category = "Literature",
    tags = {"Literature", "Junk"},
    basePrice = 15,
    stockRange = { min=1, max=5 }
})

DynamicTrading.AddItem("BuyMagazine", {
    item = "Base.Magazine",
    category = "Literature",
    tags = {"Literature", "Junk"},
    basePrice = 20,
    stockRange = { min=2, max=6 }
})