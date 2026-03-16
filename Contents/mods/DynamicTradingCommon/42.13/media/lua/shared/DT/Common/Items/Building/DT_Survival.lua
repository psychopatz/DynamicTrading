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
    { item="Base.CampingTentKit2", basePrice=27, tags={"Building.Survival", "Rarity.Common", "Theme.Survival"}, stockRange={min=0, max=1} },
    { item="Base.HideTent", basePrice=22, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=1} },
    { item="Base.ImprovisedTentKit", basePrice=26, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_BluePlaid", basePrice=23, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.SleepingBag_Camo", basePrice=23, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.SleepingBag_Cheap_Blue", basePrice=23, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.SleepingBag_Cheap_Green", basePrice=23, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.SleepingBag_Cheap_Green2", basePrice=23, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.SleepingBag_Green", basePrice=23, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.SleepingBag_GreenPlaid", basePrice=23, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.SleepingBag_Hide", basePrice=23, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_HighQuality_Brown", basePrice=23, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.SleepingBag_RedPlaid", basePrice=23, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.SleepingBag_Spiffo", basePrice=23, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.TentBlue", basePrice=22, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=1} },
    { item="Base.TentBrown", basePrice=22, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=1} },
    { item="Base.TentGreen", basePrice=22, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=1} },
    { item="Base.TentYellow", basePrice=22, tags={"Building.Survival", "Rarity.Common"}, stockRange={min=0, max=1} },

    -- [Building.Survival] [Rarity.Rare] (18 items)
    { item="Base.CampingTentKit2_Packed", basePrice=41, tags={"Building.Survival", "Rarity.Rare", "Theme.Survival"}, stockRange={min=0, max=1} },
    { item="Base.HideTent_Packed", basePrice=40, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.ImprovisedTentKit_Packed", basePrice=40, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_BluePlaid_Packed", basePrice=41, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_Camo_Packed", basePrice=41, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_Cheap_Blue_Packed", basePrice=41, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_Cheap_Green2_Packed", basePrice=41, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_Cheap_Green_Packed", basePrice=41, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_Green_Packed", basePrice=41, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_GreenPlaid_Packed", basePrice=41, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_Hide_Packed", basePrice=40, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_HighQuality_Brown_Packed", basePrice=41, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_RedPlaid_Packed", basePrice=41, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.SleepingBag_Spiffo_Packed", basePrice=41, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.TentBlue_Packed", basePrice=40, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.TentBrown_Packed", basePrice=40, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.TentGreen_Packed", basePrice=40, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.TentYellow_Packed", basePrice=40, tags={"Building.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },

    -- [Building.Survival.Trap] [Rarity.Common] (6 items)
    { item="Base.TrapBox", basePrice=19, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.TrapCage", basePrice=20, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.TrapCrate", basePrice=29, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=0, max=3} },
    { item="Base.TrapMouse", basePrice=21, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=1, max=11} },
    { item="Base.TrapSnare", basePrice=21, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=1, max=11} },
    { item="Base.TrapStick", basePrice=21, tags={"Building.Survival.Trap", "Rarity.Common"}, stockRange={min=0, max=7} },
})

print("[DynamicTrading] Survival Registry Complete")
