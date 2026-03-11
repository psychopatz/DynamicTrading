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

    -- [Food.Cooking.Ingredient] [Rarity.Rare] (1 item)
    { item="Base.Chum", basePrice=1, tags={"Food.Cooking.Ingredient", "Rarity.Rare"}, stockRange={min=0, max=6} },
})

DynamicTrading.Log("DTCommons", "Init", "Item", "Cooking Registry Complete")
