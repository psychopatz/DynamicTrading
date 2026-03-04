require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. PHARMACEUTICALS (Pills & Life Saving)
-- =============================================================================
{ item="Base.Antibiotics", basePrice=250, tags={"Medical.Utility.Pill", "Origin.Medical", "Quality.Sterile"}, stockRange={min=1, max=5} }, -- Cures infection, Worth scaled 200-500
{ item="Base.AntibioticsBox", basePrice=1000,tags={"Medical.Utility.Pill", "Origin.Medical", "Quality.Sterile"}, stockRange={min=0, max=1} },
{ item="Base.Pills", basePrice=45, tags={"Medical.Utility.Pill", "Origin.Medical"}, stockRange={min=2, max=15} }, -- Painkillers
{ item="Base.PillsBeta", basePrice=60, tags={"Medical.Utility.Pill", "Origin.Medical"}, stockRange={min=2, max=15} }, -- Beta Blockers (Panic)
{ item="Base.PillsAntiDep", basePrice=45, tags={"Medical.Utility.Pill", "Origin.Medical"}, stockRange={min=2, max=15} }, -- Antidepressants
{ item="Base.PillsSleepingTablets", basePrice=60, tags={"Medical.Utility.Pill", "Origin.Medical"}, stockRange={min=2, max=15} }, -- Sleep
{ item="Base.PillsVitamins", basePrice=30, tags={"Medical.Utility.Pill", "Origin.Medical"}, stockRange={min=2, max=15} }, -- Fatigue
-- =============================================================================
-- 2. WOUND CARE (Bandages & Disinfectants)
-- =============================================================================
-- Bandages
{ item="Base.Bandage",              basePrice=15,  tags={"Medical.Utility.Bandage", "Origin.Medical"}, stockRange={min=5, max=25} },
{ item="Base.BandageBox",           basePrice=60,  tags={"Medical.Utility.Bandage", "Origin.Medical"}, stockRange={min=1, max=5} },
{ item="Base.AlcoholBandage",       basePrice=25,  tags={"Medical.Utility.Bandage", "Quality.Sterile"}, stockRange={min=2, max=12} }, 
{ item="Base.Bandaid",              basePrice=5,   tags={"Medical.Utility.Bandage", "Rarity.Common"}, stockRange={min=5, max=50} },
{ item="Base.AdhesiveBandageBox",   basePrice=20,  tags={"Medical.Utility.Bandage", "Rarity.Common"}, stockRange={min=1, max=7} },

-- Disinfectants
{ item="Base.Disinfectant",         basePrice=50,  tags={"Medical.Utility.Liquid", "Quality.Sterile"}, stockRange={min=1, max=7} },
{ item="Base.AlcoholWipes",         basePrice=15,  tags={"Medical.Utility.Cotton", "Quality.Sterile"}, stockRange={min=2, max=12} },
{ item="Base.AlcoholedCottonBalls", basePrice=7,   tags={"Medical.Utility.Cotton", "Quality.Sterile"}, stockRange={min=2, max=12} },
{ item="Base.CottonBalls",          basePrice=3,   tags={"Medical.Utility.Cotton", "Rarity.Common"}, stockRange={min=5, max=25} },
{ item="Base.CottonBallsBox",       basePrice=12,  tags={"Medical.Utility.Cotton", "Rarity.Common"}, stockRange={min=1, max=5} },

-- Improvised
-- Improvised
{ item="Base.RippedSheets",         basePrice=2,  tags={"Medical.Utility.Bandage", "Quality.Junk"}, stockRange={min=10, max=50} },
{ item="Base.AlcoholRippedSheets",  basePrice=7,  tags={"Medical.Utility.Bandage", "Quality.Sterile"}, stockRange={min=5, max=25} },
{ item="Base.DenimStrips",          basePrice=3,  tags={"Medical.Utility.Bandage", "Quality.Junk"}, stockRange={min=5, max=25} },
{ item="Base.LeatherStrips",        basePrice=5,  tags={"Medical.Utility.Bandage", "Quality.Junk"}, stockRange={min=5, max=25} },

-- Dirty (Trash)
{ item="Base.RippedSheetsDirty",    basePrice=0,  tags={"Junk.Trash", "Medical"}, stockRange={min=0, max=0} },
{ item="Base.BandageDirty",         basePrice=0,  tags={"Junk.Trash", "Medical"}, stockRange={min=0, max=0} },
{ item="Base.DenimStripsDirty",     basePrice=0,  tags={"Junk.Trash", "Medical"}, stockRange={min=0, max=0} },
{ item="Base.LeatherStripsDirty",   basePrice=0,  tags={"Junk.Trash", "Medical"}, stockRange={min=0, max=0} },

