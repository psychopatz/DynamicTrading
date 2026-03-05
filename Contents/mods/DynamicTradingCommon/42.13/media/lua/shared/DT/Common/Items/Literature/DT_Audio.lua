-- =============================================================================
-- DYNAMIC TRADING: LITERATURE - AUDIO
-- =============================================================================
-- Root Category: Literature
-- Sub Category: Audio
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.TuningFork",           basePrice=35, tags={"Literature.Audio", "Literature.Music.Accessory", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Literature/Audio Registry Loaded.")
