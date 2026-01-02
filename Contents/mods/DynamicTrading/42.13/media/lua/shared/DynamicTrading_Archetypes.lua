require "DynamicTrading_Config"

if not DynamicTrading then return end

-- =============================================================================
-- GROUP A: THE ESSENTIALS (Core Services)
-- =============================================================================

-- 1. THE GENERAL STORE (Jack of all trades)
DynamicTrading.RegisterArchetype("General", {
    name = "General Trader",
    allocations = {
        ["Food"] = 4,
        ["Drink"] = 3,
        ["Material"] = 3,
        ["Junk"] = 4,
        ["Clothing"] = 2
    },
    wants = {
        ["Luxury"] = 1.1 -- Pays a little extra for valuables
    }, 
    forbid = { "Illegal", "Legendary" }
})

-- 2. THE FARMER (Food Producer)
DynamicTrading.RegisterArchetype("Farmer", {
    name = "Farmer",
    allocations = {
        ["Vegetable"] = 6,
        ["Seed"] = 6,
        ["Sack"] = 3
    },
    wants = {
        ["Tool"] = 1.3,   -- Shovels/Trowels
        ["Water"] = 1.2,  -- Irrigation
        ["Fuel"] = 1.2    -- For tractors/generators
    },
    forbid = { "Weapon", "Ammo", "Electronics" }
})

-- 3. THE BUTCHER (Meat Source)
DynamicTrading.RegisterArchetype("Butcher", {
    name = "Butcher",
    allocations = {
        ["Meat"] = 8,
        ["Bag"] = 2 -- Leather sacks
    },
    wants = {
        ["Ammo"] = 1.4,    -- Needs to hunt
        ["Blade"] = 1.3,   -- Knives for processing
        ["Spice"] = 1.2    -- Salt for curing meat
    },
    forbid = { "Vegetable", "Fruit", "Literature" }
})

-- 4. THE DOCTOR (Medic)
DynamicTrading.RegisterArchetype("Doctor", {
    name = "Field Medic",
    allocations = {
        ["Medical"] = 10,
        ["Literature"] = 2 -- First Aid Books
    },
    wants = {
        ["Clean"] = 1.5,   -- Soap/Bleach is vital
        ["Alcohol"] = 1.3, -- Disinfectant
        ["Luxury"] = 1.2   -- Chocolate for patients
    },
    forbid = { "Junk", "Construction", "CarPart" }
})

-- 5. THE MECHANIC (Vehicle Expert)
DynamicTrading.RegisterArchetype("Mechanic", {
    name = "Mechanic",
    allocations = {
        ["CarPart"] = 8,
        ["Fuel"] = 3,
        ["Tool"] = 4
    },
    wants = {
        ["Electronics"] = 1.3, -- Engine sensors/parts
        ["Junk"] = 1.1,        -- Scrap metal
        ["Drink"] = 1.2        -- Beer
    },
    forbid = { "Clothing", "Medical", "Seed" }
})

-- =============================================================================
-- GROUP B: THE SURVIVORS (Hardened Types)
-- =============================================================================

-- 6. THE SURVIVALIST (The Prepper)
DynamicTrading.RegisterArchetype("Survivalist", {
    name = "Prepper",
    allocations = {
        ["Canned"] = 6,
        ["Ammo"] = 4,
        ["CarPart"] = 2 -- Batteries
    },
    wants = {
        ["Weapon"] = 1.3,
        ["Fuel"] = 1.5,
        ["Electronics"] = 1.2
    },
    forbid = { "Fresh", "Luxury", "Toy" } -- "Useless" items
})

-- 7. THE GUNRUNNER (Arms Dealer)
DynamicTrading.RegisterArchetype("Gunrunner", {
    name = "Gunrunner",
    allocations = {
        ["Firearm"] = 5,
        ["Ammo"] = 8,
        ["Blade"] = 3
    },
    wants = {
        ["Armor"] = 1.5,   -- Vests/Protection
        ["Medical"] = 1.3, -- Bandages for wounds
        ["Canned"] = 1.1   -- Easy food
    },
    forbid = { "Tool", "Seed", "Literature" }
})

-- 8. THE CONSTRUCTION FOREMAN (Builder)
DynamicTrading.RegisterArchetype("Foreman", {
    name = "Site Foreman",
    allocations = {
        ["Material"] = 8, -- Planks/Nails
        ["Metalwork"] = 4
    },
    wants = {
        ["Tool"] = 1.4,    -- Axes/Sledges
        ["Alcohol"] = 1.2, -- For the crew
        ["Food"] = 1.2     -- High Calorie
    },
    forbid = { "Literature", "Seed", "Jewelry" }
})

-- 9. THE SCAVENGER (Junk Lord)
DynamicTrading.RegisterArchetype("Scavenger", {
    name = "Scavenger",
    allocations = {
        ["Junk"] = 10,
        ["Material"] = 3,
        ["Clothing"] = 3,
        ["Tool"] = 2
    },
    wants = {
        ["Bag"] = 1.5,    -- Needs inventory space
        ["Water"] = 1.2,
        ["Food"] = 1.2
    },
    forbid = {} -- He buys EVERYTHING, but usually at base price (no bonuses)
})

-- =============================================================================
-- GROUP C: THE SPECIALISTS (Skilled Trades)
-- =============================================================================

-- 10. THE TAILOR (Clothier)
DynamicTrading.RegisterArchetype("Tailor", {
    name = "Tailor",
    allocations = {
        ["Clothing"] = 8,
        ["Armor"] = 3,
        ["Bag"] = 3
    },
    wants = {
        ["Fabric"] = 1.5,  -- Thread/Scissors/Needles
        ["Blade"] = 1.2,   -- Scissors
        ["Literature"] = 1.3 -- Tailoring Books
    },
    forbid = { "Fuel", "CarPart", "HeavyTool" }
})

