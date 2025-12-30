require "DynamicTrading_Config"

if not DynamicTrading then return end
-- ==========================================
-- BANDAGES & DRESSINGS (Heal Tag)
-- ==========================================

-- Adhesive Bandage: Single-use, very common for small scratches.
DynamicTrading.AddItem("BuyBandAid", {
    item = "Base.BandAid",
    category = "Medical",
    tags = {"Medical", "Heal"},
    basePrice = 8,
    stockRange = { min=5, max=15 }
})

-- Sterile Bandage: The best standard dressing. Prevents infection.
DynamicTrading.AddItem("BuyBandageSterile", {
    item = "Base.Bandage",
    category = "Medical",
    tags = {"Medical", "Heal", "Clean"},
    basePrice = 20,
    stockRange = { min=3, max=10 }
})

-- Cotton Balls: Used with disinfectant or for minor bleeding.
DynamicTrading.AddItem("BuyCottonBalls", {
    item = "Base.CottonBalls",
    category = "Medical",
    tags = {"Medical", "Clean"},
    basePrice = 5,
    stockRange = { min=5, max=15 }
})

-- ==========================================
-- DISINFECTANTS & CLEANING (Clean Tag)
-- ==========================================

-- Bottle of Disinfectant: Multi-use, critical for preventing wound infections.
DynamicTrading.AddItem("BuyDisinfectant", {
    item = "Base.Disinfectant",
    category = "Medical",
    tags = {"Medical", "Clean"},
    basePrice = 45,
    stockRange = { min=1, max=4 }
})

-- Alcohol Wipes: Single-use disinfectant, very portable.
DynamicTrading.AddItem("BuyAlcoholWipes", {
    item = "Base.AlcoholWipes",
    category = "Medical",
    tags = {"Medical", "Clean"},
    basePrice = 12,
    stockRange = { min=4, max=12 }
})

-- ==========================================
-- MEDICATIONS & PILLS
-- ==========================================

-- Antibiotics: Rare and life-saving. Cures wound infections.
DynamicTrading.AddItem("BuyAntibiotics", {
    item = "Base.Antibiotics",
    category = "Medical",
    tags = {"Medical", "Rare"},
    basePrice = 120,
    stockRange = { min=0, max=2 }
})

-- Painkillers: Essential for sleeping or performing actions while injured.
DynamicTrading.AddItem("BuyPainkillers", {
    item = "Base.Painkillers",
    category = "Medical",
    tags = {"Medical"},
    basePrice = 30,
    stockRange = { min=2, max=6 }
})

-- Beta Blockers: Reduces panic. Crucial for combat/firearms.
DynamicTrading.AddItem("BuyBetaBlockers", {
    item = "Base.BeerBlockers", -- Item name in game files is often BeerBlockers (legacy typo)
    item = "Base.BetaBlockers", 
    category = "Medical",
    tags = {"Medical", "Gun"},
    basePrice = 35,
    stockRange = { min=1, max=5 }
})

-- Antidepressants: Long-term mood management.
DynamicTrading.AddItem("BuyAntidepressants", {
    item = "Base.Antidepressants",
    category = "Medical",
    tags = {"Medical"},
    basePrice = 40,
    stockRange = { min=1, max=4 }
})

-- Sleeping Tablets: Forces sleep; useful for pain or night-skipping.
DynamicTrading.AddItem("BuySleepingTablets", {
    item = "Base.SleepingTablets",
    category = "Medical",
    tags = {"Medical"},
    basePrice = 25,
    stockRange = { min=1, max=4 }
})

-- Vitamins: Reduces fatigue slightly.
DynamicTrading.AddItem("BuyVitamins", {
    item = "Base.Vitamins",
    category = "Medical",
    tags = {"Medical", "Food"},
    basePrice = 15,
    stockRange = { min=2, max=8 }
})

-- ==========================================
-- SURGICAL TOOLS (Heal Tag)
-- ==========================================

-- Suture Needle: Required for stitching deep wounds.
DynamicTrading.AddItem("BuySutureNeedle", {
    item = "Base.SutureNeedle",
    category = "Medical",
    tags = {"Medical", "Heal"},
    basePrice = 40,
    stockRange = { min=1, max=5 }
})

-- Suture Needle Holder: Increases success rate/speed of stitching.
DynamicTrading.AddItem("BuySutureNeedleHolder", {
    item = "Base.SutureNeedleHolder",
    category = "Medical",
    tags = {"Medical", "Heal"},
    basePrice = 55,
    stockRange = { min=0, max=2 }
})

-- Tweezers: Required to remove glass or bullets.
DynamicTrading.AddItem("BuyTweezers", {
    item = "Base.Tweezers",
    category = "Medical",
    tags = {"Medical", "Heal"},
    basePrice = 30,
    stockRange = { min=1, max=3 }
})

-- ==========================================
-- SPECIALTY MEDICAL
-- ==========================================

-- First Aid Kit: A container for organization.
DynamicTrading.AddItem("BuyFirstAidKit", {
    item = "Base.FirstAidKit",
    category = "Medical",
    tags = {"Medical", "Heal"},
    basePrice = 60,
    stockRange = { min=0, max=2 }
})

-- Cold Pack: Reduces swelling and pain.
DynamicTrading.AddItem("BuyColdPack", {
    item = "Base.ColdPack",
    category = "Medical",
    tags = {"Medical", "Heal"},
    basePrice = 20,
    stockRange = { min=1, max=4 }
})

-- Splint: Pre-made splint for broken limbs.
DynamicTrading.AddItem("BuySplint", {
    item = "Base.Splint",
    category = "Medical",
    tags = {"Medical", "Heal"},
    basePrice = 25,
    stockRange = { min=1, max=3 }
})