-- =============================================================================
-- 3. SURGICAL TOOLS & DEEP WOUNDS
-- =============================================================================
{ item="Base.SutureNeedle",         basePrice=75,  tags={"Medical.Surgical.Tool", "Quality.Sterile"}, stockRange={min=2, max=12} }, -- Scale 50-150
{ item="Base.SutureNeedleBox",      basePrice=300, tags={"Medical.Surgical.Tool", "Quality.Sterile"}, stockRange={min=0, max=2} },
{ item="Base.SutureNeedleHolder",   basePrice=110, tags={"Medical.Surgical.Tool", "Origin.Medical"}, stockRange={min=1, max=5} },
{ item="Base.Forceps_Forged",       basePrice=150, tags={"Medical.Surgical.Tool", "Origin.Medical"}, stockRange={min=1, max=5} },
{ item="Base.Tweezers",             basePrice=50,  tags={"Medical.Surgical.Tool", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.Tweezers_Forged",      basePrice=90,  tags={"Medical.Surgical.Tool", "Origin.Medical"}, stockRange={min=1, max=5} },
{ item="Base.Scalpel",              basePrice=130, tags={"Medical.Surgical.Tool", "Origin.Medical"}, stockRange={min=1, max=5} },
{ item="Base.ScissorsBluntMedical", basePrice=80,  tags={"Medical.Surgical.Tool", "Origin.Medical"}, stockRange={min=1, max=10} }, -- Medical Shears -- Medical Shears

-- =============================================================================
-- 4. HERBAL MEDICINE (Natural Remedies)
-- =============================================================================
-- Herbs
{ item="Base.BlackSage",            basePrice=15, tags={"Medical.Herb.Pain", "Theme.Survival"}, stockRange={min=1, max=7} },
{ item="Base.CommonMallow",         basePrice=15, tags={"Medical.Herb.Cold", "Theme.Survival"}, stockRange={min=1, max=7} },
{ item="Base.Ginseng",              basePrice=30, tags={"Medical.Herb.Energy", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=5} },
{ item="Base.LemonGrass",           basePrice=50, tags={"Medical.Herb.Survival", "Rarity.Rare"}, stockRange={min=1, max=5} },
{ item="Base.Plantain",             basePrice=20, tags={"Medical.Herb.Wound", "Theme.Survival"}, stockRange={min=1, max=7} },
{ item="Base.Comfrey",              basePrice=25, tags={"Medical.Herb.Bone", "Theme.Survival"}, stockRange={min=1, max=7} },
{ item="Base.WildGarlic2",          basePrice=20, tags={"Medical.Herb.Infection", "Theme.Survival"}, stockRange={min=1, max=7} },

-- Dried Herbs (Better Shelf Life)
{ item="Base.BlackSageDried",       basePrice=20, tags={"Medical.Herb.Pain", "Theme.Survival"}, stockRange={min=1, max=7} },
{ item="Base.CommonMallowDried",    basePrice=20, tags={"Medical.Herb.Cold", "Theme.Survival"}, stockRange={min=1, max=7} },
{ item="Base.PlantainDried",        basePrice=25, tags={"Medical.Herb.Wound", "Theme.Survival"}, stockRange={min=1, max=7} },
{ item="Base.ComfreyDried",         basePrice=30, tags={"Medical.Herb.Bone", "Theme.Survival"}, stockRange={min=1, max=7} },
{ item="Base.WildGarlicDried",      basePrice=25, tags={"Medical.Herb.Infection", "Theme.Survival"}, stockRange={min=1, max=7} },

-- Poultices (Processed)
{ item="Base.ComfreyCataplasm",     basePrice=50, tags={"Medical.Herb.Processed"}, stockRange={min=0, max=3} },
{ item="Base.PlantainCataplasm",    basePrice=45, tags={"Medical.Herb.Processed"}, stockRange={min=0, max=3} },
{ item="Base.WildGarlicCataplasm",  basePrice=45, tags={"Medical.Herb.Processed"}, stockRange={min=0, max=3} },

-- Tools
{ item="Base.MortarPestle",         basePrice=40, tags={"Medical.Surgical.Tool", "Theme.Survival"}, stockRange={min=1, max=5} },
{ item="Base.CeramicMortarandPestle",basePrice=60,tags={"Medical.Surgical.Tool", "Quality.Luxury"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 5. KITS & MISC
-- =============================================================================
{ item="Base.FirstAidKit",          basePrice=40, tags={"Container.Bag", "Origin.Medical"}, stockRange={min=1, max=5} }, -- Empty bag usually
{ item="Base.Splint",               basePrice=30, tags={"Medical.Utility.Splint", "Theme.Survival"}, stockRange={min=1, max=7} },
{ item="Base.Tissue",               basePrice=2,  tags={"Junk.Paper", "Rarity.Common"}, stockRange={min=1, max=10} },
{ item="Base.TissueBox",            basePrice=10, tags={"Medical.Utility.Tissues", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Coldpack",             basePrice=20, tags={"Medical.Utility.Coldpack", "Origin.Medical"}, stockRange={min=1, max=7} },
{ item="Base.ColdpackBox",          basePrice=80, tags={"Medical.Utility.Coldpack", "Origin.Medical"}, stockRange={min=1, max=5} },

-- Medical Clothing
{ item="Base.Hat_SurgicalMask",     basePrice=50, tags={"Clothing.Accessory.Mask", "Origin.Medical", "Quality.Sterile"}, stockRange={min=2, max=12} },
{ item="Base.Gloves_Surgical",      basePrice=40, tags={"Clothing.Hands.Gloves", "Origin.Medical", "Quality.Sterile"}, stockRange={min=2, max=12} },
{ item="Base.Hat_SurgicalCap",      basePrice=30, tags={"Clothing.Head.Hat", "Origin.Medical"}, stockRange={min=2, max=12} },
{ item="Base.Stethoscope",          basePrice=150, tags={"Medical.Utility.Tool", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} }, -- Doctor RP item -- Doctor RP item
})

print("[DynamicTrading] Medical Registry Complete \n.")
