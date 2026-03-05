-- =============================================================================
-- DYNAMIC TRADING: MEDICAL - HERB
-- =============================================================================
-- Root Category: Medical
-- Sub Category: Herb
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BlackSage",            basePrice=15, tags={"Medical.Herb.Pain", "Theme.Survival"}, stockRange={min=1, max=7} },
    { item="Base.BlackSageDried",       basePrice=20, tags={"Medical.Herb.Pain", "Theme.Survival"}, stockRange={min=1, max=7} },
    { item="Base.Comfrey",              basePrice=25, tags={"Medical.Herb.Bone", "Theme.Survival"}, stockRange={min=1, max=7} },
    { item="Base.ComfreyCataplasm",     basePrice=50, tags={"Medical.Herb.Processed"}, stockRange={min=0, max=3} },
    { item="Base.ComfreyDried",         basePrice=30, tags={"Medical.Herb.Bone", "Theme.Survival"}, stockRange={min=1, max=7} },
    { item="Base.CommonMallow",         basePrice=15, tags={"Medical.Herb.Cold", "Theme.Survival"}, stockRange={min=1, max=7} },
    { item="Base.CommonMallowDried",    basePrice=20, tags={"Medical.Herb.Cold", "Theme.Survival"}, stockRange={min=1, max=7} },
    { item="Base.Ginseng",              basePrice=30, tags={"Medical.Herb.Energy", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=5} },
    { item="Base.LemonGrass",           basePrice=50, tags={"Medical.Herb.Survival", "Rarity.Rare"}, stockRange={min=1, max=5} },
    { item="Base.Plantain",             basePrice=20, tags={"Medical.Herb.Wound", "Theme.Survival"}, stockRange={min=1, max=7} },
    { item="Base.PlantainCataplasm",    basePrice=45, tags={"Medical.Herb.Processed"}, stockRange={min=0, max=3} },
    { item="Base.PlantainDried",        basePrice=25, tags={"Medical.Herb.Wound", "Theme.Survival"}, stockRange={min=1, max=7} },
    { item="Base.WildGarlic2",          basePrice=20, tags={"Medical.Herb.Infection", "Theme.Survival"}, stockRange={min=1, max=7} },
    { item="Base.WildGarlicCataplasm",  basePrice=45, tags={"Medical.Herb.Processed"}, stockRange={min=0, max=3} },
    { item="Base.WildGarlicDried",      basePrice=25, tags={"Medical.Herb.Infection", "Theme.Survival"}, stockRange={min=1, max=7} },
})

print("[DynamicTrading] Medical/Herb Registry Loaded.")
