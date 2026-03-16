-- ============================================================================
-- Container Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Container.Bag.Satchel] [Rarity.Rare] (13 items)
    { item="Base.Bag_ClothSatchel_Burlap", basePrice=1990, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ClothSatchel_Cotton", basePrice=1990, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ClothSatchel_Denim", basePrice=1990, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ClothSatchel_DenimBlack", basePrice=1990, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ClothSatchel_DenimLight", basePrice=1990, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HideSatchel", basePrice=1990, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Satchel", basePrice=1990, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Satchel_Fishing", basePrice=1990, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Satchel_Leather", basePrice=1996, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Satchel_Mail", basePrice=1990, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Satchel_Medical", basePrice=2229, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Theme.Clinical", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_Satchel_Military", basePrice=2949, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_SatchelPhoto", basePrice=1990, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Satchel Registry Complete")
