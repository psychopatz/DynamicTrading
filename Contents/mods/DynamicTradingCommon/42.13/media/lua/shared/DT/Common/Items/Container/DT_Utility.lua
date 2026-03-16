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
    { item="Base.KeyRing_Kitty", basePrice=73, tags={"Container.Utility.KeyRing", "Rarity.Common", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=5, max=42} },

    -- [Container.Utility.KeyRing] [Rarity.Rare] (28 items)
    { item="Base.KeyRing", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Bass", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_BlueFox", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Bug", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_CarDealer", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Clover", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_EagleFlag", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_EightBall", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Forged", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Forged_Gold", basePrice=170, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Quality.Luxury", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=16} },
    { item="Base.KeyRing_Forged_Silver", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Hotdog", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Large", basePrice=112, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Nolans", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Panther", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_PineTree", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_PrayingHands", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_RabbitFoot", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=11} },
    { item="Base.KeyRing_Racing12", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Racing34", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Racing58", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_RainbowStar", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_RubberDuck", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_SecurityPass", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Sexy", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_Spiffos", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_StinkyFace", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
    { item="Base.KeyRing_WestMaple", basePrice=106, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=23} },
})

print("[DynamicTrading] Utility Registry Complete")
