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
    { item="Base.Bag_ALICEpack", basePrice=110, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_ALICEpack_Army", basePrice=110, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Militia", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_ALICEpack_DesertCamo", basePrice=110, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_BaseballBag", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_BigHikingBag", basePrice=112, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_BigHikingBag_Travel", basePrice=112, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_BreakdownBag", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_BurglarBag", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CraftedFramepack_Large", basePrice=74, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_CraftedFramepack_Large2", basePrice=64, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_CraftedFramepack_Large3", basePrice=65, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_CraftedFramepack_Small", basePrice=72, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CrudeLeatherBag", basePrice=98, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_CrudeTarpBag", basePrice=95, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_FishingBasket", basePrice=26, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_FoodSnacks", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_GolfBag", basePrice=105, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_GolfBag_Melee", basePrice=105, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HideSlingBag", basePrice=119, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HikingBag_Travel", basePrice=124, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_InmateEscapedBag", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Military", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Militia", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_NormalHikingBag", basePrice=124, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Police", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Police", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_RifleCaseCloth", basePrice=49, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_RifleCaseCloth2", basePrice=49, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_RifleCaseClothCamo", basePrice=49, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag", basePrice=108, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Kids", basePrice=108, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Medical", basePrice=87, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Clinical", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Patches", basePrice=108, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Schoolbag_Travel", basePrice=108, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_SheetSlingBag", basePrice=80, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_Sheriff", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Origin.Police", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunCaseCloth", basePrice=49, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunCaseCloth2", basePrice=49, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunDblBag", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunDblSawnoffBag", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ShotgunSawnoffBag", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_SurvivorBag", basePrice=110, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_SWAT", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TarpFramepack_Large", basePrice=72, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.Bag_TarpFramepack_Small", basePrice=70, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TarpSlingBag", basePrice=99, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_TennisBag", basePrice=126, tags={"Container.Bag.Backpack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Backpack Registry Complete")
