--[[
    =============================================================================
    DYNAMIC TRADING - ARCHETYPE CONFIGURATION GUIDE
    =============================================================================
    
    This file defines the specific "Personalities" of traders found via radio.
    You can modify existing traders or add your own by following the format below.

    HOW TO REGISTER A NEW TRADER:
    -------------------------------------------------------------------------
    DynamicTrading.RegisterArchetype("UniqueID", {
        name = "Display Name",      -- The name shown in the UI (e.g., "Farmer", "Gunrunner")

        -- [WHAT THEY SELL]
        -- Key = Tag Name, Value = 'Slots' or Weight. 
        -- Higher numbers mean the trader will generate MORE items of this category.
        allocations = {
            ["Food"] = 5,           -- High chance for Food
            ["Medical"] = 2         -- Low chance for Meds
        },

        -- [WHAT THEY WANT] (Price Bonus)
        -- Key = Tag Name, Value = Price Multiplier.
        -- 1.2 = Pays +20% more. 1.5 = Pays +50% more.
        wants = {
            ["Seed"] = 1.5,         -- Loves Seeds
            ["Tool"] = 1.2          -- Likes Tools
        },

        -- [WHAT THEY HATE]
        -- List of Tags this trader will NEVER sell and usually won't buy.
        forbid = { "Weapon", "Alcohol", "Junk" }
    })

    Available Tags can be found in the /media/lua/shared/DTItems/ folders.
    (e.g., "Ammo", "Medical", "Luxury", "Construction", "Fresh", "Canned", etc.)
    =============================================================================
]]
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
        ["Clothing"] = 2,
        ["General"] = 2
    },
    wants = {
        ["Luxury"] = 1.1,
        ["Jewelry"] = 1.2
    }, 
    forbid = { "Illegal", "Legendary" }
})

-- 2. THE FARMER (Food Producer)
DynamicTrading.RegisterArchetype("Farmer", {
    name = "Farmer",
    allocations = {
        ["Vegetable"] = 6,
        ["Fruit"] = 4,
        ["Grain"] = 4,
        ["Farming"] = 3, -- Replaces 'Seed' (Found in DT_Containers)
        ["Farmer"] = 2   -- Tools/Items specific to farmers
    },
    wants = {
        ["Tool"] = 1.3,
        ["Water"] = 1.2,
        ["Fuel"] = 1.2
    },
    forbid = { "Gun", "Ammo", "Electronics" }
})

-- 3. THE BUTCHER (Meat Source)
DynamicTrading.RegisterArchetype("Butcher", {
    name = "Butcher",
    allocations = {
        ["Meat"] = 8,
        ["Butcher"] = 4, -- Specific tools/items
        ["Container"] = 2
    },
    wants = {
        ["Ammo"] = 1.4,   -- Hunting
        ["Blade"] = 1.3,  -- Processing
        ["Spice"] = 1.2   -- Curing
    },
    forbid = { "Vegetable", "Fruit", "Literature" }
})

-- 4. THE DOCTOR (Medic)
DynamicTrading.RegisterArchetype("Doctor", {
    name = "Field Medic",
    allocations = {
        ["Medical"] = 8,
        ["Pill"] = 4,
        ["Sterile"] = 3,
        ["Pharmacist"] = 2
    },
    wants = {
        ["Clean"] = 1.5,   -- Hygiene products
        ["Alcohol"] = 1.3, -- Disinfectant
        ["Luxury"] = 1.2   -- Comfort items
    },
    forbid = { "Junk", "Build", "CarPart" }
})

-- 5. THE MECHANIC (Vehicle Expert)
DynamicTrading.RegisterArchetype("Mechanic", {
    name = "Mechanic",
    allocations = {
        ["CarPart"] = 8,
        ["Mechanic"] = 5,
        ["Fuel"] = 3,
        ["Tool"] = 4
    },
    wants = {
        ["Electronics"] = 1.3,
        ["Junk"] = 1.1, -- Scrap metal
        ["Drink"] = 1.2
    },
    forbid = { "Clothing", "Medical", "Farming" }
})

-- =============================================================================
-- GROUP B: THE SURVIVORS (Hardened Types)
-- =============================================================================

