require "DynamicTrading_Config"

-- =============================================================================
-- 1. RARITY TIERS
-- =============================================================================
-- We apply these tags to items to control their spawn rate and value globally.

DynamicTrading.RegisterTag("Common", {
    priceMult = 1.0, 
    weight = 100 -- Very likely to appear in wildcard slots
})

DynamicTrading.RegisterTag("Uncommon", {
    priceMult = 1.25, -- +25% Price
    weight = 40
})

DynamicTrading.RegisterTag("Rare", {
    priceMult = 2.0,  -- +100% Price
    weight = 10       -- Rare
})

DynamicTrading.RegisterTag("Legendary", {
    priceMult = 5.0,  -- 5x Price
    weight = 1        -- Extremely rare (1% chance compared to Common)
})

-- =============================================================================
-- 2. ITEM CATEGORIES
-- =============================================================================

-- BASICS
DynamicTrading.RegisterTag("Food",      { priceMult = 1.0, weight = 80 })
DynamicTrading.RegisterTag("Drink",     { priceMult = 1.0, weight = 80 })
DynamicTrading.RegisterTag("Clothing",  { priceMult = 0.8, weight = 60 })
DynamicTrading.RegisterTag("Literature",{ priceMult = 1.2, weight = 50 }) -- Books are valuable

-- RESOURCES
DynamicTrading.RegisterTag("Material",  { priceMult = 1.0, weight = 70 }) -- Planks, Nails
DynamicTrading.RegisterTag("Junk",      { priceMult = 0.5, weight = 100 }) -- Scrap
DynamicTrading.RegisterTag("Fuel",      { priceMult = 1.5, weight = 20 }) -- Gas is gold

-- SPECIALIZED
DynamicTrading.RegisterTag("Medical",   { priceMult = 1.5, weight = 25 })
DynamicTrading.RegisterTag("Weapon",    { priceMult = 1.3, weight = 15 })
DynamicTrading.RegisterTag("Ammo",      { priceMult = 2.0, weight = 10 })
DynamicTrading.RegisterTag("Tool",      { priceMult = 1.2, weight = 30 })
DynamicTrading.RegisterTag("Seed",      { priceMult = 0.8, weight = 40 })

-- LUXURY / SPECIFIC
DynamicTrading.RegisterTag("Jewelry",   { priceMult = 3.0, weight = 5 })  -- High value
DynamicTrading.RegisterTag("Electronics",{ priceMult = 1.4, weight = 20 })

-- =============================================================================
-- 3. CONDITIONAL / SEASONAL
-- =============================================================================
-- Weight 0 means they NEVER spawn randomly. 
-- They only appear if an Event (Winter) or specific Trader (Smuggler) injects them.

DynamicTrading.RegisterTag("Winter",    { priceMult = 1.5, weight = 0 }) -- Parkas, Heaters
DynamicTrading.RegisterTag("Harvest",   { priceMult = 0.5, weight = 0 }) -- Cheap crops during harvest
DynamicTrading.RegisterTag("Illegal",   { priceMult = 3.0, weight = 0 }) -- Contraband