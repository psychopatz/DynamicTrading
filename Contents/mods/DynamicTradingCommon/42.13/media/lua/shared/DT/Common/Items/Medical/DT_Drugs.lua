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

    -- [Medical.General.Drug] [Rarity.Rare] (12 items)
    { item="Base.CanPipe_Tobacco", basePrice=117, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=6} },
    { item="Base.Cigar", basePrice=125, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=11} },
    { item="Base.CigaretteCarton", basePrice=187, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=2} },
    { item="Base.CigarettePack", basePrice=278, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=11} },
    { item="Base.CigaretteRolled", basePrice=101, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=22} },
    { item="Base.CigaretteSingle", basePrice=103, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=22} },
    { item="Base.Cigarillo", basePrice=107, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=22} },
    { item="Base.SmokingPipe_Tobacco", basePrice=117, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=6} },
    { item="Base.Tobacco", basePrice=100, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=11} },
    { item="Base.TobaccoChewing", basePrice=266, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=6} },
    { item="Base.TobaccoDried", basePrice=100, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.TobaccoLoose", basePrice=237, tags={"Medical.General.Drug", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Drugs Registry Complete")