-- 6. THE SURVIVALIST (The Prepper)
DynamicTrading.RegisterArchetype("Survivalist", {
    name = "Prepper",
    allocations = {
        ["Canned"] = 6,
        ["Survival"] = 5,
        ["Ammo"] = 4,
        ["Battery"] = 2
    },
    wants = {
        ["Weapon"] = 1.3,
        ["Fuel"] = 1.5,
        ["Generator"] = 1.4
    },
    forbid = { "Fresh", "Luxury", "Toy" }
})

-- 7. THE GUNRUNNER (Arms Dealer)
DynamicTrading.RegisterArchetype("Gunrunner", {
    name = "Gunrunner",
    allocations = {
        ["Gun"] = 5,      -- Replaces 'Firearm'
        ["Ammo"] = 8,
        ["WeaponPart"] = 4,
        ["Gunrunner"] = 3 -- Specific items
    },
    wants = {
        ["Armor"] = 1.5,
        ["Medical"] = 1.3,
        ["Canned"] = 1.1
    },
    forbid = { "Tool", "Farming", "Literature" }
})

-- 8. THE CONSTRUCTION FOREMAN (Builder)
DynamicTrading.RegisterArchetype("Foreman", {
    name = "Site Foreman",
    allocations = {
        ["Material"] = 8,
        ["Build"] = 6,
        ["Wood"] = 4,
        ["Heavy"] = 2 -- Heavy tools
    },
    wants = {
        ["Tool"] = 1.4,
        ["Alcohol"] = 1.2,
        ["HighCalorie"] = 1.2
    },
    forbid = { "Literature", "Jewelry" }
})

-- 9. THE SCAVENGER (Junk Lord)
DynamicTrading.RegisterArchetype("Scavenger", {
    name = "Scavenger",
    allocations = {
        ["Junk"] = 10,
        ["Trash"] = 5,
        ["Scavenger"] = 5,
        ["Material"] = 3
    },
    wants = {
        ["Backpack"] = 1.5, -- Needs space
        ["Water"] = 1.2,
        ["Food"] = 1.2
    },
    forbid = {} -- Buys everything
})

-- =============================================================================
-- GROUP C: THE SPECIALISTS (Skilled Trades)
-- =============================================================================

-- 10. THE TAILOR (Clothier)
DynamicTrading.RegisterArchetype("Tailor", {
    name = "Tailor",
    allocations = {
        ["Clothing"] = 8,
        ["Textile"] = 5, -- Replaces 'Fabric'
        ["Tailor"] = 4,  -- Specific tools
        ["Organizer"] = 2
    },
    wants = {
        ["Tool"] = 1.2,
        ["Jewelry"] = 1.3,
        ["SkillBook"] = 1.3
    },
    forbid = { "Fuel", "CarPart", "Heavy" }
})

-- 11. THE ELECTRICIAN (Techie)
DynamicTrading.RegisterArchetype("Electrician", {
    name = "Electrician",
    allocations = {
        ["Electronics"] = 8,
        ["Communication"] = 4,
        ["Light"] = 3, -- Replaces 'LightSource'
        ["Generator"] = 2
    },
    wants = {
        ["Tool"] = 1.3,
        ["Copper"] = 1.4, -- Found in DT_Cooking/Materials
        ["SkillBook"] = 1.4
    },
    forbid = { "Fresh", "Clothing" }
})

-- 12. THE WELDER (Metalworker)
DynamicTrading.RegisterArchetype("Welder", {
    name = "Metalworker",
    allocations = {
        ["Metal"] = 8,
        ["Smithing"] = 6, -- Replaces 'Metalwork'
        ["Tool"] = 4
    },
    wants = {
        ["Fuel"] = 2.0, -- Propane
        ["Electronics"] = 1.2,
        ["Heavy"] = 1.3
    },
    forbid = { "Farming", "Bedding" }
})

-- 13. THE CHEF (Cook)
DynamicTrading.RegisterArchetype("Chef", {
    name = "Chef",
    allocations = {
        ["Cooking"] = 6,
        ["Food"] = 6,
        ["Fresh"] = 4,
        ["Spice"] = 3,
        ["Ingredient"] = 3
    },
    wants = {
        ["Preservation"] = 1.5,
        ["Fuel"] = 1.2,
        ["Water"] = 1.2
    },
    forbid = { "Weapon", "Ammo", "Junk" }
})

