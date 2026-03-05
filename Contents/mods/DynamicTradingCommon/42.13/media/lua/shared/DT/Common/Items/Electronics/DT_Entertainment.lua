-- =============================================================================
-- DYNAMIC TRADING: ELECTRONICS - ENTERTAINMENT
-- =============================================================================
-- Root Category: Electronics
-- Sub Category: Entertainment
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.CDplayer",              basePrice=85, tags={"Electronics.Entertainment.Audio", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
    { item="Base.VideoGame",             basePrice=120,tags={"Electronics.Entertainment.Gaming", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Electronics/Entertainment Registry Loaded.")
