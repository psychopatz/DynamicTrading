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

    -- [Container.Bag.Bandolier] [Rarity.Rare] (23 items)
    { item="Base.AmmoStrap_Brown_Bullets", basePrice=106, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=11} },
    { item="Base.AmmoStrap_Brown_Shells", basePrice=106, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=11} },
    { item="Base.AmmoStrap_Bullets", basePrice=106, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=11} },
    { item="Base.AmmoStrap_Bullets_308", basePrice=106, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=11} },
    { item="Base.AmmoStrap_Shells", basePrice=106, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=11} },
    { item="Base.Bag_AmmoBox", basePrice=101, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_AmmoBox_308", basePrice=101, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_AmmoBox_38", basePrice=101, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_AmmoBox_44", basePrice=101, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_AmmoBox_45", basePrice=101, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_AmmoBox_9mm", basePrice=101, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_AmmoBox_Hunting", basePrice=101, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_AmmoBox_Mixed", basePrice=101, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_AmmoBox_ShotgunShells", basePrice=101, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ProtectiveCaseBulkyAmmo", basePrice=159, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ProtectiveCaseBulkyAmmo_308", basePrice=159, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ProtectiveCaseBulkyAmmo_38", basePrice=159, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ProtectiveCaseBulkyAmmo_44", basePrice=159, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ProtectiveCaseBulkyAmmo_45", basePrice=159, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ProtectiveCaseBulkyAmmo_556", basePrice=159, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ProtectiveCaseBulkyAmmo_9mm", basePrice=159, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ProtectiveCaseBulkyAmmo_Hunting", basePrice=159, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Bag_ProtectiveCaseBulkyAmmo_ShotgunShells", basePrice=159, tags={"Container.Bag.Bandolier", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },

    -- [Container.Bag.Holster] [Rarity.Rare] (1 item)
    { item="Base.HolsterShoulder", basePrice=106, tags={"Container.Bag.Holster", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=6} },

    -- [Container.Bag.Rig] [Rarity.Rare] (5 items)
    { item="Base.Bag_ALICE_BeltSus", basePrice=130, tags={"Container.Bag.Rig", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=11} },
    { item="Base.Bag_ALICE_BeltSus_Camo", basePrice=130, tags={"Container.Bag.Rig", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=11} },
    { item="Base.Bag_ALICE_BeltSus_Green", basePrice=130, tags={"Container.Bag.Rig", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=11} },
    { item="Base.Bag_ChestRig", basePrice=129, tags={"Container.Bag.Rig", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=11} },
    { item="Base.Bag_ChestRig_Tarp", basePrice=129, tags={"Container.Bag.Rig", "Rarity.Rare", "Container.Capacity.Low", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=11} },
})

print("[DynamicTrading] Wearable Registry Complete")
