-- =============================================================================
-- DYNAMIC TRADING: MISC - ARTIFACT
-- =============================================================================
-- Root Category: Misc
-- Sub Category: Artifact
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.StockCertificate",     basePrice=150,  tags={"Misc.Artifact", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Misc/Artifact Registry Loaded.")
