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

    -- [Medical.General] [Rarity.Rare] (10 items)
    { item="Base.AdhesiveBandageBox", basePrice=17, tags={"Medical.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.AlcoholBandage", basePrice=170, tags={"Medical.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bandage", basePrice=170, tags={"Medical.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.BandageBox", basePrice=17, tags={"Medical.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.BandageDirty", basePrice=170, tags={"Medical.General", "Rarity.Rare", "Quality.Waste"}, stockRange={min=0, max=10} },
    { item="Base.Pills", basePrice=680, tags={"Medical.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PillsAntiDep", basePrice=680, tags={"Medical.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PillsBeta", basePrice=680, tags={"Medical.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PillsSleepingTablets", basePrice=680, tags={"Medical.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PillsVitamins", basePrice=340, tags={"Medical.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
})

DynamicTrading.Log("DTCommons", "Init", "Item", "General Registry Complete")
