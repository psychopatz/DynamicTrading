-- =============================================================================
-- DYNAMIC TRADING: LITERATURE - MUSIC
-- =============================================================================
-- Root Category: Literature
-- Sub Category: Music
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Flute",                basePrice=35, tags={"Literature.Music.Instrument", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.GuitarPick",           basePrice=2,  tags={"Literature.Music.Accessory", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.Harmonica",            basePrice=45, tags={"Literature.Music.Instrument", "Rarity.Common"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Literature/Music Registry Loaded.")
