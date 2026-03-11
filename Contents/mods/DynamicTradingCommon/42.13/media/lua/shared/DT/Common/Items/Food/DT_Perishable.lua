-- ============================================================================
-- Food Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Food.NonPerishable] [Rarity.Rare] (6 items)
    { item="Base.CanPipe_Tobacco", basePrice=1, tags={"Food.NonPerishable", "Rarity.Rare"}, stockRange={min=0, max=7} },
    { item="Base.Cigar", basePrice=1, tags={"Food.NonPerishable", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.CigaretteRolled", basePrice=1, tags={"Food.NonPerishable", "Rarity.Rare"}, stockRange={min=0, max=25} },
    { item="Base.CigaretteSingle", basePrice=1, tags={"Food.NonPerishable", "Rarity.Rare"}, stockRange={min=0, max=25} },
    { item="Base.Cigarillo", basePrice=1, tags={"Food.NonPerishable", "Rarity.Rare"}, stockRange={min=0, max=25} },
    { item="Base.SmokingPipe_Tobacco", basePrice=1, tags={"Food.NonPerishable", "Rarity.Rare"}, stockRange={min=0, max=7} },
})

DynamicTrading.Log("DTCommons", "Init", "Item", "Perishable Registry Complete")
