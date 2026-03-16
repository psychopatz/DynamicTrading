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
    { item="Base.BunnyTail", basePrice=6, tags={"Clothing.Accessory.Cosmetic", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.SpiffoTail", basePrice=6, tags={"Clothing.Accessory.Cosmetic", "Rarity.Rare"}, stockRange={min=0, max=12} },

    -- [Clothing.Accessory.Neck] [Rarity.Rare] (16 items)
    { item="Base.Necklace_Choker", basePrice=6, tags={"Clothing.Accessory.Neck", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_Choker_Amber", basePrice=6, tags={"Clothing.Accessory.Neck", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_Choker_Diamond", basePrice=9, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Quality.Luxury"}, stockRange={min=0, max=8} },
    { item="Base.Necklace_Choker_Sapphire", basePrice=6, tags={"Clothing.Accessory.Neck", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_StripeBlackWhite", basePrice=23, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_StripeBlueWhite", basePrice=19, tags={"Clothing.Accessory.Neck", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_StripeRedWhite", basePrice=29, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_White", basePrice=36, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.ShemaghScarf", basePrice=33, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=7} },
    { item="Base.ShemaghScarf_Green", basePrice=33, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=7} },
    { item="Base.Tie_BowTieFull", basePrice=6, tags={"Clothing.Accessory.Neck", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Tie_BowTieWorn", basePrice=6, tags={"Clothing.Accessory.Neck", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Full", basePrice=6, tags={"Clothing.Accessory.Neck", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Full_Spiffo", basePrice=6, tags={"Clothing.Accessory.Neck", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Worn", basePrice=6, tags={"Clothing.Accessory.Neck", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Worn_Spiffo", basePrice=6, tags={"Clothing.Accessory.Neck", "Rarity.Rare"}, stockRange={min=0, max=12} },

    -- [Clothing.Accessory.Utility] [Rarity.Rare] (10 items)
    { item="Base.Belt2", basePrice=6, tags={"Clothing.Accessory.Utility", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Holster_DuctTape", basePrice=6, tags={"Clothing.Accessory.Utility", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Holster_Hide", basePrice=6, tags={"Clothing.Accessory.Utility", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.HolsterAnkle", basePrice=6, tags={"Clothing.Accessory.Utility", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.HolsterDouble", basePrice=5, tags={"Clothing.Accessory.Utility", "Rarity.Rare"}, stockRange={min=0, max=7} },
    { item="Base.HolsterSimple", basePrice=6, tags={"Clothing.Accessory.Utility", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.HolsterSimple_Black", basePrice=6, tags={"Clothing.Accessory.Utility", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.HolsterSimple_Brown", basePrice=6, tags={"Clothing.Accessory.Utility", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.HolsterSimple_Green", basePrice=6, tags={"Clothing.Accessory.Utility", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.RopeBelt", basePrice=5, tags={"Clothing.Accessory.Utility", "Rarity.Rare"}, stockRange={min=0, max=4} },

    -- [Clothing.Accessory.Wrist.Watch] [Rarity.Rare] (16 items)
    { item="Base.WristWatch_Left_ClassicBlack", basePrice=6, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_ClassicBrown", basePrice=6, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_ClassicGold", basePrice=9, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury"}, stockRange={min=0, max=8} },
    { item="Base.WristWatch_Left_ClassicMilitary", basePrice=7, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Militia", "Clothing.Tactical"}, stockRange={min=0, max=9} },
    { item="Base.WristWatch_Left_DigitalBlack", basePrice=6, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_DigitalDress", basePrice=6, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_DigitalRed", basePrice=6, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_Expensive", basePrice=9, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury"}, stockRange={min=0, max=8} },
    { item="Base.WristWatch_Right_ClassicBlack", basePrice=6, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_ClassicBrown", basePrice=6, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_ClassicGold", basePrice=9, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury"}, stockRange={min=0, max=8} },
    { item="Base.WristWatch_Right_ClassicMilitary", basePrice=7, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Militia", "Clothing.Tactical"}, stockRange={min=0, max=9} },
    { item="Base.WristWatch_Right_DigitalBlack", basePrice=6, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_DigitalDress", basePrice=6, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_DigitalRed", basePrice=6, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_Expensive", basePrice=9, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury"}, stockRange={min=0, max=8} },
})

print("[DynamicTrading] Accessory Registry Complete")
