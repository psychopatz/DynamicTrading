require "DT/Common/Config"

-- =============================================================================
-- 1. RARITY TIERS
-- =============================================================================
-- We apply these tags to items to control their spawn rate and value globally.

DynamicTrading.RegisterTag("Common", {
        module = "DynamicTradingCommon",
    priceMult = 1.0, 
    weight = 100 -- Very likely to appear in wildcard slots
})

DynamicTrading.RegisterTag("Uncommon", {
        module = "DynamicTradingCommon",
    priceMult = 1.25, -- +25% Price
    weight = 40
})

DynamicTrading.RegisterTag("Rare", {
        module = "DynamicTradingCommon",
    priceMult = 2.0,  -- +100% Price
    weight = 10       -- Rare
})

DynamicTrading.RegisterTag("Legendary", {
        module = "DynamicTradingCommon",
    priceMult = 5.0,  -- 5x Price
    weight = 1        -- Extremely rare (1% chance compared to Common)
})

-- =============================================================================
-- 2. ITEM CATEGORIES
-- =============================================================================

-- BASICS
DynamicTrading.RegisterTag("Food", {
        module = "DynamicTradingCommon", priceMult = 1.0, weight = 80 })
DynamicTrading.RegisterTag("Drink", {
        module = "DynamicTradingCommon", priceMult = 1.0, weight = 80 })
DynamicTrading.RegisterTag("Clothing", {
        module = "DynamicTradingCommon", priceMult = 0.8, weight = 60 })
DynamicTrading.RegisterTag("Literature", {
        module = "DynamicTradingCommon", priceMult = 1.2, weight = 50 }) -- Books are valuable

DynamicTrading.RegisterTag("Resource.Material", {
        module = "DynamicTradingCommon", priceMult = 1.0, weight = 70 }) -- Planks, Nails
DynamicTrading.RegisterTag("Resource.Fishing", {
        module = "DynamicTradingCommon", priceMult = 1.1, weight = 45 }) -- Hooks, line, bait, tackle
DynamicTrading.RegisterTag("Quality.Waste", {
        module = "DynamicTradingCommon", priceMult = 0.5, weight = 100 }) -- Scrap
DynamicTrading.RegisterTag("Resource.Fuel", {
        module = "DynamicTradingCommon", priceMult = 1.5, weight = 20 }) -- Gas is gold

-- SPECIALIZED
DynamicTrading.RegisterTag("Medical", {
        module = "DynamicTradingCommon", priceMult = 1.5, weight = 25 })
DynamicTrading.RegisterTag("Weapon", {
        module = "DynamicTradingCommon", priceMult = 1.3, weight = 15 })
DynamicTrading.RegisterTag("Ammo", {
        module = "DynamicTradingCommon", priceMult = 2.0, weight = 10 })
DynamicTrading.RegisterTag("Tool", {
        module = "DynamicTradingCommon", priceMult = 1.2, weight = 30 })
DynamicTrading.RegisterTag("Tool.Fishing", {
        module = "DynamicTradingCommon", priceMult = 1.25, weight = 20 }) -- Rods, gaffs, angling gear
DynamicTrading.RegisterTag("Seed", {
        module = "DynamicTradingCommon", priceMult = 0.8, weight = 40 })

-- LUXURY / SPECIFIC
DynamicTrading.RegisterTag("Misc.Cosmetic", {
        module = "DynamicTradingCommon", priceMult = 3.0, weight = 5 })  -- High value
DynamicTrading.RegisterTag("Quality.Luxury", {
        module = "DynamicTradingCommon", priceMult = 4.0, weight = 2 })  -- Premium status

-- =============================================================================
-- 3. CONDITIONAL / SEASONAL
-- =============================================================================
-- Weight 0 means they NEVER spawn randomly. 
-- They only appear if an Event (Winter) or specific Trader (Smuggler) injects them.

DynamicTrading.RegisterTag("Winter", {
        module = "DynamicTradingCommon", priceMult = 1.5, weight = 0 }) -- Parkas, Heaters
DynamicTrading.RegisterTag("Harvest", {
        module = "DynamicTradingCommon", priceMult = 0.5, weight = 0 }) -- Cheap crops during harvest
DynamicTrading.RegisterTag("Illegal", {
        module = "DynamicTradingCommon", priceMult = 3.0, weight = 0 }) -- Contraband

