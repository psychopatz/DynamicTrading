-- =============================================================================
-- DYNAMIC TRADING: ELECTRONICS - COMMUNICATION
-- =============================================================================
-- Root Category: Electronics
-- Sub Category: Communication
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.HamRadio1",             basePrice=250, tags={"Electronics.Communication.Stationary", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.HamRadio2",             basePrice=600, tags={"Electronics.Communication.Stationary", "Origin.Militia", "Rarity.Legendary"}, stockRange={min=0, max=1} },
    { item="Base.HamRadioMakeShift",     basePrice=80,  tags={"Electronics.Communication.Stationary", "Origin.Nomad", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
    { item="Base.ManPackRadio",          basePrice=800, tags={"Electronics.Communication.Handheld", "Origin.Militia", "Rarity.Legendary"}, stockRange={min=0, max=1} },
    { item="Base.WalkieTalkie1",         basePrice=25, tags={"Electronics.Communication.Handheld", "Quality.Waste", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.WalkieTalkie2",         basePrice=60, tags={"Electronics.Communication.Handheld", "Rarity.Common"}, stockRange={min=1, max=3} },
    { item="Base.WalkieTalkie3",         basePrice=120,tags={"Electronics.Communication.Handheld", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
    { item="Base.WalkieTalkie4",         basePrice=250,tags={"Electronics.Communication.Handheld", "Origin.Militia", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.WalkieTalkie5",         basePrice=600,tags={"Electronics.Communication.Handheld", "Origin.Militia", "Rarity.Legendary"}, stockRange={min=0, max=1} },
    { item="Base.WalkieTalkieMakeShift", basePrice=15, tags={"Electronics.Communication.Handheld", "Origin.Nomad", "Rarity.Common"}, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Electronics/Communication Registry Loaded.")
