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
    { item="Base.Bag_ClothSatchel_Burlap", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ClothSatchel_Cotton", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ClothSatchel_Denim", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ClothSatchel_DenimBlack", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ClothSatchel_DenimLight", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HideSatchel", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Satchel", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Satchel_Fishing", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Satchel_Leather", basePrice=91, tags={"Container.Bag.Satchel", "Rarity.Rare", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Satchel_Mail", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Satchel_Medical", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Clinical", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Satchel_Military", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Origin.Militia", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_SatchelPhoto", basePrice=84, tags={"Container.Bag.Satchel", "Rarity.Rare", "Container.Bag", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Satchel Registry Complete")
