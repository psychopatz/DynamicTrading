-- ============================================================================
-- Building Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Building.Survival] [Rarity.Common] (18 items)
    { item="Base.CampingTentKit2", basePrice=1, tags={"Building.Survival", "Rarity.Common", "Theme.Survival"}, stockRange={min=0, max=2} },
    { item="Base.HideTent", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.ImprovisedTentKit", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_BluePlaid", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SleepingBag_Camo", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SleepingBag_Cheap_Blue", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SleepingBag_Cheap_Green", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SleepingBag_Cheap_Green2", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SleepingBag_Green", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SleepingBag_GreenPlaid", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SleepingBag_Hide", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_HighQuality_Brown", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SleepingBag_RedPlaid", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SleepingBag_Spiffo", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.TentBlue", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.TentBrown", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.TentGreen", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.TentYellow", basePrice=1, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=2} },

    -- [Building.Survival] [Rarity.Rare] (18 items)
    { item="Base.CampingTentKit2_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare", "Theme.Survival"}, stockRange={min=0, max=2} },
    { item="Base.HideTent_Packed", basePrice=1, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.ImprovisedTentKit_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_BluePlaid_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_Camo_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_Cheap_Blue_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_Cheap_Green2_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_Cheap_Green_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_Green_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_GreenPlaid_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_Hide_Packed", basePrice=1, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_HighQuality_Brown_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_RedPlaid_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.SleepingBag_Spiffo_Packed", basePrice=2, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.TentBlue_Packed", basePrice=1, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.TentBrown_Packed", basePrice=1, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.TentGreen_Packed", basePrice=1, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.TentYellow_Packed", basePrice=1, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=2} },

    -- [Building.Survival.Trap] [Rarity.Common] (6 items)
    { item="Base.TrapBox", basePrice=1, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.TrapCage", basePrice=1, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.TrapCrate", basePrice=1, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.TrapMouse", basePrice=4, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.TrapSnare", basePrice=2, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.TrapStick", basePrice=1, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=2, max=10} },
})

print("[DynamicTrading] Survival Registry Complete")
