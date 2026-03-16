-- ============================================================================
-- Medical Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Medical.Healthcare] [Rarity.Rare] (13 items)
    { item="Base.AdhesiveBandageBox", basePrice=100, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.AlcoholBandage", basePrice=98, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.AlcoholRippedSheets", basePrice=58, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bandage", basePrice=67, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.BandageBox", basePrice=100, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.BandageDirty", basePrice=20, tags={"Medical.Healthcare", "Rarity.Rare", "Quality.Waste"}, stockRange={min=0, max=10} },
    { item="Base.Bandaid", basePrice=41, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Coldpack", basePrice=26, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.ColdpackBox", basePrice=59, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.CottonBalls", basePrice=67, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.CottonBallsBox", basePrice=100, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Disinfectant", basePrice=58, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Splint", basePrice=54, tags={"Medical.Healthcare", "Rarity.Rare"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Healthcare Registry Complete")
