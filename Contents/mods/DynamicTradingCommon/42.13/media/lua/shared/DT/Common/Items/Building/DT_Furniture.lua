-- ============================================================================
-- Building Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Building.Furniture] [Rarity.Common] (10 items)
    { item="Base.Antlers_Wall", basePrice=2, tags={"Building.Furniture", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Bull_Skull_Wall", basePrice=1, tags={"Building.Furniture", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Cow_Skull_Wall", basePrice=1, tags={"Building.Furniture", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.DeerDoe_Skull_Wall", basePrice=2, tags={"Building.Furniture", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.DeerStag_Skull_Wall", basePrice=2, tags={"Building.Furniture", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Mattress", basePrice=1, tags={"Building.Furniture", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.MetalDrum", basePrice=2, tags={"Building.Furniture", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Moveable", basePrice=2, tags={"Building.Furniture", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Pig_Skull_Wall", basePrice=2, tags={"Building.Furniture", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Sheep_Skull_Wall", basePrice=2, tags={"Building.Furniture", "Rarity.Common"}, stockRange={min=3, max=15} },

    -- [Building.Furniture] [Rarity.Rare] (2 items)
    { item="Base.CandleBox", basePrice=2, tags={"Building.Furniture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Frame", basePrice=2, tags={"Building.Furniture", "Rarity.Rare"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Furniture Registry Complete")
