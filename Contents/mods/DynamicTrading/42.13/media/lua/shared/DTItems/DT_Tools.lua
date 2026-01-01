require "DynamicTrading_Config"

if not DynamicTrading then return end

-- =================================================
-- HELPER: REGISTER LIST
-- =================================================
local function Register(list)
    for _, data in ipairs(list) do
        -- Use the Item ID as the Unique ID
        DynamicTrading.AddItem(data.item, data)
    end
end

-- =================================================
-- ITEM DEFINITIONS
-- =================================================
Register({
    -- BASIC TOOLS (Common)
    { item="Base.Hammer",       basePrice=15,  tags={"Tool", "Build"},      stockRange={min=2, max=5} },
    { item="Base.Screwdriver",  basePrice=10,  tags={"Tool", "Common"},     stockRange={min=3, max=8} },
    { item="Base.Saw",          basePrice=20,  tags={"Tool", "Build"},      stockRange={min=1, max=3} },
    { item="Base.NailsBox",     basePrice=10,  tags={"Tool", "Build"},      stockRange={min=2, max=6} },
    
    -- FARMING / OUTDOORS
    { item="Base.GardenSaw",    basePrice=15,  tags={"Tool", "Gardening"},  stockRange={min=1, max=3} },
    { item="Base.Trowel",       basePrice=12,  tags={"Tool", "Gardening"},  stockRange={min=1, max=4} },
    { item="Base.Shovel",       basePrice=25,  tags={"Tool", "Gardening"},  stockRange={min=1, max=2} },

    -- MECHANIC
    { item="Base.Wrench",       basePrice=18,  tags={"Tool", "CarPart"},    stockRange={min=1, max=3} },
    { item="Base.LugWrench",    basePrice=18,  tags={"Tool", "CarPart"},    stockRange={min=1, max=3} },
    { item="Base.Jack",         basePrice=35,  tags={"Tool", "CarPart"},    stockRange={min=1, max=1} },
    { item="Base.TirePump",     basePrice=15,  tags={"Tool", "CarPart"},    stockRange={min=1, max=2} },

    -- RARE / EXPENSIVE
    -- Note: We add the "Rare" tag, which multiplies price by 2.0 (defined in Tags.lua)
    { 
        item="Base.Sledgehammer", 
        basePrice=80,  -- Final price ~160
        tags={"Tool", "Heavy", "Rare"}, 
        stockRange={min=1, max=1}, 
        chance=2 -- Very low spawn weight
    },
    { 
        item="Base.Axe", 
        basePrice=45, 
        tags={"Tool", "Weapon", "Rare"}, 
        stockRange={min=1, max=2},
        chance=5
    },
    { 
        item="Base.WoodAxe", 
        basePrice=55, 
        tags={"Tool", "Weapon", "Rare"}, 
        stockRange={min=1, max=1},
        chance=3
    }
})