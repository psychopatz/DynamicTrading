-- =============================================================================
-- DYNAMIC TRADING: MEDICAL - TOBACCO
-- =============================================================================
-- Root Category: Medical
-- Sub Category: Tobacco
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.CanPipe",              basePrice=5,   tags={"Medical.Tobacco", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.CanPipe_Tobacco",      basePrice=10,  tags={"Medical.Tobacco", "Quality.Waste"}, stockRange={min=0, max=5} },
    { item="Base.Cigar", basePrice=50, tags={"Medical.Tobacco", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
    { item="Base.CigaretteCarton",      basePrice=1500, tags={"Medical.Tobacco", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=1} },
    { item="Base.CigarettePack",        basePrice=80,  tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.CigaretteRolled", basePrice=3, tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=10, max=50} },
    { item="Base.CigaretteRollingPapers",basePrice=15, tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.CigaretteSingle", basePrice=4, tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=10, max=50} },
    { item="Base.Cigarillo", basePrice=15, tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=5, max=15} },
    { item="Base.SmokingPipe_Tobacco",  basePrice=65,  tags={"Medical.Tobacco", "Quality.Basic", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
    { item="Base.TobaccoChewing",       basePrice=45,  tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.TobaccoLoose",         basePrice=85,  tags={"Medical.Tobacco", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Medical/Tobacco Registry Loaded.")
