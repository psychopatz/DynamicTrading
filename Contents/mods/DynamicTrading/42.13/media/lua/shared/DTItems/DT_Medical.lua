require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
-- =============================================================================
-- 1. PHARMACEUTICALS (Pills & Life Saving)
-- =============================================================================
{ item="Base.Antibiotics", basePrice=50, tags={"Medical", "Pill", "Survival"}, stockRange={min=1, max=5} }, -- Cures infection
{ item="Base.AntibioticsBox", basePrice=100,tags={"Medical", "Pill", "Survival", "Stockpile"}, stockRange={min=0, max=2} },
{ item="Base.Pills", basePrice=20, tags={"Medical", "Pill"}, stockRange={min=2, max=10} }, -- Painkillers
{ item="Base.PillsBeta", basePrice=25, tags={"Medical", "Pill", "Combat"}, stockRange={min=2, max=10} }, -- Beta Blockers (Panic)
{ item="Base.PillsAntiDep", basePrice=20, tags={"Medical", "Pill"}, stockRange={min=2, max=10} }, -- Antidepressants
{ item="Base.PillsSleepingTablets", basePrice=25, tags={"Medical", "Pill"}, stockRange={min=2, max=10} }, -- Sleep
{ item="Base.PillsVitamins", basePrice=15, tags={"Medical", "Pill"}, stockRange={min=2, max=10} }, -- Fatigue
-- =============================================================================
-- 2. WOUND CARE (Bandages & Disinfectants)
-- =============================================================================
-- Bandages
{ item="Base.Bandage",              basePrice=5,  tags={"Medical", "Common"}, stockRange={min=5, max=20} },
{ item="Base.BandageBox",           basePrice=25, tags={"Medical", "Stockpile"}, stockRange={min=1, max=5} },
{ item="Base.AlcoholBandage",       basePrice=8,  tags={"Medical", "Sterile"}, stockRange={min=2, max=10} }, -- Sterilized
{ item="Base.Bandaid",              basePrice=1,  tags={"Medical", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.AdhesiveBandageBox",   basePrice=5,  tags={"Medical", "Junk"}, stockRange={min=1, max=5} },

-- Disinfectants
{ item="Base.Disinfectant",         basePrice=20, tags={"Medical", "Liquid"}, stockRange={min=1, max=5} },
{ item="Base.AlcoholWipes",         basePrice=5,  tags={"Medical", "Common"}, stockRange={min=2, max=10} },
{ item="Base.AlcoholedCottonBalls", basePrice=2,  tags={"Medical"}, stockRange={min=2, max=10} },
{ item="Base.CottonBalls",          basePrice=1,  tags={"Medical"}, stockRange={min=5, max=20} },
{ item="Base.CottonBallsBox",       basePrice=5,  tags={"Medical"}, stockRange={min=1, max=5} },

-- Improvised
{ item="Base.RippedSheets",         basePrice=0.5,tags={"Medical", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.AlcoholRippedSheets",  basePrice=2,  tags={"Medical"}, stockRange={min=5, max=20} },
{ item="Base.DenimStrips",          basePrice=1,  tags={"Medical", "Material"}, stockRange={min=5, max=20} },
{ item="Base.LeatherStrips",        basePrice=2,  tags={"Medical", "Material"}, stockRange={min=5, max=20} },

-- Dirty (Trash)
{ item="Base.RippedSheetsDirty",    basePrice=0,  tags={"Trash"}, stockRange={min=0, max=0} },
{ item="Base.BandageDirty",         basePrice=0,  tags={"Trash"}, stockRange={min=0, max=0} },

-- =============================================================================
-- 3. SURGICAL TOOLS & DEEP WOUNDS
-- =============================================================================
{ item="Base.SutureNeedle",         basePrice=15, tags={"Medical", "Tool", "Survival"}, stockRange={min=1, max=5} },
{ item="Base.SutureNeedleBox",      basePrice=50, tags={"Medical", "Stockpile"}, stockRange={min=0, max=2} },
{ item="Base.SutureNeedleHolder",   basePrice=10, tags={"Medical", "Tool"}, stockRange={min=1, max=3} },
{ item="Base.Forceps_Forged",       basePrice=8,  tags={"Medical", "Tool"}, stockRange={min=1, max=3} },
{ item="Base.Tweezers",             basePrice=5,  tags={"Medical", "Tool"}, stockRange={min=1, max=5} },
{ item="Base.Tweezers_Forged",      basePrice=5,  tags={"Medical", "Tool"}, stockRange={min=1, max=5} },
{ item="Base.Scalpel",              basePrice=10, tags={"Medical", "Tool", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.ScissorsBluntMedical", basePrice=10, tags={"Medical", "Tool"}, stockRange={min=1, max=5} }, -- Medical Shears

-- =============================================================================
-- 4. HERBAL MEDICINE (Natural Remedies)
-- =============================================================================
-- Herbs
{ item="Base.BlackSage",            basePrice=5,  tags={"Medical", "Herb"}, stockRange={min=1, max=5} }, -- Pain
{ item="Base.CommonMallow",         basePrice=5,  tags={"Medical", "Herb"}, stockRange={min=1, max=5} }, -- Cold
{ item="Base.Ginseng",              basePrice=15, tags={"Medical", "Herb", "Energy"}, stockRange={min=1, max=5} }, -- Endurance
{ item="Base.LemonGrass",           basePrice=20, tags={"Medical", "Herb", "Survival"}, stockRange={min=1, max=5} }, -- Poison Cure (Essential)
{ item="Base.Plantain",             basePrice=8,  tags={"Medical", "Herb"}, stockRange={min=1, max=5} }, -- Wound
{ item="Base.Comfrey",              basePrice=10, tags={"Medical", "Herb"}, stockRange={min=1, max=5} }, -- Bone
{ item="Base.WildGarlic2",          basePrice=8,  tags={"Medical", "Herb"}, stockRange={min=1, max=5} }, -- Infection

-- Dried Herbs (Better Shelf Life)
{ item="Base.BlackSageDried",       basePrice=8,  tags={"Medical", "Herb"}, stockRange={min=1, max=5} },
{ item="Base.CommonMallowDried",    basePrice=8,  tags={"Medical", "Herb"}, stockRange={min=1, max=5} },
{ item="Base.PlantainDried",        basePrice=10, tags={"Medical", "Herb"}, stockRange={min=1, max=5} },
{ item="Base.ComfreyDried",         basePrice=12, tags={"Medical", "Herb"}, stockRange={min=1, max=5} },
{ item="Base.WildGarlicDried",      basePrice=10, tags={"Medical", "Herb"}, stockRange={min=1, max=5} },

-- Poultices (Processed)
{ item="Base.ComfreyCataplasm",     basePrice=25, tags={"Medical", "Herb", "Processed"}, stockRange={min=0, max=3} }, -- Bone healing
{ item="Base.PlantainCataplasm",    basePrice=20, tags={"Medical", "Herb", "Processed"}, stockRange={min=0, max=3} },
{ item="Base.WildGarlicCataplasm",  basePrice=20, tags={"Medical", "Herb", "Processed"}, stockRange={min=0, max=3} },

-- Tools
{ item="Base.MortarPestle",         basePrice=10, tags={"Medical", "Tool"}, stockRange={min=1, max=3} },
{ item="Base.CeramicMortarandPestle",basePrice=12,tags={"Medical", "Tool"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 5. KITS & MISC
-- =============================================================================
{ item="Base.FirstAidKit",          basePrice=15, tags={"Medical", "Container"}, stockRange={min=1, max=3} }, -- Empty bag usually
{ item="Base.Splint",               basePrice=10, tags={"Medical", "Bone"}, stockRange={min=1, max=5} },
{ item="Base.Tissue",               basePrice=0.1,tags={"Medical", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.TissueBox",            basePrice=2,  tags={"Medical", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.Coldpack",             basePrice=5,  tags={"Medical", "Component"}, stockRange={min=1, max=5} },
{ item="Base.ColdpackBox",          basePrice=10, tags={"Medical", "Stockpile"}, stockRange={min=1, max=3} },

-- Medical Clothing
{ item="Base.Hat_SurgicalMask",     basePrice=5,  tags={"Clothing", "Medical"}, stockRange={min=2, max=10} },
{ item="Base.Gloves_Surgical",      basePrice=5,  tags={"Clothing", "Medical"}, stockRange={min=2, max=10} },
{ item="Base.Hat_SurgicalCap",      basePrice=2,  tags={"Clothing", "Medical"}, stockRange={min=2, max=10} },
{ item="Base.Stethoscope",          basePrice=5,  tags={"Medical", "Luxury"}, stockRange={min=0, max=2} }, -- Doctor RP item
})