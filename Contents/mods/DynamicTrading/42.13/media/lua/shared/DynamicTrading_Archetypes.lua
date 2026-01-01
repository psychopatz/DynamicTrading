require "DynamicTrading_Config"

-- =============================================================================
-- 1. THE GENERAL STORE
-- =============================================================================
-- The jack-of-all-trades. Good for basics, pays average prices.
DynamicTrading.RegisterArchetype("General", {
    name = "General Trader",
    
    -- Guaranteed Stock (The "Shopping List")
    allocations = {
        ["Food"] = 5,
        ["Drink"] = 3,
        ["Material"] = 4,
        ["Junk"] = 3
    },
    
    -- He has no specific buying preference, so 'wants' is empty.
    wants = {}, 
    
    -- He doesn't sell illegal goods or super rare artifacts.
    forbid = { "Illegal", "Legendary" }
})

-- =============================================================================
-- 2. THE FARMER
-- =============================================================================
-- Sells food cheap. Buys seeds and tools for a premium.
DynamicTrading.RegisterArchetype("Farmer", {
    name = "The Farmer",
    
    allocations = {
        ["Food"] = 8,    -- Lots of food
        ["Seed"] = 4,    -- Seeds
        ["Tool"] = 2     -- Garden tools
    },
    
    wants = {
        ["Seed"] = 1.5,  -- Pays +50% for seeds
        ["Tool"] = 1.2,  -- Pays +20% for tools
        ["Sack"] = 1.5   -- Pays +50% for sacks (Custom tag you might add)
    },
    
    -- Farmers don't sell Guns or Electronics
    forbid = { "Weapon", "Ammo", "Electronics", "Modern" }
})

-- =============================================================================
-- 3. THE BUTCHER / HUNTER
-- =============================================================================
-- Focuses on Meat and Weapons.
DynamicTrading.RegisterArchetype("Butcher", {
    name = "The Butcher",
    
    allocations = {
        ["Meat"] = 6,    -- Needs items tagged "Meat"
        ["Weapon"] = 4,  -- Knives, Axes
        ["Leather"] = 3  -- Animal skins (if you have mods for this)
    },
    
    wants = {
        ["Meat"] = 1.2,     -- Buys raw meat
        ["Weapon"] = 1.25,  -- Buys hunting gear
        ["Ammo"] = 1.1      -- Buys ammo
    },
    
    forbid = { "Vegetable", "Fruit", "Literature" }
})

-- =============================================================================
-- 4. THE DOCTOR
-- =============================================================================
-- High value, low stock volume.
DynamicTrading.RegisterArchetype("Doctor", {
    name = "Field Medic",
    
    allocations = {
        ["Medical"] = 8,
        ["Clean"] = 3    -- Soap, bleach
    },
    
    wants = {
        ["Medical"] = 1.5, -- Pays huge for meds
        ["Alcohol"] = 1.2  -- Alcohol for disinfection
    },
    
    forbid = { "Junk", "Weapon", "Construction" }
})

-- =============================================================================
-- 5. THE MECHANIC
-- =============================================================================
DynamicTrading.RegisterArchetype("Mechanic", {
    name = "The Mechanic",
    
    allocations = {
        ["CarPart"] = 6,
        ["Fuel"] = 4,
        ["Tool"] = 4,
        ["Electronics"] = 2
    },
    
    wants = {
        ["CarPart"] = 1.3,
        ["Fuel"] = 1.2,
        ["ScrapMetal"] = 1.1
    },
    
    forbid = { "Food", "Clothing", "Medical" }
})