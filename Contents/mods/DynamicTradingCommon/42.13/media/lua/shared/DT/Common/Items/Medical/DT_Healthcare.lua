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
    { item="Base.AdhesiveBandageBox", basePrice=100, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=5} },
    { item="Base.AlcoholBandage", basePrice=98, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.AlcoholRippedSheets", basePrice=58, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.Bandage", basePrice=67, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.BandageBox", basePrice=100, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=5} },
    { item="Base.BandageDirty", basePrice=20, tags={"Medical.Healthcare", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=15} },
    { item="Base.Bandaid", basePrice=41, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=27} },
    { item="Base.Coldpack", basePrice=26, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ColdpackBox", basePrice=59, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.CottonBalls", basePrice=67, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.CottonBallsBox", basePrice=100, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=5} },
    { item="Base.Disinfectant", basePrice=58, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.Splint", basePrice=54, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=3} },
})

print("[DynamicTrading] Healthcare Registry Complete")