-- 14. THE HERBALIST (Nature Lover)
DynamicTrading.RegisterArchetype("Herbalist", {
    name = "Herbalist",
    allocations = {
        ["Herb"] = 8,
        ["Vegetable"] = 4,
        ["Preservation"] = 4, -- Jars/Lids
        ["Tea"] = 2
    },
    wants = {
        ["Container"] = 1.5,
        ["Backpack"] = 1.2,
        ["Literature"] = 1.3
    },
    forbid = { "Canned", "Gun", "Electronics" }
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
        ["Luxury"] = 3,
        ["Illegal"] = 3
    },
    wants = {
        ["Gun"] = 1.5,
        ["Ammo"] = 1.3,
        ["Jewelry"] = 1.4
    },
    forbid = { "Junk", "Material", "Farming" }
})

-- 16. THE LIBRARIAN (Knowledge Keeper)
DynamicTrading.RegisterArchetype("Librarian", {
    name = "Archivist",
    allocations = {
        ["Literature"] = 10,
        ["SkillBook"] = 6,
        ["Cartography"] = 4, -- Replaces 'Map'
        ["Scholastic"] = 3
    },
    wants = {
        ["Electronics"] = 1.3,
        ["Light"] = 1.2,
        ["Music"] = 1.2
    },
    forbid = { "Weapon", "Alcohol" }
})

-- 17. THE ANGLER (Fisherman)
DynamicTrading.RegisterArchetype("Angler", {
    name = "River Trader",
    allocations = {
        ["Fish"] = 6,
        ["Bait"] = 5,
        ["Trapping"] = 4,
        ["Water"] = 4
    },
    wants = {
        ["Tool"] = 1.2,
        ["Textile"] = 1.4, -- Fishing line
        ["Spice"] = 1.3
    },
    forbid = { "Electronics", "Gun" }
})

-- 18. THE SHERIFF (Law & Order)
DynamicTrading.RegisterArchetype("Sheriff", {
    name = "Constable",
    allocations = {
        ["Police"] = 5,
        ["Gun"] = 4,
        ["Ammo"] = 4,
        ["Weapon"] = 3
    },
    wants = {
        ["Communication"] = 1.5,
        ["Donut"] = 2.0, -- Specific item if modded, otherwise Food
        ["Sweets"] = 1.5, -- Found in DT_Food
        ["Coffee"] = 1.5
    },
    forbid = { "Illegal", "Heavy" }
})

-- 19. THE BARTENDER (Pub Owner)
DynamicTrading.RegisterArchetype("Bartender", {
    name = "Barkeep",
    allocations = {
        ["Alcohol"] = 8,
        ["Drink"] = 6,
        ["Glass"] = 4,
        ["Fun"] = 2
    },
    wants = {
        ["Fruit"] = 1.3,
        ["Clean"] = 1.2,
        ["Junk"] = 1.1 -- Decor
    },
    forbid = { "Weapon", "Ammo" }
})

-- 20. THE TEACHER (School)
DynamicTrading.RegisterArchetype("Teacher", {
    name = "Teacher",
    allocations = {
        ["Scholastic"] = 8,
        ["Paper"] = 6,  -- Found in DT_Junk
        ["Office"] = 5, -- Found in DT_Containers
        ["Literature"] = 3
    },
    wants = {
        ["Toy"] = 1.5,
        ["Sweets"] = 1.2,
        ["Medical"] = 1.2
    },
    forbid = { "Alcohol", "Tobacco", "Weapon" }
})
-- 21. THE HUNTER (Wilderness Survival)
DynamicTrading.RegisterArchetype("Hunter", {
    name = "Trapper",
    allocations = {
        ["Trapping"] = 5,
        ["Game"] = 5,       -- Wild meat
        ["Leather"] = 4,    -- Animal products
        ["Hunting"] = 3,    -- Specific weapons/gear
        ["Bone"] = 2
    },
    wants = {
        ["Spice"] = 1.3,    -- For making jerky
        ["Camping"] = 1.4,  -- Tents/Sleep bags
        ["Blade"] = 1.2     -- Skinning knives
    },
    forbid = { "Electronics", "Office", "Toy" }
})

