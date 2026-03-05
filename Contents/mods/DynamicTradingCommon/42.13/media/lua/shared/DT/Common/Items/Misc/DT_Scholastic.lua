-- =============================================================================
-- DYNAMIC TRADING: MISC - SCHOLASTIC
-- =============================================================================
-- Root Category: Misc
-- Sub Category: Scholastic
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BluePen",          basePrice=2,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.Clipboard",        basePrice=10, tags={"Misc.Scholastic", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.CorrectionFluid",  basePrice=5,  tags={"Misc.Scholastic", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.Crayons",          basePrice=15, tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.Eraser",           basePrice=5,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.GreenPen",         basePrice=2,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.MarkerBlack",      basePrice=8,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.MarkerBlue",       basePrice=8,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.MarkerGreen",      basePrice=8,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.MarkerRed",        basePrice=8,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Pen",              basePrice=2,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=10, max=50} },
    { item="Base.PenFancy",         basePrice=25, tags={"Misc.Scholastic", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=3} },
    { item="Base.PenMultiColor",    basePrice=10, tags={"Misc.Scholastic", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
    { item="Base.PenSpiffo",        basePrice=50, tags={"Misc.Scholastic", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.Pencil",           basePrice=2,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=10, max=50} },
    { item="Base.PencilSpiffo",     basePrice=50, tags={"Misc.Scholastic", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.RedPen",           basePrice=2,  tags={"Misc.Scholastic", "Rarity.Common"}, stockRange={min=5, max=20} },
})

print("[DynamicTrading] Misc/Scholastic Registry Loaded.")
