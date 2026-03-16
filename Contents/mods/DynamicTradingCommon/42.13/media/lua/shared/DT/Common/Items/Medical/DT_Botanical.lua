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
    { item="Base.BlackSage", basePrice=170, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.BlackSageDried", basePrice=170, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.Comfrey", basePrice=170, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.ComfreyCataplasm", basePrice=85, tags={"Medical.Healthcare.Botanical", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.ComfreyDried", basePrice=170, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.CommonMallow", basePrice=170, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.CommonMallowDried", basePrice=170, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.Ginseng", basePrice=170, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.Plantain", basePrice=170, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.PlantainCataplasm", basePrice=85, tags={"Medical.Healthcare.Botanical", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PlantainDried", basePrice=170, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.WildGarlic2", basePrice=170, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Medical.Consumable"}, stockRange={min=0, max=10} },
    { item="Base.WildGarlicCataplasm", basePrice=85, tags={"Medical.Healthcare.Botanical", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.WildGarlicDried", basePrice=170, tags={"Medical.Healthcare.Botanical", "Rarity.Rare", "Medical.Consumable"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Botanical Registry Complete")
