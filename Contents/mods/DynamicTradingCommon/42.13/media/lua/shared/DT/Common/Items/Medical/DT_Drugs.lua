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
    { item="Base.CanPipe_Tobacco", basePrice=57, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General", "Medical.Consumable"}, stockRange={min=0, max=6} },
    { item="Base.Cigar", basePrice=85, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.CigaretteCarton", basePrice=8, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General"}, stockRange={min=0, max=2} },
    { item="Base.CigarettePack", basePrice=1360, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.CigaretteRolled", basePrice=170, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General", "Medical.Consumable"}, stockRange={min=0, max=20} },
    { item="Base.CigaretteSingle", basePrice=170, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General", "Medical.Consumable"}, stockRange={min=0, max=20} },
    { item="Base.Cigarillo", basePrice=170, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General", "Medical.Consumable"}, stockRange={min=0, max=20} },
    { item="Base.SmokingPipe_Tobacco", basePrice=57, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General", "Medical.Consumable"}, stockRange={min=0, max=6} },
    { item="Base.Tobacco", basePrice=85, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.TobaccoChewing", basePrice=907, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General", "Medical.Consumable"}, stockRange={min=0, max=6} },
    { item="Base.TobaccoDried", basePrice=85, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General"}, stockRange={min=0, max=10} },
    { item="Base.TobaccoLoose", basePrice=2267, tags={"Medical.General.Drug", "Rarity.Rare", "Medical.General", "Medical.Consumable"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Drugs Registry Complete")
