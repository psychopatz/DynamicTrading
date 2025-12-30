DynamicTrading = DynamicTrading or {}
DynamicTrading.Config = {}
DynamicTrading.Config.MasterList = {} 

-- =================================================
-- MERCHANT ARCHETYPES
-- =================================================
-- Allocations can be a Category Name (e.g., "Food") 
-- OR a Tag (e.g., "Meat", "Gun", "Build").
-- The system checks Tags first, then Categories.

DynamicTrading.Config.MerchantTypes = {
    -- 1. THE GENERAL TRADER (Balanced)
    General = {
        name = "General Trader",
        desc = "A little bit of everything for everyone.",
        allocations = {
            Food = 6,
            Material = 4,
            Medical = 2,
            Junk = 3,
            Literature = 1,
            Clothing = 2,
            Weapon = 2
        }
    },

    -- 2. THE BUTCHER (Meat Specialist)
    Butcher = {
        name = "The Butcher",
        desc = "Fresh meat, animal parts, and sharp knives.",
        allocations = {
            Meat = 8,          -- Tag: Meat
            AnimalPart = 4,    -- Category: AnimalPart (or Tag)
            Blade = 3,         -- Tag: Blade (Knives/Axes)
            Food = 2,          -- Category: Food (General filler)
        }
    },

    -- 3. THE GUNRUNNER (Weapons Specialist)
    Gunrunner = {
        name = "The Gunrunner",
        desc = "Heavy firepower and ammunition.",
        allocations = {
            Gun = 5,           -- Tag: Gun
            Ammo = 7,          -- Tag: Ammo
            Military = 3,      -- Tag: Military
            WeaponPart = 3,    -- Category
            Armor = 2          -- Tag: Armor
        }
    },

    -- 4. THE SURVIVALIST (Outdoorsman)
    Survivalist = {
        name = "The Survivalist",
        desc = "Gear for living off the grid.",
        allocations = {
            Camping = 5,       -- Category
            Trap = 2,          -- Category
            Survival = 4,      -- Tag: Survival (Lighters, Tents)
            Weapon = 2,        -- Category
            Warm = 3,          -- Tag: Warm (Clothing)
            Medical = 2
        }
    },

    -- 5. THE SCAVENGER (Junk & Parts)
    Scavenger = {
        name = "The Scavenger",
        desc = "One man's trash is another man's treasure.",
        allocations = {
            Junk = 8,          -- Category
            Material = 5,      -- Category
            Electronics = 3,   -- Category
            SpareParts = 4,    -- Tag: Repair (Duct tape, Glue)
            Clothing = 2
        }
    },

    -- 6. THE MECHANIC (Cars & Tools)
    Mechanic = {
        name = "The Mechanic",
        desc = "Vehicle parts, fuel, and heavy tools.",
        allocations = {
            Car = 6,           -- Tag: Car (Batteries, Wrenches)
            Fuel = 4,          -- Tag: Fuel
            Tool = 5,          -- Category
            Heavy = 2,         -- Tag: Heavy (Sledgehammers, Jacks)
            Electronics = 2
        }
    },

    -- 7. THE PHARMACIST (Medical)
    Pharmacist = {
        name = "The Pharmacist",
        desc = "Medicine, hygiene, and chemicals.",
        allocations = {
            Medical = 8,       -- Category
            Clean = 5,         -- Tag: Clean (Soap, Bleach)
            Heal = 4,          -- Tag: Heal (Bandages)
            Food = 2,          -- Category (Water/Food)
        }
    },

    -- 8. THE CARPENTER (Builder)
    Carpenter = {
        name = "The Carpenter",
        desc = "Building materials and blueprints.",
        allocations = {
            Build = 8,         -- Tag: Build (Nails, Hammers, Saws)
            Material = 5,      -- Category
            Literature = 3,    -- Category (Skill books)
            Clothing = 2       -- Work clothes
        }
    },

    -- 9. THE FARMER (Crops & Fresh Food)
    Farmer = {
        name = "The Farmer",
        desc = "Fresh produce and gardening tools.",
        allocations = {
            Crop = 6,          -- Tag: Crop (Seeds, Veggies)
            Fresh = 6,         -- Tag: Fresh
            Gardening = 4,     -- Category
            Food = 2,
            Water = 2          -- Tag: Water
        }
    }

} -- <<-- IMPORTANT: This closing bracket must always be here!

-- =================================================
-- HELPER: ITEM REGISTRATION
-- =================================================
function DynamicTrading.AddItem(uniqueID, data)
    if not uniqueID or not data then return end
    
    -- Set defaults to prevent crashes
    if not data.basePrice then data.basePrice = 10 end
    if not data.stockRange then data.stockRange = {min=1, max=5} end
    if not data.tags then data.tags = {} end
    
    DynamicTrading.Config.MasterList[uniqueID] = data
end

print("[DynamicTrading] Config & Archetypes Loaded.")