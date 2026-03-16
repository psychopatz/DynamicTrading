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

    -- [Container.Bag.Backpack] [Rarity.Rare] (45 items)
    { item="Base.Bag_ALICEpack", basePrice=260, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_ALICEpack_Army", basePrice=299, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Militia", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_ALICEpack_DesertCamo", basePrice=260, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_BaseballBag", basePrice=185, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_BigHikingBag", basePrice=221, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_BigHikingBag_Travel", basePrice=221, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_BreakdownBag", basePrice=185, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_BurglarBag", basePrice=185, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CraftedFramepack_Large", basePrice=204, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_CraftedFramepack_Large2", basePrice=236, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_CraftedFramepack_Large3", basePrice=288, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_CraftedFramepack_Small", basePrice=171, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CrudeLeatherBag", basePrice=161, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CrudeTarpBag", basePrice=157, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_FishingBasket", basePrice=100, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_FoodSnacks", basePrice=185, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_GolfBag", basePrice=184, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_GolfBag_Melee", basePrice=184, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HideSlingBag", basePrice=157, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HikingBag_Travel", basePrice=205, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_InmateEscapedBag", basePrice=185, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Military", basePrice=212, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Militia", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_NormalHikingBag", basePrice=205, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_Police", basePrice=199, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Police", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_RifleCaseCloth", basePrice=121, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_RifleCaseCloth2", basePrice=121, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_RifleCaseClothCamo", basePrice=121, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag", basePrice=172, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Kids", basePrice=172, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Medical", basePrice=173, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Clinical", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_Schoolbag_Patches", basePrice=172, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Travel", basePrice=172, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_SheetSlingBag", basePrice=124, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Sheriff", basePrice=199, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Police", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_ShotgunCaseCloth", basePrice=121, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunCaseCloth2", basePrice=121, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunDblBag", basePrice=185, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunDblSawnoffBag", basePrice=185, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunSawnoffBag", basePrice=185, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_SurvivorBag", basePrice=260, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_SWAT", basePrice=185, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TarpFramepack_Large", basePrice=199, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_TarpFramepack_Small", basePrice=166, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TarpSlingBag", basePrice=141, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TennisBag", basePrice=185, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Backpack Registry Complete")
