require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
-- =============================================================================
-- 1. SKILL BOOKS (Progression Multipliers)
-- =============================================================================
-- TIER 1 (Levels 1-2): Essential basics.
{ item="Base.BookFarming1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookAiming1", basePrice=50, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookHusbandry1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookBlacksmith1", basePrice=60, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookButchering1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookCarpentry1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookCarving1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookCooking1", basePrice=30, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookElectrician1", basePrice=50, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookFirstAid1", basePrice=30, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookFishing1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookForaging1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookGlassmaking1", basePrice=60, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookFlintKnapping1", basePrice=50, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookLongBlade1", basePrice=50, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookMaintenance1", basePrice=60, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} }, -- Very useful
{ item="Base.BookMasonry1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookMechanic1", basePrice=50, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookPottery1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookReloading1", basePrice=50, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookTailoring1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookTracking1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookTrapping1", basePrice=40, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },
{ item="Base.BookMetalWelding1", basePrice=50, tags={"Literature", "SkillBook", "Common"}, stockRange={min=2, max=5} },

-- TIER 2 (Levels 3-4): Getting serious.
{ item="Base.BookFarming2",       basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookAiming2",        basePrice=100,tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookHusbandry2",     basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookBlacksmith2",    basePrice=120,tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookButchering2",    basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookCarpentry2",     basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookCarving2",       basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookCooking2",       basePrice=60, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookElectrician2",   basePrice=100,tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookFirstAid2",      basePrice=60, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookFishing2",       basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookForaging2",      basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookGlassmaking2",   basePrice=120,tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookFlintKnapping2", basePrice=100,tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookLongBlade2",     basePrice=100,tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookMaintenance2",   basePrice=120,tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookMasonry2",       basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookMechanic2",      basePrice=100,tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookPottery2",       basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookReloading2",     basePrice=100,tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookTailoring2",     basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookTracking2",      basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookTrapping2",      basePrice=80, tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.BookMetalWelding2",  basePrice=100,tags={"Literature", "SkillBook", "Uncommon"}, stockRange={min=1, max=3} },

-- TIER 3 (Levels 5-6): The Grind Breakers. High demand.
{ item="Base.BookFarming3",       basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookAiming3",        basePrice=180, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookHusbandry3",     basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookBlacksmith3",    basePrice=200, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookButchering3",    basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookCarpentry3",     basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookCarving3",       basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookCooking3",       basePrice=120, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookElectrician3",   basePrice=180, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookFirstAid3",      basePrice=120, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookFishing3",       basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookForaging3",      basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookGlassmaking3",   basePrice=200, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookFlintKnapping3", basePrice=180, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookLongBlade3",     basePrice=180, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookMaintenance3",   basePrice=200, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookMasonry3",       basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookMechanic3",      basePrice=180, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookPottery3",       basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookReloading3",     basePrice=180, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookTailoring3",     basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookTracking3",      basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookTrapping3",      basePrice=150, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },
{ item="Base.BookMetalWelding3",  basePrice=180, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=2} },

-- TIER 4 (Levels 7-8): Master Class.
{ item="Base.BookFarming4",       basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookAiming4",        basePrice=350, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookHusbandry4",     basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookBlacksmith4",    basePrice=400, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookButchering4",    basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookCarpentry4",     basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookCarving4",       basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookCooking4",       basePrice=200, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookElectrician4",   basePrice=350, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookFirstAid4",      basePrice=200, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookFishing4",       basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookForaging4",      basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookGlassmaking4",   basePrice=400, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookFlintKnapping4", basePrice=350, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookLongBlade4",     basePrice=350, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookMaintenance4",   basePrice=400, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookMasonry4",       basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookMechanic4",      basePrice=350, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookPottery4",       basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookReloading4",     basePrice=350, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookTailoring4",     basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookTracking4",      basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookTrapping4",      basePrice=300, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },
{ item="Base.BookMetalWelding4",  basePrice=350, tags={"Literature", "SkillBook", "Rare"}, stockRange={min=1, max=1} },

