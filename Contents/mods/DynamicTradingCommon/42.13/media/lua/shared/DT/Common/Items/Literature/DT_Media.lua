-- =============================================================================
-- DYNAMIC TRADING: LITERATURE - MEDIA
-- =============================================================================
-- Root Category: Literature
-- Sub Category: Media
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.HottieZ",            basePrice=120, tags={"Literature.Media", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.HottieZ_New",        basePrice=150, tags={"Literature.Media", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.Magazine",           basePrice=2, tags={"Literature.Media", "Quality.Waste"}, stockRange={min=5, max=30} },
    { item="Base.MagazineCrossword",  basePrice=3, tags={"Literature.Media"}, stockRange={min=2, max=10} },
    { item="Base.MagazineWordsearch", basePrice=3, tags={"Literature.Media"}, stockRange={min=2, max=10} },
    { item="Base.Newspaper",          basePrice=1, tags={"Literature.Media"}, stockRange={min=10, max=50} },
    { item="Base.Newspaper_New",      basePrice=1, tags={"Literature.Media"}, stockRange={min=10, max=50} },
    { item="Base.TVMagazine",         basePrice=1, tags={"Literature.Media"}, stockRange={min=5, max=20} },
})

print("[DynamicTrading] Literature/Media Registry Loaded.")
