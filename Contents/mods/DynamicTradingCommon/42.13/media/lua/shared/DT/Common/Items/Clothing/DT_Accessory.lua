-- ============================================================================
-- Clothing Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Clothing.Accessory.Cosmetic] [Rarity.Rare] (2 items)
    { item="Base.BunnyTail", basePrice=1, tags={"Clothing.Accessory.Cosmetic", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=6} },
    { item="Base.SpiffoTail", basePrice=1, tags={"Clothing.Accessory.Cosmetic", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=6} },

    -- [Clothing.Accessory.Neck] [Rarity.Rare] (16 items)
    { item="Base.Necklace_Choker", basePrice=1, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_Choker_Amber", basePrice=1, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_Choker_Diamond", basePrice=1, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_Choker_Sapphire", basePrice=1, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.Scarf_StripeBlackWhite", basePrice=27, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
    { item="Base.Scarf_StripeBlueWhite", basePrice=22, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.Scarf_StripeRedWhite", basePrice=35, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
    { item="Base.Scarf_White", basePrice=42, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
    { item="Base.ShemaghScarf", basePrice=32, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=6} },
    { item="Base.ShemaghScarf_Green", basePrice=32, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=6} },
    { item="Base.Tie_BowTieFull", basePrice=1, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=6} },
    { item="Base.Tie_BowTieWorn", basePrice=1, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.Tie_Full", basePrice=1, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.Tie_Full_Spiffo", basePrice=1, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.Tie_Worn", basePrice=1, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.Tie_Worn_Spiffo", basePrice=1, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },

    -- [Clothing.Accessory.Utility] [Rarity.Rare] (10 items)
    { item="Base.Belt2", basePrice=1, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.Holster_DuctTape", basePrice=1, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.Holster_Hide", basePrice=1, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.HolsterAnkle", basePrice=1, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.HolsterDouble", basePrice=1, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=6} },
    { item="Base.HolsterSimple", basePrice=1, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.HolsterSimple_Black", basePrice=1, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.HolsterSimple_Brown", basePrice=1, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.HolsterSimple_Green", basePrice=1, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=10} },
    { item="Base.RopeBelt", basePrice=1, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Clothing.Accessory"}, stockRange={min=0, max=4} },

    -- [Clothing.Accessory.Wrist.Watch] [Rarity.Rare] (16 items)
    { item="Base.WristWatch_Left_ClassicBlack", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Left_ClassicBrown", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Left_ClassicGold", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Left_ClassicMilitary", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Militia", "Clothing.Accessory", "Clothing.Accessory.Wrist", "Clothing.Tactical"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Left_DigitalBlack", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Left_DigitalDress", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Left_DigitalRed", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Left_Expensive", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Right_ClassicBlack", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Right_ClassicBrown", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Right_ClassicGold", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Right_ClassicMilitary", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Militia", "Clothing.Accessory", "Clothing.Accessory.Wrist", "Clothing.Tactical"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Right_DigitalBlack", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Right_DigitalDress", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Right_DigitalRed", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
    { item="Base.WristWatch_Right_Expensive", basePrice=1, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Wrist"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Accessory Registry Complete")
