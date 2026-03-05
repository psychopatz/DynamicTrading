require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. CLEANING & HYGIENE (Disease Prevention)
-- =============================================================================
-- Cleaning
{ item="Base.Soap2", basePrice=25, tags={"Tool.Cleaning.Hygiene", "Rarity.Common"}, stockRange={min=2, max=10} },
-- (Consolidated in DT_ContainersFluid.lua)
{ item="Base.BathTowel", basePrice=25, tags={"Clothing.Accessory.Towel", "Tool.Cleaning.Hygiene", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.DishCloth", basePrice=10, tags={"Resource.Material.Cloth", "Tool.Cleaning.Hygiene", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.Sponge", basePrice=8, tags={"Tool.Cleaning.Hygiene", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.Broom", basePrice=25, tags={"Weapon.Melee.LongBlunt", "Tool.Cleaning.Utility", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Mop", basePrice=30, tags={"Weapon.Melee.LongBlunt", "Tool.Cleaning.Utility", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Plunger", basePrice=15, tags={"Weapon.Melee.ShortBlunt", "Tool.Cleaning.Utility", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.ToiletBrush", basePrice=5, tags={"Weapon.Melee.ShortBlunt", "Tool.Cleaning.Utility", "Rarity.Common"}, stockRange={min=1, max=3} },
-- Wet items
{ item="Base.BathTowelWet",     basePrice=5,  tags={"Tool.Cleaning.Hygiene", "Quality.Waste"}, stockRange={min=0, max=0} },
{ item="Base.DishClothWet",     basePrice=2,  tags={"Tool.Cleaning.Hygiene", "Quality.Waste"}, stockRange={min=0, max=0} },

-- =============================================================================
-- 2. FIRE SAFETY & FUEL
-- =============================================================================
{ item="Base.Extinguisher",     basePrice=150, tags={"Tool.General.Safety", "Quality.Sterile", "Rarity.Uncommon"}, stockRange={min=1, max=3} }, -- Saves bases
{ item="Base.LighterFluid",     basePrice=35, tags={"Resource.Fuel.Igniter", "Rarity.Common"}, stockRange={min=2, max=10} }, -- Accelerant
{ item="Base.BBQStarterFluid",  basePrice=35, tags={"Resource.Fuel.Igniter", "Rarity.Common"}, stockRange={min=2, max=10} },

-- =============================================================================
-- 3. WRITING & MAP TOOLS (Scholastic)
-- =============================================================================
-- Essential for map marking, but very common loot.
{ item="Base.Pencil",           basePrice=2,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=10, max=50} },
{ item="Base.Pen",              basePrice=2,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=10, max=50} },
{ item="Base.BluePen",          basePrice=2,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.RedPen",           basePrice=2,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.GreenPen",         basePrice=2,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Eraser",           basePrice=5,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Crayons",          basePrice=15, tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=5, max=20} },