-- 22. THE QUARTERMASTER (Military Surplus)
DynamicTrading.RegisterArchetype("Quartermaster", {
    name = "Deserter",
    allocations = {
        ["Military"] = 8,
        ["Tactical"] = 5,
        ["Stockpile"] = 4,  -- Bulk items
        ["MRE"] = 3,        -- If exists (or Canned/Protein)
        ["Canned"] = 3
    },
    wants = {
        ["Alcohol"] = 1.5,
        ["Tobacco"] = 1.5,
        ["Luxury"] = 1.2
    },
    forbid = { "Farming", "Decor", "Toy" }
})

-- 23. THE AUDIOPHILE (Music & Fun)
DynamicTrading.RegisterArchetype("Musician", {
    name = "DJ / Musician",
    allocations = {
        ["Music"] = 10,     -- Instruments, CDs, Vinyl
        ["Electronics"] = 4,
        ["Fun"] = 4,
        ["Leisure"] = 2
    },
    wants = {
        ["Battery"] = 1.5,  -- For portable players
        ["Generator"] = 1.2,-- To keep the music playing
        ["Alcohol"] = 1.2
    },
    forbid = { "Weapon", "Medical", "Farming" }
})

-- 24. THE JANITOR (Cleaning Specialist)
DynamicTrading.RegisterArchetype("Janitor", {
    name = "The Cleaner",
    allocations = {
        ["Clean"] = 8,      -- Bleach, soap, mops
        ["Hygiene"] = 6,
        ["Chemical"] = 3,   -- If exists, otherwise Poison
        ["Poison"] = 3,     -- Rat poison etc
        ["Trash"] = 4       -- Bags, bins
    },
    wants = {
        ["Mask"] = 1.4,     -- If exists, otherwise Clothing/Medical
        ["Wearable"] = 1.2, -- Gloves
        ["Water"] = 1.2
    },
    forbid = { "Food", "Fresh", "Luxury" }
})

-- 25. THE CARPENTER (Wood Specialist)
DynamicTrading.RegisterArchetype("Carpenter", {
    name = "Carpenter",
    allocations = {
        ["Wood"] = 10,
        ["Woodwork"] = 5,   -- Finished wooden items
        ["Carpenter"] = 5,  -- Saws, hammers
        ["Build"] = 3
    },
    wants = {
        ["Tool"] = 1.3,     -- Nails/Screws
        ["Food"] = 1.2,     -- High energy
        ["Medical"] = 1.1   -- Splinters/Cuts
    },
    forbid = { "Metal", "Electronics", "Jewelry" }
})

-- 26. THE PAWNBROKER (Valuables)
DynamicTrading.RegisterArchetype("Pawnbroker", {
    name = "Fence",
    allocations = {
        ["Jewelry"] = 6,
        ["Gold"] = 4,
        ["Silver"] = 4,
        ["Luxury"] = 5,
        ["Rare"] = 3
    },
    wants = {
        ["Electronics"] = 1.2,
        ["Gun"] = 1.2,
        ["Antique"] = 1.5   -- If exists, otherwise Decor
    },
    forbid = { "Trash", "Junk", "Rotten" }
})

-- 27. THE PYROMANIAC (Fire & Fuel)
DynamicTrading.RegisterArchetype("Pyro", {
    name = "Firebug",
    allocations = {
        ["Fuel"] = 8,
        ["Fire"] = 6,       -- Lighters, Matches (Found in Household)
        ["Burnable"] = 4,   -- If exists
        ["Explosive"] = 2   -- If exists
    },
    wants = {
        ["Alcohol"] = 1.3,  -- Flammable
        ["Textile"] = 1.2,  -- Rags
        ["Glass"] = 1.2     -- Bottles for molotovs
    },
    forbid = { "Water", "FireExtinguisher", "Ice" }
})

