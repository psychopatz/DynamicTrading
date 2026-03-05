-- =============================================================================
-- DYNAMIC TRADING: MISC - GENERAL
-- =============================================================================
-- Root Category: Misc
-- Sub Category: General
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BackgammonBoard",      basePrice=85,  tags={"Misc.General", "Theme.Leisure", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
    { item="Base.CardDeck",             basePrice=25,  tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=1, max=3} },
    { item="Base.CheckerBoard",         basePrice=85,  tags={"Misc.General", "Theme.Leisure", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
    { item="Base.Dice",                 basePrice=5,   tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=2, max=8} },
    { item="Base.Dice_Bone",            basePrice=15,  tags={"Misc.General", "Theme.Leisure", "Origin.Nomad", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
    { item="Base.Dice_Wood",            basePrice=10,  tags={"Misc.General", "Theme.Leisure", "Origin.Nomad", "Rarity.Common"}, stockRange={min=1, max=3} },
    { item="Base.Firecracker",        tags={"Misc.General", "Theme.Leisure"}, stockRange={min=2, max=10}, basePrice=35 },
    { item="Base.GamePieceBlack",       basePrice=2,   tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=5, max=10} },
    { item="Base.GamePieceRed",         basePrice=2,   tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=5, max=10} },
    { item="Base.GamePieceWhite",       basePrice=2,   tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=5, max=10} },
    { item="Base.Revolver_CapGun",        tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, basePrice=10, stockRange={min=1, max=2} },
    { item="Base.RippedSheetsDirty",    basePrice=0,  tags={"Misc.General", "Medical", "Quality.Waste"}, stockRange={min=0, max=0} },
    { item="Base.ScratchTicket",        basePrice=2,   tags={"Misc.General", "Quality.Waste"}, stockRange={min=5, max=20} },
})

print("[DynamicTrading] Misc/General Registry Loaded.")
