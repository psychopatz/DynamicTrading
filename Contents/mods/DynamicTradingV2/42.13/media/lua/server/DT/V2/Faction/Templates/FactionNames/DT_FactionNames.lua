-- ==============================================================================
-- media/lua/shared/Faction/DT_FactionNames.lua
-- Logic: Dynamic Name Generation for Factions
-- Build 42 Compatible.
-- ==============================================================================

DT_FactionNames = {}

-- 1. PREFIXES: The first word of the name
DT_FactionNames.Prefixes = {
    "The", "Great", "Iron", "Rusty", "Deadly", "New", "Hidden", "Eternal", 
    "Last", "Sovereign", "Gilded", "Crimson", "Azure", "Broken", "Silent",
    "Wild", "Free", "Old", "United", "Holy", "Lone", "Swift", "Grim"
}

-- 2. NOUNS: The core identity of the group
DT_FactionNames.Nouns = {
    "Vanguard", "Reapers", "Union", "Settlers", "Raiders", "Knights", 
    "Collective", "Republic", "Guardians", "Hounds", "Eagles", "Crows", 
    "Syndicate", "Alliance", "Order", "Brigade", "Covenant", "Brotherhood", 
    "Sisters", "Militia", "Survivors", "Remnant", "Garrison", "Wardens"
}

-- 3. SUFFIXES: Optional additions for flavor (e.g., "of Knox")
DT_FactionNames.Suffixes = {
    "of Knox", "of the Dead", "of the Forest", "of Kentucky", "from the Ashes",
    "Corps", "Network", "Frontier", "Hold", "Dominion"
}

-- ==========================================================
-- GENERATION LOGIC
-- ==========================================================
-- Returns a string like "The Iron Vanguard" or "Great Raiders of the Dead"
function DT_FactionNames.Generate()
    local prefix = DT_FactionNames.Prefixes[ZombRand(#DT_FactionNames.Prefixes) + 1]
    local noun = DT_FactionNames.Nouns[ZombRand(#DT_FactionNames.Nouns) + 1]
    
    -- We'll give it a 30% chance to have a suffix for extra variety
    local finalName = prefix .. " " .. noun
    
    if ZombRand(100) < 30 then
        local suffix = DT_FactionNames.Suffixes[ZombRand(#DT_FactionNames.Suffixes) + 1]
        finalName = finalName .. " " .. suffix
    end

    -- Safety check: Ensure we don't return an empty string
    if not finalName or finalName == "" then return "A Group of Strangers" end
    
    return finalName
end

-- ==========================================================
-- DEBUGGING
-- ==========================================================
-- This allows you to test names in the console without spawning anything
function DT_FactionNames.TestPrint(count)
    print("DT DEBUG: Generating " .. tostring(count) .. " test names...")
    for i=1, count do
        print("  - " .. DT_FactionNames.Generate())
    end
end

-- Print to console so we know the naming module is ready
print("[Dynamic Trading] Faction Name Generator Initialized.")