-- 28. THE ATHLETE (Sports Gear)
DynamicTrading.RegisterArchetype("Athlete", {
    name = "Coach",
    allocations = {
        ["Sport"] = 8,      -- Bats, balls, protective gear
        ["Clothing"] = 4,   -- Running shoes, shorts
        ["Protein"] = 4,
        ["Water"] = 4
    },
    wants = {
        ["Medical"] = 1.3,  -- Bandages, painkillers
        ["HighCalorie"] = 1.2,
        ["Vitamin"] = 1.4   -- If exists
    },
    forbid = { "Alcohol", "Tobacco", "Junk" }
})

-- 29. THE PHARMACIST (Pills & Chemistry)
DynamicTrading.RegisterArchetype("Pharmacist", {
    name = "Pharmacist",
    allocations = {
        ["Pill"] = 8,
        ["Pharmacist"] = 5, -- Specific medical items
        ["Medical"] = 4,
        ["Clean"] = 3
    },
    wants = {
        ["Herb"] = 1.3,     -- Raw ingredients
        ["Paper"] = 1.2,    -- Prescriptions/Notes
        ["Container"] = 1.2 -- Small bottles
    },
    forbid = { "Weapon", "Dirty", "Rotten" }
})

-- 30. THE HIKER (Outdoor/Camping)
DynamicTrading.RegisterArchetype("Hiker", {
    name = "Drifter",
    allocations = {
        ["Camping"] = 8,    -- Tents
        ["Travel"] = 5,     -- Maps/Compasses
        ["Backpack"] = 4,
        ["Shelter"] = 3
    },
    wants = {
        ["Canned"] = 1.3,   -- Trail food
        ["Sweets"] = 1.2,   -- Energy bars
        ["Clothing"] = 1.2  -- Boots/Socks
    },
    forbid = { "Heavy", "Generator", "Furniture" }
})
-- 31. THE BURGLAR (Thief)
DynamicTrading.RegisterArchetype("Burglar", {
    name = "The Fence",
    allocations = {
        ["Thief"] = 5,      -- Crowbars, lock tools (Found in DT_Tools)
        ["Luxury"] = 4,     -- Stolen goods
        ["Jewelry"] = 4,
        ["Illegal"] = 2,
        ["Weapon"] = 2      -- Small arms/knives
    },
    wants = {
        ["Electronics"] = 1.3,
        ["Cash"] = 1.5,     -- If money item exists, otherwise Luxury
        ["Backpack"] = 1.2  -- Duffel bags
    },
    forbid = { "Heavy", "Furniture", "Farming" }
})

-- 32. THE BLACKSMITH (Smithing Specialist)
DynamicTrading.RegisterArchetype("Blacksmith", {
    name = "Blacksmith",
    allocations = {
        ["Smithing"] = 8,   -- Tongs, bellows, hammers
        ["Metal"] = 6,      -- Raw sheets, bars
        ["Heavy"] = 4,      -- Sledgehammers, anvils
        ["Charcoal"] = 3    -- Fuel/Material
    },
    wants = {
        ["Fuel"] = 1.4,     -- Coal/Propane
        ["Water"] = 1.2,    -- Quenching
        ["Leather"] = 1.2   -- Aprons/Grips
    },
    forbid = { "Plastic", "Electronics", "Paper" }
})

-- 33. THE TRIBAL (Primitive Survival)
DynamicTrading.RegisterArchetype("Tribal", {
    name = "Primitive Survivor",
    allocations = {
        ["Primitive"] = 8,  -- Stone tools, handmade items
        ["Spear"] = 6,      -- Crafted spears
        ["Bone"] = 4,       -- Bone needles/knives
        ["Leather"] = 3
    },
    wants = {
        ["Blade"] = 1.3,    -- Good steel knives are gold to them
        ["Textile"] = 1.2,  -- Rope/Twine
        ["Medicine"] = 1.4  -- Real pills are magic
    },
    forbid = { "Electronics", "Gun", "Computer" }
})

-- 34. THE PAINTER (Renovator)
DynamicTrading.RegisterArchetype("Painter", {
    name = "Renovator",
    allocations = {
        ["Painter"] = 8,    -- Brushes, paint buckets
        ["Decor"] = 5,      -- Flooring, fancy items
        ["Material"] = 4,   -- Plaster
        ["Tool"] = 3
    },
    wants = {
        ["Water"] = 1.2,    -- Cleaning brushes
        ["Wearable"] = 1.1, -- Overalls/Masks
        ["Food"] = 1.1
    },
    forbid = { "Weapon", "Rotten", "Dirty" }
})