-- 11. THE ELECTRICIAN (Techie)
DynamicTrading.RegisterArchetype("Electrician", {
    name = "Electrician",
    allocations = {
        ["Electronics"] = 8,
        ["Communication"] = 4,
        ["LightSource"] = 3
    },
    wants = {
        ["Tool"] = 1.3, -- Screwdrivers
        ["Junk"] = 1.1, -- Scrap Electronics
        ["Literature"] = 1.4 -- Engineering Books
    },
    forbid = { "Fresh", "Clothing" }
})

-- 12. THE WELDER (Metalworker)
DynamicTrading.RegisterArchetype("Welder", {
    name = "Metalworker",
    allocations = {
        ["Metalwork"] = 8,
        ["Tool"] = 4 -- Torches/Masks
    },
    wants = {
        ["Fuel"] = 2.0, -- Propane (Critical Need)
        ["Electronics"] = 1.2,
        ["HeavyTool"] = 1.3 -- Sledgehammers
    },
    forbid = { "Seed", "Soft" } -- Hates flammable fabric
})

-- 13. THE CHEF (Cook)
DynamicTrading.RegisterArchetype("Chef", {
    name = "Chef",
    allocations = {
        ["Food"] = 6, -- Prepared meals
        ["Fresh"] = 6
    },
    wants = {
        ["Spice"] = 1.5, -- Salt/Pepper/Sugar
        ["Fuel"] = 1.2,  -- Cooking fuel
        ["Water"] = 1.2,
        ["Seed"] = 1.1
    },
    forbid = { "Weapon", "Ammo", "Junk" }
})

-- 14. THE HERBALIST (Nature Lover)
DynamicTrading.RegisterArchetype("Herbalist", {
    name = "Herbalist",
    allocations = {
        ["Forage"] = 8, -- Berries/Mushrooms
        ["Medical"] = 4 -- Herbal poultices
    },
    wants = {
        ["Jar"] = 1.5, -- For preserving
        ["Bag"] = 1.2, -- For gathering
        ["Literature"] = 1.3 -- Herbalist Mags
    },
    forbid = { "Canned", "Firearm", "Electronics" }
})

-- =============================================================================
-- GROUP D: THE ODDBALLS (Flavor & Niche)
-- =============================================================================

-- 15. THE SMUGGLER (Vice Dealer)
DynamicTrading.RegisterArchetype("Smuggler", {
    name = "Night Trader",
    allocations = {
        ["Alcohol"] = 5,
        ["Tobacco"] = 5,
        ["Luxury"] = 3
    },
    wants = {
        ["Firearm"] = 1.5, -- Pistols only usually
        ["Ammo"] = 1.3,
        ["Fuel"] = 1.4     -- For fast cars
    },
    forbid = { "Junk", "Material", "Seed" }
})

-- 16. THE LIBRARIAN (Knowledge Keeper)
DynamicTrading.RegisterArchetype("Librarian", {
    name = "Archivist",
    allocations = {
        ["Literature"] = 10,
        ["Map"] = 3
    },
    wants = {
        ["Electronics"] = 1.3, -- CDs/VHS
        ["LightSource"] = 1.2, -- Reading lights
        ["Coffee"] = 1.4       -- Late nights
    },
    forbid = { "Weapon", "Alcohol" }
})

-- 17. THE ANGLER (Fisherman)
DynamicTrading.RegisterArchetype("Angler", {
    name = "River Trader",
    allocations = {
        ["Fresh"] = 6, -- Fish
        ["Water"] = 4
    },
    wants = {
        ["Tool"] = 1.2,   -- Rod repair
        ["Fabric"] = 1.4, -- Fishing line/twine
        ["Spice"] = 1.3   -- Cooking fish
    },
    forbid = { "Electronics", "Firearm" }
})

-- 18. THE SHERIFF (Law & Order)
DynamicTrading.RegisterArchetype("Sheriff", {
    name = "Constable",
    allocations = {
        ["Weapon"] = 4,   -- Shotguns/Nightsticks
        ["Ammo"] = 4,
        ["Clothing"] = 3  -- Police gear
    },
    wants = {
        ["Communication"] = 1.5, -- Walkie Talkies
        ["Coffee"] = 1.5,        -- Cop fuel
        ["Food"] = 1.2           -- Donuts (Sweet foods)
    },
    forbid = { "Illegal", "HeavyWeapon" }
})

-- 19. THE BARTENDER (Pub Owner)
DynamicTrading.RegisterArchetype("Bartender", {
    name = "Barkeep",
    allocations = {
        ["Alcohol"] = 8,
        ["Glass"] = 4, -- Empty bottles
        ["Entertainment"] = 2
    },
    wants = {
        ["Fruit"] = 1.3, -- Cocktail ingredients
        ["Clean"] = 1.2, -- Cleaning supplies
        ["Junk"] = 1.1   -- Pub decor
    },
    forbid = { "Weapon", "Ammo" }
})

-- 20. THE TEACHER (School)
DynamicTrading.RegisterArchetype("Teacher", {
    name = "Teacher",
    allocations = {
        ["Literature"] = 5,
        ["Stationery"] = 6,
        ["Bag"] = 3
    },
    wants = {
        ["Toy"] = 1.5,   -- For the kids
        ["Food"] = 1.2,  -- Candy/Sweets
        ["Medical"] = 1.2
    },
    forbid = { "Alcohol", "Tobacco", "Weapon" }
})

print("[DynamicTrading] 20 Archetypes Loaded Successfully.")