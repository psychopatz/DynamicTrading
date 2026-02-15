-- ==============================================================================
-- DT_NPC_Archetypes.lua
-- Database for Custom/Donator NPCs.
-- The Generator will check this list for specific spawning rules or random chances.
-- ==============================================================================

DT_NPC_Archetypes = DT_NPC_Archetypes or {}

-- Format:
-- {
--     name = "Psychopatz", 
--     isFemale = false,
--     outfit = { "Base.Tshirt_White", "Base.Jeans_Black", "Base.Shoes_Sneakers" },
--     hairStyle = "Bob", -- Optional
--     beardStyle = "Full", -- Optional
--     archetypeID = "Chef", -- Optional: Forces this archetype during generation
--     weight = 10, -- Chance weight relative to others
-- }

DT_NPC_Archetypes.List = {
    -- 1. The Sheriff (Rick)
    {
        name = "Rick Grimes",
        isFemale = false,
        outfit = { "Base.Hat_Sheriff", "Base.Shirt_Sheriff", "Base.Trousers_Sheriff", "Base.Shoes_Black", "Base.HolsterSimple" },
        beardStyle = "BeardFull",
        hairStyle = "Short",
        archetypeID = "Sheriff",
        weight = 10
    },

    -- 2. The Doctor
    {
        name = "Dr. House",
        isFemale = false,
        outfit = { "Base.JacketLong_Doctor", "Base.Shirt_FormalWhite", "Base.Trousers_Suit", "Base.Shoes_Black" },
        beardStyle = "BeardStubble",
        hairStyle = "BaldSpot",
        archetypeID = "Doctor",
        weight = 10
    },

    -- 3. The Survivalist
    {
        name = "Bear Grylls",
        isFemale = false,
        outfit = { "Base.PonchoGreen", "Base.Trousers_HuntingCamo", "Base.Shoes_HikingBoots", "Base.Bag_LeatherWaterBag" },
        hairStyle = "Messy",
        archetypeID = "Survivalist",
        weight = 10
    },

    -- 4. The Chef (Gordon)
    {
        name = "Gordon Ramsay",
        isFemale = false,
        outfit = { "Base.Jacket_Chef", "Base.Hat_ChefHat", "Base.Trousers_Chef", "Base.Shoes_Black" },
        hairStyle = "Spiky",
        archetypeID = "Chef",
        weight = 10
    },

    -- 5. The Mechanic (Cid)
    {
        name = "Cindy",
        isFemale = true,
        outfit = { "Base.Shorts_ShortDenim", "Base.Vest_HighViz", "Base.Hat_BandanaTied", "Base.Shoes_WorkBoots" },
        hairStyle = "Ponytail",
        archetypeID = "Mechanic",
        weight = 10
    },
    
    -- 6. The Biker (Daryl)
    {
        name = "Daryl",
        isFemale = false,
        outfit = { "Base.Vest_Hunting_Camo", "Base.Shirt_Denim", "Base.Trousers_JeanBaggy", "Base.Shoes_BlackBoots" },
        hairStyle = "Long2",
        beardStyle = "BeardGoatee",
        archetypeID = "Survivalist",
        weight = 10
    },
    
    -- 7. The Scientist
    {
        name = "Dr. Kleiner",
        isFemale = false,
        outfit = { "Base.JacketLong_Doctor", "Base.Shirt_FormalWhite", "Base.Tie_Red", "Base.Trousers_Suit", "Base.Shoes_Black", "Base.Glasses_Thick" },
        hairStyle = "BaldSpot",
        archetypeID = "Doctor",
        weight = 10
    },

    -- 8. The Lumberjack
    {
        name = "Paul Bunyan",
        isFemale = false,
        outfit = { "Base.Shirt_Lumberjack", "Base.Trousers_Denim", "Base.Shoes_WorkBoots", "Base.Hat_WinterHat" },
        beardStyle = "BeardLong",
        archetypeID = "Foreman",
        weight = 10
    }
}

-- Return a random MVP or nil if list is empty
function DT_NPC_Archetypes.GetRandom()
    if #DT_NPC_Archetypes.List == 0 then return nil end
    return DT_NPC_Archetypes.List[ZombRand(#DT_NPC_Archetypes.List) + 1]
end