-- 35. THE ROAD WARRIOR (Vehicle Combat)
DynamicTrading.RegisterArchetype("RoadWarrior", {
    name = "Road Warrior",
    allocations = {
        ["Improvised"] = 6, -- Spiked bats, armor
        ["CarPart"] = 5,
        ["Fuel"] = 5,
        ["Armor"] = 3
    },
    wants = {
        ["Mechanic"] = 1.4, -- Tools to fix the ride
        ["Gun"] = 1.3,      -- Drive-by gear
        ["Canned"] = 1.2
    },
    forbid = { "Decor", "Toy", "Fragile" }
})

-- 36. THE INTERIOR DESIGNER (Home Goods)
DynamicTrading.RegisterArchetype("Designer", {
    name = "Home Stager",
    allocations = {
        ["Decor"] = 10,     -- Paintings, rugs, plants
        ["Furniture"] = 4,  -- If tag exists (implied via Decor)
        ["Light"] = 4,      -- Lamps
        ["Organizer"] = 3   -- Shelves/Boxes
    },
    wants = {
        ["Clean"] = 1.3,
        ["Textile"] = 1.2,  -- Curtains/Sheets
        ["Paint"] = 1.1
    },
    forbid = { "Weapon", "Trash", "Junk" }
})

-- 37. THE OFFICE WORKER (White Collar Hoarder)
DynamicTrading.RegisterArchetype("Office", {
    name = "White Collar",
    allocations = {
        ["Office"] = 8,     -- Paperclips, staplers, binders
        ["Paper"] = 6,
        ["Electronics"] = 4,-- Calculators, PCs
        ["Suit"] = 2        -- Clothing (Formal)
    },
    wants = {
        ["Coffee"] = 2.0,   -- The lifeblood
        ["Sweets"] = 1.3,   -- Donuts/Vending machine food
        ["Tobacco"] = 1.2   -- Stress relief
    },
    forbid = { "Farm", "Heavy", "Dirty" }
})

-- 38. THE GEEK (Toys & Tech)
DynamicTrading.RegisterArchetype("Geek", {
    name = "Collector",
    allocations = {
        ["Toy"] = 6,        -- Action figures, plushies
        ["Fun"] = 5,        -- Games
        ["Electronics"] = 5,-- Consoles
        ["Literature"] = 4  -- Comics (Magazines)
    },
    wants = {
        ["Battery"] = 1.5,
        ["Sweets"] = 1.4,   -- Junk food
        ["Drink"] = 1.2     -- Soda
    },
    forbid = { "Alcohol", "Farm", "Tool" }
})

-- 39. THE BREWER (Alcohol Maker)
DynamicTrading.RegisterArchetype("Brewer", {
    name = "Moonshiner",
    allocations = {
        ["Alcohol"] = 8,
        ["Sugar"] = 4,      -- Ingredient (Food/Spice)
        ["Water"] = 4,
        ["Glass"] = 3       -- Bottles
    },
    wants = {
        ["Fruit"] = 1.4,    -- Fermentation base
        ["Grain"] = 1.4,    -- Wheat/Corn
        ["Fuel"] = 1.3      -- For the still
    },
    forbid = { "Police", "Law", "Book" }
})

-- 40. THE DEMOLITIONIST (Heavy Destruction)
DynamicTrading.RegisterArchetype("Demo", {
    name = "Demo Expert",
    allocations = {
        ["Heavy"] = 6,      -- Sledges, Pickaxes
        ["Fire"] = 4,
        ["Fuel"] = 4,
        ["Electronics"] = 3 -- Detonators/timers
    },
    wants = {
        ["Gunpowder"] = 2.0, -- Ammo parts
        ["Wire"] = 1.5,      -- Material/Electronics
        ["Medical"] = 1.2    -- Burns/injuries
    },
    forbid = { "Fragile", "Glass", "Decor" }
})
print("[DynamicTrading] 20 Archetypes Loaded Successfully.")