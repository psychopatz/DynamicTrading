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

    -- [Medical.Healthcare] [Rarity.Rare] (12 items)
    { item="Base.AdhesiveBandageBox", basePrice=183, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=5} },
    { item="Base.AlcoholBandage", basePrice=181, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.AlcoholRippedSheets", basePrice=141, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.Bandage", basePrice=149, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.BandageBox", basePrice=183, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=5} },
    { item="Base.BandageDirty", basePrice=45, tags={"Medical.Healthcare", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=15} },
    { item="Base.Bandaid", basePrice=123, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=27} },
    { item="Base.Coldpack", basePrice=108, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ColdpackBox", basePrice=142, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.CottonBalls", basePrice=149, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.CottonBallsBox", basePrice=183, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=5} },
    { item="Base.Splint", basePrice=137, tags={"Medical.Healthcare", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=3} },
})

print("[DynamicTrading] Healthcare Registry Complete")
