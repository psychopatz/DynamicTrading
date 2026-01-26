require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
-- =============================================================================
-- 1. CLEANING & HYGIENE (Disease Prevention)
-- =============================================================================
{ item="Base.Soap2", basePrice=12, tags={"Cleaning", "Hygiene", "Common"}, stockRange={min=5, max=20} }, -- Speed up washing
{ item="Base.Bleach", basePrice=15, tags={"Cleaning", "Poison"}, stockRange={min=2, max=10} }, -- Clean blood or die
{ item="Base.CleaningLiquid2", basePrice=8, tags={"Cleaning"}, stockRange={min=2, max=10} },
{ item="Base.BathTowel", basePrice=8, tags={"Cleaning", "Hygiene"}, stockRange={min=2, max=10} },
{ item="Base.DishCloth", basePrice=4, tags={"Cleaning", "Hygiene"}, stockRange={min=2, max=10} },
{ item="Base.Sponge", basePrice=3, tags={"Cleaning", "Hygiene"}, stockRange={min=2, max=10} },
{ item="Base.Broom", basePrice=5, tags={"Cleaning", "Weapon"}, stockRange={min=1, max=5} }, -- Weak spear
{ item="Base.Mop", basePrice=5, tags={"Cleaning", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Plunger", basePrice=5, tags={"Cleaning", "Weapon"}, stockRange={min=1, max=5} }, -- Spear component
{ item="Base.ToiletBrush", basePrice=2, tags={"Cleaning", "Junk"}, stockRange={min=1, max=5} },
-- Wet items are generally junk unless dried, trading them is weird
{ item="Base.BathTowelWet",     basePrice=1,  tags={"Cleaning", "Junk"}, stockRange={min=0, max=0} },
{ item="Base.DishClothWet",     basePrice=1,  tags={"Cleaning", "Junk"}, stockRange={min=0, max=0} },

-- =============================================================================
-- 2. FIRE SAFETY & FUEL
-- =============================================================================
{ item="Base.Extinguisher",     basePrice=40, tags={"Fire", "Safety", "Heavy"}, stockRange={min=1, max=3} }, -- Saves bases
{ item="Base.LighterFluid",     basePrice=12, tags={"Fire", "Fuel", "Common"}, stockRange={min=2, max=10} }, -- Accelerant
{ item="Base.BBQStarterFluid",  basePrice=12, tags={"Fire", "Fuel", "Common"}, stockRange={min=2, max=10} },

-- =============================================================================
-- 3. WRITING & MAP TOOLS (Scholastic)
-- =============================================================================
-- Essential for map marking, but very common loot.
{ item="Base.Pencil",           basePrice=1,  tags={"Scholastic", "Common"}, stockRange={min=10, max=50} },
{ item="Base.Pen",              basePrice=1,  tags={"Scholastic", "Common"}, stockRange={min=10, max=50} }, -- Black
{ item="Base.BluePen",          basePrice=1,  tags={"Scholastic", "Common"}, stockRange={min=5, max=20} },
{ item="Base.RedPen",           basePrice=1,  tags={"Scholastic", "Common"}, stockRange={min=5, max=20} },
{ item="Base.GreenPen",         basePrice=1,  tags={"Scholastic", "Common"}, stockRange={min=5, max=20} },
{ item="Base.Eraser",           basePrice=2,  tags={"Scholastic", "Common"}, stockRange={min=5, max=20} },
{ item="Base.Crayons",          basePrice=3,  tags={"Scholastic", "Common"}, stockRange={min=5, max=20} },

-- Premium Writing
{ item="Base.PenMultiColor",    basePrice=5,  tags={"Scholastic", "Uncommon"}, stockRange={min=1, max=5} }, -- 4 colors in 1
{ item="Base.PenFancy",         basePrice=10, tags={"Scholastic", "Luxury"}, stockRange={min=1, max=3} }, -- Fountain Pen

-- Collector Items (Spiffo)
{ item="Base.PenSpiffo",        basePrice=15, tags={"Scholastic", "Luxury", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.PencilSpiffo",     basePrice=15, tags={"Scholastic", "Luxury", "Rare"}, stockRange={min=0, max=2} },

-- Markers (Bold map markings)
{ item="Base.MarkerBlack",      basePrice=2,  tags={"Scholastic", "Common"}, stockRange={min=2, max=10} },
{ item="Base.MarkerBlue",       basePrice=2,  tags={"Scholastic", "Common"}, stockRange={min=2, max=10} },
{ item="Base.MarkerRed",        basePrice=2,  tags={"Scholastic", "Common"}, stockRange={min=2, max=10} },
{ item="Base.MarkerGreen",      basePrice=2,  tags={"Scholastic", "Common"}, stockRange={min=2, max=10} },

-- =============================================================================
-- 4. HOUSEHOLD TOOLS & MISC
-- =============================================================================
{ item="Base.Scissors",         basePrice=15, tags={"Tool", "Clothing", "Common"}, stockRange={min=2, max=10} }, -- Essential for Tailoring
{ item="Base.ScissorsBlunt",    basePrice=10, tags={"Tool", "Clothing", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.ScissorsForged",   basePrice=8,  tags={"Tool", "Clothing", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.StraightRazor",    basePrice=12, tags={"Tool", "Weapon", "Hygiene"}, stockRange={min=1, max=5} }, -- Good short blade
{ item="Base.LetterOpener",     basePrice=5,  tags={"Tool", "Weapon", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.AlarmClock2",      basePrice=10, tags={"Electronics", "Tool"}, stockRange={min=2, max=10} }, -- Trap component / Waking up
{ item="Base.RatPoison",        basePrice=15, tags={"Poison", "Medical"}, stockRange={min=1, max=5} }, -- Potent poison
{ item="Base.MagnifyingGlass",  basePrice=5,  tags={"Tool", "Fire"}, stockRange={min=1, max=3} }, -- Foraging light fire
{ item="Base.Calculator",       basePrice=5,  tags={"Electronics", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.Clipboard",        basePrice=2,  tags={"Scholastic", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.CorrectionFluid",  basePrice=2,  tags={"Scholastic", "Junk"}, stockRange={min=1, max=5} },

-- Weather Protection (High value in Winter/Rain)
{ item="Base.UmbrellaBlack",        basePrice=10, tags={"Clothing", "Tool"}, stockRange={min=2, max=8} },
{ item="Base.UmbrellaBlue",         basePrice=10, tags={"Clothing", "Tool"}, stockRange={min=2, max=8} },
{ item="Base.UmbrellaRed",          basePrice=10, tags={"Clothing", "Tool"}, stockRange={min=2, max=8} },
{ item="Base.UmbrellaWhite",        basePrice=10, tags={"Clothing", "Tool"}, stockRange={min=2, max=8} },
{ item="Base.UmbrellaTINTED",       basePrice=12, tags={"Clothing", "Tool"}, stockRange={min=1, max=5} },
-- Closed state usually shares price or is untradeable until opened, but we list for completeness
{ item="Base.ClosedUmbrellaBlack",  basePrice=10, tags={"Clothing", "Tool"}, stockRange={min=1, max=5} },

-- Rags (Craftable Trash)
{ item="Base.RippedSheets",     basePrice=0.1, tags={"Material", "Medical", "Junk"}, stockRange={min=10, max=100} },
{ item="Base.RippedSheetsDirty",basePrice=0,   tags={"Trash"}, stockRange={min=0, max=0} },
{ item="Base.Doily",            basePrice=1,   tags={"Decor", "Junk"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 5. MUSICAL INSTRUMENTS (Boredom & Weapons)
-- =============================================================================
-- Larger instruments are decent blunt weapons.
{ item="Base.GuitarAcoustic",       basePrice=30, tags={"Music", "Weapon", "Fun"}, stockRange={min=1, max=3} },
{ item="Base.GuitarElectric",       basePrice=45, tags={"Music", "Weapon", "Luxury"}, stockRange={min=1, max=3} },
{ item="Base.GuitarElectricBass",   basePrice=45, tags={"Music", "Weapon", "Luxury"}, stockRange={min=1, max=3} },
{ item="Base.Banjo",                basePrice=35, tags={"Music", "Weapon", "Fun"}, stockRange={min=1, max=3} },
{ item="Base.Keytar",               basePrice=50, tags={"Music", "Weapon", "Luxury", "Rare"}, stockRange={min=0, max=1} },
{ item="Base.Saxophone",            basePrice=40, tags={"Music", "Weapon", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.Violin",               basePrice=30, tags={"Music", "Weapon", "Luxury"}, stockRange={min=1, max=3} },

-- Small Instruments (Pocket Happiness)
{ item="Base.Harmonica",            basePrice=15, tags={"Music", "Fun", "Common"}, stockRange={min=1, max=5} },
{ item="Base.Flute",                basePrice=15, tags={"Music", "Fun", "Common"}, stockRange={min=1, max=5} },
{ item="Base.Trumpet",              basePrice=25, tags={"Music", "Fun"}, stockRange={min=1, max=3} },

-- Whistles (Tactical Zombie Luring)
{ item="Base.Whistle",              basePrice=5,  tags={"Music", "Tool", "Tactical"}, stockRange={min=2, max=10} },
{ item="Base.Whistle_Bone",         basePrice=2,  tags={"Music", "Tool", "Tactical", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.Hat_Cowboy_Plastic",   basePrice=5,  tags={"Music", "Clothing", "Junk"}, stockRange={min=0, max=2} }, -- It has a whistle

-- Accessories
{ item="Base.GuitarPick",           basePrice=1,  tags={"Music", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.Drumstick",            basePrice=2,  tags={"Music", "Weapon", "Junk"}, stockRange={min=2, max=10} },
{ item="Base.TuningFork",           basePrice=5,  tags={"Music", "Tool"}, stockRange={min=1, max=5} },

-- Improvised Weapons from Household items
{ item="Base.Spear_Plunger",        basePrice=8,  tags={"Weapon", "Spear", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Broom_Twig",           basePrice=2,  tags={"Cleaning", "Junk"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Household Registry Complete.")
