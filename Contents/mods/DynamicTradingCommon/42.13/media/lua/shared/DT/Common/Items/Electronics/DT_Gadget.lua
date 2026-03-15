-- ============================================================================
-- Electronics Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Electronics.Gadget.General] [Rarity.Rare] (4 items)
    { item="Base.ElectricWire", basePrice=85, tags={"Electronics.Gadget.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.ElectronicsScrap", basePrice=85, tags={"Electronics.Gadget.General", "Rarity.Rare", "Quality.Waste"}, stockRange={min=0, max=10} },
    { item="Base.HairDryer", basePrice=8, tags={"Electronics.Gadget.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.HairIron", basePrice=8, tags={"Electronics.Gadget.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Gadget Registry Complete")
