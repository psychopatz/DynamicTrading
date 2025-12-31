require "DynamicTrading_Config"

if not DynamicTrading then return end


-- ==========================================
-- SKILL BOOKS (XP Multipliers - B42 Updated)
-- Tier I: 250 | Tier II: 500 | Tier III: 1000 | Tier IV: 1800 | Tier V: 3000
-- ==========================================

local skills = {
    {id="Agriculture",   item="BookFarming",       tag="Farmer"},
    {id="Aiming",        item="BookAiming",        tag="Gun"},
    {id="AnimalCare",    item="BookHusbandry",     tag="Farmer"},
    {id="Blacksmithing", item="BookBlacksmith",    tag="Build"},
    {id="Butchering",    item="BookButchering",    tag="Meat"},
    {id="Carpentry",     item="BookCarpentry",     tag="Build"},
    {id="Carving",       item="BookCarving",       tag="Survival"},
    {id="Cooking",       item="BookCooking",       tag="Food"},
    {id="Electrical",    item="BookElectrician",   tag="Electronics"},
    {id="FirstAid",      item="BookFirstAid",      tag="Medical"},
    {id="Fishing",       item="BookFishing",       tag="Survival"},
    {id="Foraging",      item="BookForaging",      tag="Survival"},
    {id="Glassmaking",   item="BookGlassmaking",   tag="Material"},
    {id="Knapping",      item="BookFlintKnapping", tag="Survival"},
    {id="LongBlade",     item="BookLongBlade",     tag="Blade"},
    {id="Maintenance",   item="BookMaintenance",   tag="Tool"},
    {id="Masonry",       item="BookMasonry",       tag="Build"},
    {id="Mechanics",     item="BookMechanic",      tag="Car"},
    {id="Pottery",       item="BookPottery",       tag="Material"},
    {id="Reloading",     item="BookReloading",     tag="Gun"},
    {id="Tailoring",     item="BookTailoring",     tag="Clothing"},
    {id="Tracking",      item="BookTracking",      tag="Survival"},
    {id="Trapping",      item="BookTrapping",      tag="Survival"},
    {id="Welding",       item="BookMetalWelding",  tag="Build"}
}

local tiers = {
    {sfx="1", p=250}, {sfx="2", p=500}, {sfx="3", p=1000}, {sfx="4", p=1800}, {sfx="5", p=3000}
}

for _, s in ipairs(skills) do
    for _, t in ipairs(tiers) do
        DynamicTrading.AddItem("BuyBook"..s.id..t.sfx, {
            item = "Base."..s.item..t.sfx,
            category = "Literature",
            tags = {"Literature", "SkillBook", s.tag},
            basePrice = t.p,
            stockRange = { min=0, max=1 }
        })
    end
end

-- ==========================================
-- RECIPE MAGAZINES (B42 Expanded)
-- ==========================================

-- Standard Crafting Magazines (Smithing, Tailoring, etc.)
local magGroups = {
    {id="SmithingMag", count=11, tag="Build", price=450},
    {id="TailoringMag", count=10, tag="Clothing", price=350},
    {id="ArmorMag", count=7, tag="Armor", price=550},
    {id="FarmingMag", count=9, tag="Farmer", price=300},
    {id="CookingMag", count=6, tag="Food", price=250},
    {id="GlassmakingMag", count=3, tag="Material", price=400},
    {id="MetalworkMag", count=4, tag="Build", price=450},
    {id="HuntingMag", count=4, tag="Survival", price=400},
    {id="ElectronicsMag", count=3, tag="Electronics", price=400} -- 4 is Generator
}

for _, g in ipairs(magGroups) do
    for i=1, g.count do
        DynamicTrading.AddItem("Buy"..g.id..i, {
            item = "Base."..g.id..i,
            category = "Literature",
            tags = {"Literature", "Magazine", g.tag},
            basePrice = g.price,
            stockRange = { min=0, max=1 }
        })
    end
end

-- The "Big Two" Essentials
DynamicTrading.AddItem("BuyGeneratorManual", {
    item = "Base.ElectronicsMag4",
    category = "Literature",
    tags = {"Literature", "Electronics", "Rare"},
    basePrice = 1200,
    stockRange = { min=0, max=1 }
})

DynamicTrading.AddItem("BuyHerbalistMag", {
    item = "Base.HerbalistMag",
    category = "Literature",
    tags = {"Literature", "Survival", "Medical"},
    basePrice = 850,
    stockRange = { min=0, max=1 }
})

-- ==========================================
-- LEISURE (Entertainment & Luxury)
-- ==========================================

-- HottieZ (The high-end stress relief)
DynamicTrading.AddItem("BuyHottieZ", {
    item = "Base.HottieZ_New",
    category = "Literature",
    tags = {"Literature", "Rare"},
    basePrice = 500,
    stockRange = { min=0, max=1 }
})

-- Leatherbound / Fancy Books (Luxury Trade)
local fancy = {"Classic", "ClassicFiction", "History", "Legal", "Medical", "MilitaryHistory", "Occult", "Philosophy", "Politics", "Religion"}
for _, f in ipairs(fancy) do
    DynamicTrading.AddItem("BuyBookFancy"..f, {
        item = "Base.BookFancy_"..f,
        category = "Literature",
        tags = {"Literature", "Luxury"},
        basePrice = 400,
        stockRange = { min=0, max=1 }
    })
end

-- Common Reading
DynamicTrading.AddItem("BuyComicBook", {
    item = "Base.ComicBook",
    category = "Literature",
    tags = {"Literature"},
    basePrice = 100,
    stockRange = { min=1, max=3 }
})

-- ==========================================
-- CARTOGRAPHY (Maps)
-- ==========================================

local regions = {"Map", "WestpointMap", "MuldraughMap", "RiversideMap", "RosewoodMap", "MarchRidgeMap"}
for _, r in ipairs(regions) do
    DynamicTrading.AddItem("BuyMap"..r, {
        item = "Base."..r,
        category = "Literature",
        tags = {"Literature", "Survival"},
        basePrice = 150,
        stockRange = { min=0, max=2 }
    })
end

-- ==========================================
-- WRITABLE (Journals/Notebooks)
-- ==========================================

DynamicTrading.AddItem("BuyJournal", {
    item = "Base.Journal",
    category = "Literature",
    tags = {"Literature", "Survival"},
    basePrice = 250,
    stockRange = { min=1, max=2 }
})

DynamicTrading.AddItem("BuyNotebook", {
    item = "Base.Notebook",
    category = "Literature",
    tags = {"Literature"},
    basePrice = 120,
    stockRange = { min=1, max=3 }
})