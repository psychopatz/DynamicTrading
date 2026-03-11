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

    -- [Electronics.Gadget] [Rarity.Common] (4 items)
    { item="Base.Generator", basePrice=1, tags={"Electronics.Gadget", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.Generator_Blue", basePrice=1, tags={"Electronics.Gadget", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.Generator_Old", basePrice=1, tags={"Electronics.Gadget", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.Generator_Yellow", basePrice=1, tags={"Electronics.Gadget", "Rarity.Common"}, stockRange={min=0, max=2} },

    -- [Electronics.Gadget] [Rarity.Rare] (6 items)
    { item="Base.ElectronicsMag1", basePrice=102, tags={"Electronics.Gadget", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.ElectronicsMag2", basePrice=102, tags={"Electronics.Gadget", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.ElectronicsMag3", basePrice=102, tags={"Electronics.Gadget", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.ElectronicsMag4", basePrice=102, tags={"Electronics.Gadget", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.ElectronicsMag5", basePrice=102, tags={"Electronics.Gadget", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.ElectronicsScrap", basePrice=85, tags={"Electronics.Gadget", "Rarity.Rare", "Quality.Waste"}, stockRange={min=0, max=10} },
})

DynamicTrading.Log("DTCommons", "Init", "Item", "Gadget Registry Complete")
