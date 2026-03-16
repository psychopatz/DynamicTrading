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
    { item="Base.Bag_ALICEpack", basePrice=2734, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_ALICEpack_Army", basePrice=3804, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_ALICEpack_DesertCamo", basePrice=2734, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_BaseballBag", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_BigHikingBag", basePrice=2695, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_BigHikingBag_Travel", basePrice=2695, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_BreakdownBag", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_BurglarBag", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CraftedFramepack_Large", basePrice=2678, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_CraftedFramepack_Large2", basePrice=2710, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_CraftedFramepack_Large3", basePrice=2762, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_CraftedFramepack_Small", basePrice=2645, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CrudeLeatherBag", basePrice=2635, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CrudeTarpBag", basePrice=2630, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_FishingBasket", basePrice=2574, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_FoodSnacks", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_GolfBag", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_GolfBag_Melee", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HideSlingBag", basePrice=2631, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HikingBag_Travel", basePrice=2679, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_InmateEscapedBag", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Military", basePrice=3717, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_NormalHikingBag", basePrice=2679, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_Police", basePrice=3284, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Theme.Police", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_RifleCaseCloth", basePrice=2594, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_RifleCaseCloth2", basePrice=2594, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_RifleCaseClothCamo", basePrice=2594, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag", basePrice=2646, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Kids", basePrice=2646, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Medical", basePrice=2944, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Theme.Clinical", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_Schoolbag_Patches", basePrice=2646, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Travel", basePrice=2646, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_SheetSlingBag", basePrice=2598, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Sheriff", basePrice=3284, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Theme.Police", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_ShotgunCaseCloth", basePrice=2594, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunCaseCloth2", basePrice=2594, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunDblBag", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunDblSawnoffBag", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunSawnoffBag", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_SurvivorBag", basePrice=2734, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_SWAT", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TarpFramepack_Large", basePrice=2673, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_TarpFramepack_Small", basePrice=2640, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TarpSlingBag", basePrice=2614, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TennisBag", basePrice=2658, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Backpack Registry Complete")
