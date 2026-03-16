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

    -- [Medical.General.Pills] [Rarity.Rare] (10 items)
    { item="Base.AlcoholedCottonBalls", basePrice=98, tags={"Medical.General.Pills", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=13} },
    { item="Base.AlcoholWipes", basePrice=107, tags={"Medical.General.Pills", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=6} },
    { item="Base.Antibiotics", basePrice=26, tags={"Medical.General.Pills", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.AntibioticsBox", basePrice=60, tags={"Medical.General.Pills", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=3} },
    { item="Base.Pills", basePrice=179, tags={"Medical.General.Pills", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.PillsAntiDep", basePrice=217, tags={"Medical.General.Pills", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.PillsBeta", basePrice=219, tags={"Medical.General.Pills", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.PillsSleepingTablets", basePrice=214, tags={"Medical.General.Pills", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.Tissue", basePrice=17, tags={"Medical.General.Pills", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.TissueBox", basePrice=21, tags={"Medical.General.Pills", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=3} },
})

print("[DynamicTrading] Pills Registry Complete")
