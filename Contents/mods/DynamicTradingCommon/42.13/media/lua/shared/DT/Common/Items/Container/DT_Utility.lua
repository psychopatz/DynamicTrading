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

    -- [Container.Utility.KeyRing] [Rarity.Common] (1 item)
    { item="Base.KeyRing_Kitty", basePrice=113, tags={"Container.Utility.KeyRing", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=5, max=42} },

    -- [Container.Utility.KeyRing] [Rarity.Rare] (28 items)
    { item="Base.KeyRing", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Bass", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_BlueFox", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Bug", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_CarDealer", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Clover", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_EagleFlag", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_EightBall", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Forged", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Forged_Gold", basePrice=369, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=16} },
    { item="Base.KeyRing_Forged_Silver", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Hotdog", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Large", basePrice=179, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Nolans", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Panther", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_PineTree", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_PrayingHands", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_RabbitFoot", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=11} },
    { item="Base.KeyRing_Racing12", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Racing34", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Racing58", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_RainbowStar", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_RubberDuck", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_SecurityPass", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Sexy", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Spiffos", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_StinkyFace", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_WestMaple", basePrice=173, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
})

print("[DynamicTrading] Utility Registry Complete")
