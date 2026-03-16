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
    { item="Base.KeyRing_Kitty", basePrice=46, tags={"Container.Utility.KeyRing", "Rarity.Common", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=10, max=50} },

    -- [Container.Utility.KeyRing] [Rarity.Rare] (28 items)
    { item="Base.KeyRing", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Bass", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_BlueFox", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Bug", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_CarDealer", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Clover", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_EagleFlag", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_EightBall", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Forged", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Forged_Gold", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Quality.Luxury", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Forged_Silver", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Hotdog", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Large", basePrice=157, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Nolans", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Panther", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_PineTree", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_PrayingHands", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_RabbitFoot", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=10} },
    { item="Base.KeyRing_Racing12", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Racing34", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Racing58", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_RainbowStar", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_RubberDuck", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_SecurityPass", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Sexy", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_Spiffos", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_StinkyFace", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
    { item="Base.KeyRing_WestMaple", basePrice=79, tags={"Container.Utility.KeyRing", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High"}, stockRange={min=0, max=20} },
})

print("[DynamicTrading] Utility Registry Complete")
