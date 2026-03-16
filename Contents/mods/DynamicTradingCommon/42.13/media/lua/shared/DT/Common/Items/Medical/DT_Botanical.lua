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

    -- [Medical.Healthcare.Botanical] [Rarity.Rare] (14 items)
    { item="Base.BlackSage", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.BlackSageDried", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.Comfrey", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.ComfreyCataplasm", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.ComfreyDried", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.CommonMallow", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.CommonMallowDried", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.Ginseng", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.Plantain", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.PlantainCataplasm", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.PlantainDried", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.WildGarlic2", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
    { item="Base.WildGarlicCataplasm", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.WildGarlicDried", basePrice=1683, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Origin.Vanilla", "Medical.Consumable"}, stockRange={min=0, max=9} },
})

print("[DynamicTrading] Botanical Registry Complete")
