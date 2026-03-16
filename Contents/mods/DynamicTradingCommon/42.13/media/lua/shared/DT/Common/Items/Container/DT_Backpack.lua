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
    { item="Base.Bag_ALICEpack", basePrice=383, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_ALICEpack_Army", basePrice=474, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_ALICEpack_DesertCamo", basePrice=383, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_BaseballBag", basePrice=308, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_BigHikingBag", basePrice=344, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_BigHikingBag_Travel", basePrice=344, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_BreakdownBag", basePrice=308, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_BurglarBag", basePrice=308, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CraftedFramepack_Large", basePrice=327, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_CraftedFramepack_Large2", basePrice=360, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_CraftedFramepack_Large3", basePrice=411, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_CraftedFramepack_Small", basePrice=294, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CrudeLeatherBag", basePrice=285, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CrudeTarpBag", basePrice=280, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_FishingBasket", basePrice=223, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_FoodSnacks", basePrice=308, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_GolfBag", basePrice=307, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_GolfBag_Melee", basePrice=307, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HideSlingBag", basePrice=280, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HikingBag_Travel", basePrice=328, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_InmateEscapedBag", basePrice=308, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Military", basePrice=387, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_NormalHikingBag", basePrice=328, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_Police", basePrice=353, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Theme.Police", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_RifleCaseCloth", basePrice=244, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_RifleCaseCloth2", basePrice=244, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_RifleCaseClothCamo", basePrice=244, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag", basePrice=295, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Kids", basePrice=295, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Medical", basePrice=311, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Theme.Clinical", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_Schoolbag_Patches", basePrice=295, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Travel", basePrice=295, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_SheetSlingBag", basePrice=248, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Sheriff", basePrice=353, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Theme.Police", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=3} },
    { item="Base.Bag_ShotgunCaseCloth", basePrice=244, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunCaseCloth2", basePrice=244, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunDblBag", basePrice=308, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunDblSawnoffBag", basePrice=308, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunSawnoffBag", basePrice=308, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_SurvivorBag", basePrice=383, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_SWAT", basePrice=308, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TarpFramepack_Large", basePrice=323, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.Bag_TarpFramepack_Small", basePrice=290, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TarpSlingBag", basePrice=264, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TennisBag", basePrice=308, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Backpack Registry Complete")