-- TIER 5 (Levels 9-10): Legend Status.
{ item="Base.BookFarming5",       basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookAiming5",        basePrice=600, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookHusbandry5",     basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookBlacksmith5",    basePrice=700, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookButchering5",    basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookCarpentry5",     basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookCarving5",       basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookCooking5",       basePrice=400, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookElectrician5",   basePrice=600, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookFirstAid5",      basePrice=400, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookFishing5",       basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookForaging5",      basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookGlassmaking5",   basePrice=700, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookFlintKnapping5", basePrice=600, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookLongBlade5",     basePrice=600, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookMaintenance5",   basePrice=700, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookMasonry5",       basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookMechanic5",      basePrice=600, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookPottery5",       basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookReloading5",     basePrice=600, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookTailoring5",     basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookTracking5",      basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookTrapping5",      basePrice=500, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.BookMetalWelding5",  basePrice=600, tags={"Literature", "SkillBook", "Legendary"}, stockRange={min=0, max=1} },

-- =============================================================================
-- 2. RECIPE MAGAZINES (The Knowledge Economy)
-- =============================================================================
-- These are one-time reads that unlock mechanics. Extremely valuable.

-- THE HOLY GRAIL (Essentials)
{ item="Base.ElectronicsMag4",    basePrice=1000, tags={"Literature", "Recipe", "Legendary"}, stockRange={min=0, max=1} }, -- Generator
{ item="Base.HerbalistMag",       basePrice=800,  tags={"Literature", "Recipe", "Legendary"}, stockRange={min=0, max=1} }, -- Herbalist (Poison detection)

-- B42 CRAFTING & SMITHING (High Value Meta)
{ item="Base.SmithingMag1",       basePrice=250, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Tools
{ item="Base.SmithingMag2",       basePrice=250, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Cookware
{ item="Base.SmithingMag3",       basePrice=250, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Farming Tools
{ item="Base.SmithingMag4",       basePrice=250, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Small Tools
{ item="Base.SmithingMag5",       basePrice=300, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Blunt Weapons
{ item="Base.SmithingMag6",       basePrice=500, tags={"Literature", "Recipe", "Legendary"}, stockRange={min=0, max=1} }, -- Advanced Forge (Crucial)
{ item="Base.SmithingMag7",       basePrice=350, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Blades
{ item="Base.SmithingMag8",       basePrice=350, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Knives
{ item="Base.SmithingMag9",       basePrice=400, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Furnaces
{ item="Base.SmithingMag10",      basePrice=450, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Smelting
{ item="Base.SmithingMag11",      basePrice=300, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Maces
{ item="Base.MetalworkMag1",      basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Walls
{ item="Base.MetalworkMag2",      basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Furniture
{ item="Base.MetalworkMag3",      basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Fences
{ item="Base.MetalworkMag4",      basePrice=150, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Sheets

-- ARMOR & WEAPON MODS (Survival Combat)
{ item="Base.ArmorMag1",          basePrice=300, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Tire Armor
{ item="Base.ArmorMag2",          basePrice=250, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Bone/Wood
{ item="Base.ArmorMag3",          basePrice=350, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Scrap Metal
{ item="Base.ArmorMag4",          basePrice=400, tags={"Literature", "Recipe", "Legendary"}, stockRange={min=0, max=1} }, -- Plate Armor
{ item="Base.ArmorMag5",          basePrice=350, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Iron Age
{ item="Base.ArmorMag6",          basePrice=300, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Spiked
{ item="Base.ArmorMag7",          basePrice=500, tags={"Literature", "Recipe", "Legendary"}, stockRange={min=0, max=1} }, -- Bulletproof
{ item="Base.WeaponMag1",         basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Bone Weapons
{ item="Base.WeaponMag2",         basePrice=300, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Gas Masks/Filters
{ item="Base.WeaponMag3",         basePrice=200, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Prison
{ item="Base.WeaponMag4",         basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Barbed Wire
{ item="Base.WeaponMag5",         basePrice=200, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Street
{ item="Base.WeaponMag6",         basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Peasants
{ item="Base.WeaponMag7",         basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Bat Carving

-- SPECIALIZED CRAFTING (Glass/Primitive/Explosives)
{ item="Base.GlassmakingMag1",    basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} },
{ item="Base.GlassmakingMag2",    basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} },
{ item="Base.GlassmakingMag3",    basePrice=250, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Bottles/Jars
{ item="Base.PrimitiveToolMag1",  basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.PrimitiveToolMag2",  basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.PrimitiveToolMag3",  basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.EngineerMagazine1",  basePrice=300, tags={"Literature", "Recipe", "Rare", "Illegal"}, stockRange={min=0, max=1} }, -- Noise Makers
{ item="Base.EngineerMagazine2",  basePrice=350, tags={"Literature", "Recipe", "Rare", "Illegal"}, stockRange={min=0, max=1} }, -- Smoke/Gas
{ item="Base.EngineerMagazine3",  basePrice=500, tags={"Literature", "Recipe", "Legendary", "Illegal"}, stockRange={min=0, max=1} }, -- Pipe Bombs

-- MECHANICS & ELECTRONICS
{ item="Base.MechanicMag1",       basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Standard
{ item="Base.MechanicMag2",       basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Commercial
{ item="Base.MechanicMag3",       basePrice=250, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Performance
{ item="Base.ElectronicsMag1",    basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Remote
{ item="Base.ElectronicsMag2",    basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Timer
{ item="Base.ElectronicsMag3",    basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Sensors
{ item="Base.ElectronicsMag5",    basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Lights
{ item="Base.RadioMag1",          basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.RadioMag2",          basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.RadioMag3",          basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },

-- FARMING, FISHING & TRAPPING
{ item="Base.FarmingMag1",        basePrice=100, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Mildew
{ item="Base.FarmingMag2",        basePrice=100, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Cure
{ item="Base.FarmingMag3",        basePrice=120, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Flowers
{ item="Base.FarmingMag4",        basePrice=120, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Scarecrow
{ item="Base.FarmingMag5",        basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Jarring (Food Preservation)
{ item="Base.FarmingMag6",        basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Crops
{ item="Base.FarmingMag7",        basePrice=150, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Veggies
{ item="Base.FarmingMag8",        basePrice=120, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Herbs
{ item="Base.FarmingMag9",        basePrice=150, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Medicinal
{ item="Base.HempMag1",           basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Hemp
{ item="Base.FishingMag1",        basePrice=120, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Rods
{ item="Base.FishingMag2",        basePrice=150, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Nets
{ item="Base.HuntingMag1",        basePrice=120, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Snare
{ item="Base.HuntingMag2",        basePrice=150, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Crate/Stick
{ item="Base.HuntingMag3",        basePrice=150, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Cage/Box
{ item="Base.HuntingMag4",        basePrice=100, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Trophy

-- TAILORING & COOKING
{ item="Base.TailoringMag1",      basePrice=120, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.TailoringMag2",      basePrice=100, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.TailoringMag3",      basePrice=120, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.TailoringMag4",      basePrice=150, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Leather
{ item="Base.TailoringMag5",      basePrice=150, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Cowboy
{ item="Base.TailoringMag6",      basePrice=150, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Pads
{ item="Base.TailoringMag7",      basePrice=200, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Backpacks (High Value)
{ item="Base.TailoringMag8",      basePrice=180, tags={"Literature", "Recipe", "Rare"}, stockRange={min=0, max=1} }, -- Gear
{ item="Base.TailoringMag9",      basePrice=250, tags={"Literature", "Recipe", "Legendary"}, stockRange={min=0, max=1} }, -- Large Backpacks
{ item="Base.TailoringMag10",     basePrice=120, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.KnittingMag1",       basePrice=100, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.KnittingMag2",       basePrice=100, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.CookingMag1",        basePrice=80,  tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Cake/Pie
{ item="Base.CookingMag2",        basePrice=100, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} }, -- Bread (Useful)
{ item="Base.CookingMag3",        basePrice=80,  tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.CookingMag4",        basePrice=80,  tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.CookingMag5",        basePrice=80,  tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.CookingMag6",        basePrice=80,  tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },

-- MISC SCHEMATICS (Random Unlocks)
{ item="Base.TrickMag1",          basePrice=50,  tags={"Literature", "Recipe", "Common"}, stockRange={min=0, max=1} },
{ item="Base.TrickMag2",          basePrice=50,  tags={"Literature", "Recipe", "Common"}, stockRange={min=0, max=1} },
{ item="Base.KeyMag1",            basePrice=100, tags={"Literature", "Recipe", "Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.ArmorSchematic",     basePrice=150, tags={"Literature", "Recipe", "Random"}, stockRange={min=0, max=2} },
{ item="Base.CookwareSchematic",  basePrice=100, tags={"Literature", "Recipe", "Random"}, stockRange={min=0, max=2} },
{ item="Base.ExplosiveSchematic", basePrice=400, tags={"Literature", "Recipe", "Random"}, stockRange={min=0, max=1} },
{ item="Base.MeleeWeaponSchematic",basePrice=150,tags={"Literature", "Recipe", "Random"}, stockRange={min=0, max=2} },
{ item="Base.RecipeClipping",     basePrice=50,  tags={"Literature", "Recipe", "Random"}, stockRange={min=0, max=3} },
{ item="Base.SewingPattern",      basePrice=80,  tags={"Literature", "Recipe", "Random"}, stockRange={min=0, max=3} },
{ item="Base.SurvivalSchematic",  basePrice=200, tags={"Literature", "Recipe", "Random"}, stockRange={min=0, max=1} },
{ item="Base.BSToolsSchematic",   basePrice=200, tags={"Literature", "Recipe", "Random"}, stockRange={min=0, max=1} },

-- =============================================================================
-- 3. LEISURE (Sanity & Boredom Management)
-- =============================================================================

-- THE LEGEND
{ item="Base.HottieZ",            basePrice=60,  tags={"Literature", "Leisure", "Luxury"}, stockRange={min=1, max=5} }, -- Peak boredom reduction
{ item="Base.HottieZ_New",        basePrice=60,  tags={"Literature", "Leisure", "Luxury"}, stockRange={min=1, max=5} },

-- HARDCOVERS / LEATHERBOUND (Durable, High Boredom Reduction)
{ item="Base.Book",               basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=2, max=10} },
{ item="Base.Book_Bible",         basePrice=25, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
-- Note: Grouping all genre hardcovers under generic Leisure price/tags to save space
-- but explicitly listing IDs as requested.
{ item="Base.Book_AdventureNonFiction", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Art", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Baseball", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Biography", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Business", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Childs", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Cinema", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Classic", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_ClassicFiction", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_ClassicNonfiction", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Computer", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_CrimeFiction", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Fantasy", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Farming", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Fashion", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Fiction", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_GeneralNonFiction", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_GeneralReference", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Golf", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_History", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Horror", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Legal", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_LiteraryFiction", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Medical", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Military", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_MilitaryHistory", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Music", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Nature", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Occult", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Philosophy", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Policing", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Politics", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Quackery", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Religion", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Rich", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Romance", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_SadNonFiction", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_SchoolTextbook", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_SciFi", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Science", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Sports", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Thriller", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Travel", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },
{ item="Base.Book_Western", basePrice=20, tags={"Literature", "Leisure"}, stockRange={min=1, max=3} },

-- LEATHERBOUND (Higher Value)
{ item="Base.BookFancy_Classic", basePrice=30, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_ClassicFiction", basePrice=30, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_ClassicNonfiction", basePrice=30, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_History", basePrice=30, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_Legal", basePrice=30, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_Medical", basePrice=30, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_MilitaryHistory", basePrice=30, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_Occult", basePrice=30, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_Philosophy", basePrice=30, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_Politics", basePrice=30, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_Religion", basePrice=30, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_Bible", basePrice=35, tags={"Literature", "Leisure", "Luxury"}, stockRange={min=0, max=2} },

-- PAPERBACKS (Cheap/Fuel)
{ item="Base.Paperback",          basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=5, max=20} },
{ item="Base.Paperback_Bible",    basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
-- All genres priced same
{ item="Base.Paperback_AdventureNonFiction", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Art", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Baseball", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Biography", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Business", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Childs", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Cinema", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Classic", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_ClassicFiction", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_ClassicNonfiction", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Computer", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Conspiracy", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_CrimeFiction", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Diet", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Fantasy", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Fashion", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Fiction", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Golf", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Hass", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_History", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Horror", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Legal", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_LiteraryFiction", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Medical", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Military", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_MilitaryHistory", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Music", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Nature", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_NewAge", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Occult", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Philosophy", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Play", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Policing", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Politics", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Poor", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Quackery", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Quigley", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Relationship", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Religion", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Rich", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Romance", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_SadNonFiction", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Scary", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_SciFi", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Science", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_SelfHelp", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Sexy", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Sports", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Teens", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Thriller", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Travel", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_TrueCrime", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },
{ item="Base.Paperback_Western", basePrice=5, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=2, max=5} },

-- MAGAZINES & NEWSPAPERS (Generic / Light Reading)
{ item="Base.Magazine",           basePrice=2, tags={"Literature", "Leisure", "Fuel", "Junk"}, stockRange={min=5, max=30} },
{ item="Base.MagazineCrossword",  basePrice=3, tags={"Literature", "Leisure"}, stockRange={min=2, max=10} },
{ item="Base.MagazineWordsearch", basePrice=3, tags={"Literature", "Leisure"}, stockRange={min=2, max=10} },
{ item="Base.TVMagazine",         basePrice=1, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=5, max=20} },
{ item="Base.Newspaper",          basePrice=1, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=10, max=50} },
{ item="Base.Newspaper_New",      basePrice=1, tags={"Literature", "Leisure", "Fuel"}, stockRange={min=10, max=50} },

-- =============================================================================
-- 4. CARTOGRAPHY (Maps)
-- =============================================================================
{ item="Base.Map",                basePrice=10, tags={"Literature", "Cartography", "Common"}, stockRange={min=2, max=10} },
{ item="Base.LouisvilleMap1",     basePrice=25, tags={"Literature", "Cartography", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.LouisvilleMap2",     basePrice=25, tags={"Literature", "Cartography", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.LouisvilleMap3",     basePrice=25, tags={"Literature", "Cartography", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.LouisvilleMap4",     basePrice=25, tags={"Literature", "Cartography", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.LouisvilleMap5",     basePrice=25, tags={"Literature", "Cartography", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.LouisvilleMap6",     basePrice=25, tags={"Literature", "Cartography", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.LouisvilleMap7",     basePrice=25, tags={"Literature", "Cartography", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.LouisvilleMap8",     basePrice=25, tags={"Literature", "Cartography", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.LouisvilleMap9",     basePrice=25, tags={"Literature", "Cartography", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.MuldraughMap",       basePrice=15, tags={"Literature", "Cartography", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.RiversideMap",       basePrice=15, tags={"Literature", "Cartography", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.RosewoodMap",        basePrice=15, tags={"Literature", "Cartography", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.WestpointMap",       basePrice=15, tags={"Literature", "Cartography", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.MarchRidgeMap",      basePrice=15, tags={"Literature", "Cartography", "Uncommon"}, stockRange={min=1, max=3} },
})