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
    { item="Base.BunnyTail", basePrice=35, tags={"Clothing.Accessory.Cosmetic", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.SpiffoTail", basePrice=35, tags={"Clothing.Accessory.Cosmetic", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },

    -- [Clothing.Accessory.Neck] [Rarity.Rare] (16 items)
    { item="Base.Necklace_Choker", basePrice=45, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_Choker_Amber", basePrice=45, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_Choker_Diamond", basePrice=165, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Necklace_Choker_Sapphire", basePrice=45, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_StripeBlackWhite", basePrice=62, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_StripeBlueWhite", basePrice=58, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_StripeRedWhite", basePrice=68, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_White", basePrice=75, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.ShemaghScarf", basePrice=72, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=7} },
    { item="Base.ShemaghScarf_Green", basePrice=72, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=7} },
    { item="Base.Tie_BowTieFull", basePrice=45, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Tie_BowTieWorn", basePrice=45, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Full", basePrice=45, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Full_Spiffo", basePrice=45, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Worn", basePrice=45, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Worn_Spiffo", basePrice=45, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },

    -- [Clothing.Accessory.Utility] [Rarity.Rare] (10 items)
    { item="Base.Belt2", basePrice=42, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Holster_DuctTape", basePrice=42, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Holster_Hide", basePrice=42, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HolsterAnkle", basePrice=42, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HolsterDouble", basePrice=42, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.HolsterSimple", basePrice=42, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HolsterSimple_Black", basePrice=42, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HolsterSimple_Brown", basePrice=42, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HolsterSimple_Green", basePrice=42, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.RopeBelt", basePrice=41, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },

    -- [Clothing.Accessory.Wrist.Watch] [Rarity.Rare] (16 items)
    { item="Base.WristWatch_Left_ClassicBlack", basePrice=45, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_ClassicBrown", basePrice=45, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_ClassicGold", basePrice=165, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.WristWatch_Left_ClassicMilitary", basePrice=112, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla", "Theme.Militia", "Clothing.Tactical"}, stockRange={min=0, max=9} },
    { item="Base.WristWatch_Left_DigitalBlack", basePrice=45, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_DigitalDress", basePrice=45, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_DigitalRed", basePrice=45, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_Expensive", basePrice=164, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.WristWatch_Right_ClassicBlack", basePrice=45, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_ClassicBrown", basePrice=45, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_ClassicGold", basePrice=165, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.WristWatch_Right_ClassicMilitary", basePrice=112, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla", "Theme.Militia", "Clothing.Tactical"}, stockRange={min=0, max=9} },
    { item="Base.WristWatch_Right_DigitalBlack", basePrice=45, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_DigitalDress", basePrice=45, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_DigitalRed", basePrice=45, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_Expensive", basePrice=164, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
})

print("[DynamicTrading] Accessory Registry Complete")