-- Premium Writing
{ item="Base.PenMultiColor",    basePrice=10, tags={"Misc.Scholastic", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
{ item="Base.PenFancy",         basePrice=25, tags={"Misc.Scholastic", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=3} },

-- Collector Items (Spiffo)
{ item="Base.PenSpiffo",        basePrice=50, tags={"Misc.Scholastic", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
{ item="Base.PencilSpiffo",     basePrice=50, tags={"Misc.Scholastic", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },

-- Markers (Bold map markings)
{ item="Base.MarkerBlack",      basePrice=8,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.MarkerBlue",       basePrice=8,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.MarkerRed",        basePrice=8,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.MarkerGreen",      basePrice=8,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=2, max=10} },

-- =============================================================================
-- 4. HOUSEHOLD TOOLS & MISC
-- =============================================================================
{ item="Base.Scissors",         basePrice=45, tags={"Tool.Crafting.Tailor", "Rarity.Common"}, stockRange={min=2, max=10} }, -- Essential for Tailoring
{ item="Base.ScissorsBlunt",    basePrice=25, tags={"Tool.Crafting.Tailor", "Quality.Waste"}, stockRange={min=1, max=5} },
{ item="Base.ScissorsForged",   basePrice=35, tags={"Tool.Crafting.Tailor", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
{ item="Base.StraightRazor",    basePrice=45, tags={"Weapon.Melee.SmallBlade", "Tool.Cleaning.Hygiene", "Rarity.Uncommon"}, stockRange={min=1, max=5} }, -- Good short blade
{ item="Base.LetterOpener",     basePrice=15, tags={"Weapon.Melee.SmallBlade", "Quality.Waste"}, stockRange={min=1, max=5} },
{ item="Base.AlarmClock2",      basePrice=25, tags={"Electronics.Utility.Clock", "Rarity.Common"}, stockRange={min=2, max=10} }, -- Trap component / Waking up
{ item="Base.RatPoison",        basePrice=60, tags={"Resource.Material.Chemical", "Origin.Healthcare", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
{ item="Base.MagnifyingGlass",  basePrice=35, tags={"Tool.General.Survival", "Theme.Survival", "Rarity.Rare"}, stockRange={min=1, max=3} }, -- Foraging light fire
{ item="Base.Calculator",       basePrice=25, tags={"Electronics.Scholastic", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Clipboard",        basePrice=10, tags={"Misc.Scholastic", "Quality.Waste"}, stockRange={min=1, max=5} },
{ item="Base.CorrectionFluid",  basePrice=5,  tags={"Misc.Scholastic", "Quality.Waste"}, stockRange={min=1, max=5} },

-- Weather Protection (High value in Winter/Rain)
{ item="Base.UmbrellaBlack",        basePrice=45, tags={"Clothing.Accessory.Umbrella", "Theme.Seasonal", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.UmbrellaBlue",         basePrice=45, tags={"Clothing.Accessory.Umbrella", "Theme.Seasonal", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.UmbrellaRed",          basePrice=45, tags={"Clothing.Accessory.Umbrella", "Theme.Seasonal", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.UmbrellaWhite",        basePrice=45, tags={"Clothing.Accessory.Umbrella", "Theme.Seasonal", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.UmbrellaTINTED",       basePrice=60, tags={"Clothing.Accessory.Umbrella", "Theme.Seasonal", "Quality.Luxury"}, stockRange={min=1, max=5} },
{ item="Base.ClosedUmbrellaBlack",  basePrice=45, tags={"Weapon.Melee.Spear", "Quality.Waste"}, stockRange={min=1, max=5} },

-- Rags (Craftable Trash)
-- (Consolidated in DT_Medical.lua)
{ item="Base.Doily",            basePrice=2,   tags={"Misc.Decor", "Rarity.Common"}, stockRange={min=1, max=5} },

-- =============================================================================
-- Musical Instruments (Large - Blunt Weapons)
-- =============================================================================
{ item="Base.GuitarAcoustic",       basePrice=150, tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.GuitarElectric",       basePrice=250, tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.GuitarElectricBass",   basePrice=260, tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.Banjo",                basePrice=130, tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.Keytar",               basePrice=450, tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Legendary"}, stockRange={min=0, max=1} },
{ item="Base.Saxophone",            basePrice=300, tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.Violin",               basePrice=280, tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Rare"}, stockRange={min=0, max=1} },

-- Small Instruments (Pocket Happiness)
{ item="Base.Harmonica",            basePrice=45, tags={"Literature.Music.Instrument", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Flute",                basePrice=35, tags={"Literature.Music.Instrument", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Trumpet",              basePrice=220, tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Rare"}, stockRange={min=1, max=3} },

-- Whistles (Tactical Zombie Luring)
{ item="Base.Whistle",              basePrice=25,  tags={"Tool.General", "Theme.Combat", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.Whistle_Bone",         basePrice=15,  tags={"Tool.General", "Theme.Survival", "Origin.Nomad"}, stockRange={min=1, max=5} },
{ item="Base.Hat_Cowboy_Plastic",   basePrice=15,  tags={"Clothing.Head.Hat", "Literature.Music.Fun"}, stockRange={min=0, max=2} }, -- It has a whistle

-- Accessories
{ item="Base.GuitarPick",           basePrice=2,  tags={"Literature.Music.Accessory", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Drumstick",            basePrice=15, tags={"Weapon.Melee.ShortBlunt", "Literature.Music.Instrument", "Quality.Waste"}, stockRange={min=2, max=10} },
{ item="Base.TuningFork",           basePrice=35, tags={"Literature.Audio", "Literature.Music.Accessory", "Rarity.Uncommon"}, stockRange={min=1, max=5} },

-- Improvised Weapons from Household items
{ item="Base.Spear_Plunger",        basePrice=25, tags={"Weapon.Melee.Spear", "Quality.Waste"}, stockRange={min=0, max=5} },
{ item="Base.Broom_Twig",           basePrice=5,  tags={"Resource.Material.Wood", "Quality.Waste"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Household Registry Complete \n.")
