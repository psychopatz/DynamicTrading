require "DynamicTrading_Config"

-- =============================================================================
-- 1. THE GENERAL STORE
-- =============================================================================
-- The General store buys everything at standard market rates.
DynamicTrading.RegisterArchetype("General", {
    name = "General Trader",
    
    allocations = {
        ["Food"] = 5,
        ["Drink"] = 3,
        ["Material"] = 4,
        ["Junk"] = 3
    },
    
    wants = {}, -- No special preferences
    forbid = { "Illegal", "Legendary" }
})

-- =============================================================================
-- 2. THE FARMER (Supply Chain: Needs Tools -> Makes Food)
-- =============================================================================
DynamicTrading.RegisterArchetype("Farmer", {
    name = "The Farmer",
    
    allocations = {
        ["Food"] = 6,     -- Sells Crops
        ["Seed"] = 6,     -- Sells Seeds
        ["Vegetable"] = 4
    },
    
    -- He HAS food. He NEEDS gear to run the farm.
    wants = {
        ["Tool"] = 1.3,   -- Pays +30% for Shovels/Trowels
        ["Water"] = 1.2,  -- Pays +20% for Water containers
        ["Sack"] = 1.5    -- Pays +50% for Empty Sacks (if tagged)
    },
    
    forbid = { "Weapon", "Ammo", "Electronics", "Modern" }
})

-- =============================================================================
-- 3. THE BUTCHER (Supply Chain: Needs Ammo/Knives -> Makes Meat)
-- =============================================================================
DynamicTrading.RegisterArchetype("Butcher", {
    name = "The Butcher",
    
    allocations = {
        ["Meat"] = 8,      -- Sells Meat
        ["Bag"] = 2        -- Sells storage
    },
    
    -- He HAS meat. He NEEDS ways to kill animals.
    wants = {
        ["Ammo"] = 1.4,    -- Pays +40% for Ammo (High Demand)
        ["Blade"] = 1.3,   -- Pays +30% for Knives (Tools of the trade)
        ["Weapon"] = 1.2   -- Pays +20% for Hunting Rifles
    },
    
    forbid = { "Vegetable", "Fruit", "Literature" }
})

-- =============================================================================
-- 4. THE DOCTOR (Supply Chain: Needs Hygiene -> Provides Healing)
-- =============================================================================
DynamicTrading.RegisterArchetype("Doctor", {
    name = "Field Medic",
    
    allocations = {
        ["Medical"] = 10,  -- Sells Meds
        ["Literature"] = 2 -- First Aid Books
    },
    
    -- He HAS pills. He NEEDS a sterile environment.
    wants = {
        ["Clean"] = 1.5,   -- Pays +50% for Soap/Bleach (Vital for him)
        ["Alcohol"] = 1.3, -- Pays +30% for disinfectants
        ["Luxury"] = 1.2   -- Pays extra for Chocolate/Comfort items for patients
    },
    
    forbid = { "Junk", "Weapon", "Construction", "CarPart" }
})

-- =============================================================================
-- 5. THE MECHANIC (Supply Chain: Needs Scrap/Electronics -> Fixes Cars)
-- =============================================================================
DynamicTrading.RegisterArchetype("Mechanic", {
    name = "The Mechanic",
    
    allocations = {
        ["CarPart"] = 8,   -- Sells Car Parts
        ["Fuel"] = 4,
        ["Tool"] = 4
    },
    
    -- He HAS parts. He NEEDS materials to refurbish them.
    wants = {
        ["Electronics"] = 1.3, -- Pays +30% for circuit boards
        ["Material"] = 1.2,    -- Pays +20% for Scrap Metal/Wire
        ["Food"] = 1.2         -- He's hungry working on cars all day
    },
    
    forbid = { "Clothing", "Medical", "Seed" }
})