-- =============================================================================
-- DYNAMIC TRADING: MEDICAL - UTILITY
-- =============================================================================
-- Root Category: Medical
-- Sub Category: Utility
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.AdhesiveBandageBox",   basePrice=20,  tags={"Medical.Utility.Bandage", "Rarity.Common"}, stockRange={min=1, max=7} },
    { item="Base.AlcoholBandage",       basePrice=25,  tags={"Medical.Utility.Bandage", "Quality.Sterile"}, stockRange={min=2, max=12} },
    { item="Base.AlcoholRippedSheets",  basePrice=7,  tags={"Medical.Utility.Bandage", "Quality.Sterile"}, stockRange={min=5, max=25} },
    { item="Base.AlcoholWipes",         basePrice=15,  tags={"Medical.Utility.Cotton", "Quality.Sterile"}, stockRange={min=2, max=12} },
    { item="Base.AlcoholedCottonBalls", basePrice=7,   tags={"Medical.Utility.Cotton", "Quality.Sterile"}, stockRange={min=2, max=12} },
    { item="Base.Antibiotics", basePrice=250, tags={"Medical.Utility.Pill", "Origin.Healthcare", "Quality.Sterile"}, stockRange={min=1, max=5} },
    { item="Base.AntibioticsBox", basePrice=1000,tags={"Medical.Utility.Pill", "Origin.Healthcare", "Quality.Sterile"}, stockRange={min=0, max=1} },
    { item="Base.Bandage",              basePrice=15,  tags={"Medical.Utility.Bandage", "Origin.Healthcare"}, stockRange={min=5, max=25} },
    { item="Base.BandageBox",           basePrice=60,  tags={"Medical.Utility.Bandage", "Origin.Healthcare"}, stockRange={min=1, max=5} },
    { item="Base.BandageDirty",         basePrice=0,  tags={"Medical.Utility.Bandage", "Quality.Waste"}, stockRange={min=0, max=0} },
    { item="Base.Bandaid",              basePrice=5,   tags={"Medical.Utility.Bandage", "Rarity.Common"}, stockRange={min=5, max=50} },
    { item="Base.Bleach",           tags={"Medical.Utility.Clinical", "Quality.Waste", "Rarity.Common"},   basePrice=15, stockRange={min=2, max=8} },
    { item="Base.CleaningLiquid2",  tags={"Medical.Utility.Clinical", "Rarity.Common"},              basePrice=12,  stockRange={min=2, max=6} },
    { item="Base.Coldpack",             basePrice=20, tags={"Medical.Utility.Coldpack", "Origin.Healthcare"}, stockRange={min=1, max=7} },
    { item="Base.ColdpackBox",          basePrice=80, tags={"Medical.Utility.Coldpack", "Origin.Healthcare"}, stockRange={min=1, max=5} },
    { item="Base.CottonBalls",          basePrice=3,   tags={"Medical.Utility.Cotton", "Rarity.Common"}, stockRange={min=5, max=25} },
    { item="Base.CottonBallsBox",       basePrice=12,  tags={"Medical.Utility.Cotton", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.DenimStrips",          basePrice=3,  tags={"Medical.Utility.Bandage", "Quality.Waste"}, stockRange={min=5, max=25} },
    { item="Base.DenimStripsDirty",     basePrice=0,  tags={"Medical.Utility.Bandage", "Quality.Waste"}, stockRange={min=0, max=0} },
    { item="Base.Disinfectant",         basePrice=50,  tags={"Medical.Utility.Liquid", "Quality.Sterile"}, stockRange={min=1, max=7} },
    { item="Base.InsectRepellent",         basePrice=35,  tags={"Medical.Utility.Protection", "Rarity.Common"}, stockRange={min=2, max=8} },
    { item="Base.LeatherStrips",        basePrice=5,  tags={"Medical.Utility.Bandage", "Quality.Waste"}, stockRange={min=5, max=25} },
    { item="Base.LeatherStripsDirty",   basePrice=0,  tags={"Medical.Utility.Bandage", "Quality.Waste"}, stockRange={min=0, max=0} },
    { item="Base.Pills", basePrice=45, tags={"Medical.Utility.Pill", "Origin.Healthcare"}, stockRange={min=2, max=15} },
    { item="Base.PillsAntiDep", basePrice=45, tags={"Medical.Utility.Pill", "Origin.Healthcare"}, stockRange={min=2, max=15} },
    { item="Base.PillsBeta", basePrice=60, tags={"Medical.Utility.Pill", "Origin.Healthcare"}, stockRange={min=2, max=15} },
    { item="Base.PillsSleepingTablets", basePrice=60, tags={"Medical.Utility.Pill", "Origin.Healthcare"}, stockRange={min=2, max=15} },
    { item="Base.PillsVitamins", basePrice=30, tags={"Medical.Utility.Pill", "Origin.Healthcare"}, stockRange={min=2, max=15} },
    { item="Base.RippedSheets",         basePrice=2,  tags={"Medical.Utility.Bandage", "Quality.Waste"}, stockRange={min=10, max=50} },
    { item="Base.Splint",               basePrice=30, tags={"Medical.Utility.Splint", "Theme.Survival"}, stockRange={min=1, max=7} },
    { item="Base.Stethoscope",          basePrice=150, tags={"Medical.Utility.Tool", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} }, -- Doctor RP item -- Doctor RP item,
    { item="Base.TissueBox",            basePrice=10, tags={"Medical.Utility.Tissues", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.WaterPurificationTablets",basePrice=180, tags={"Medical.Utility.Purification", "Theme.Survival", "Rarity.Rare"}, stockRange={min=1, max=3} }, -- High value life-saver,
})

print("[DynamicTrading] Medical/Utility Registry Loaded.")
