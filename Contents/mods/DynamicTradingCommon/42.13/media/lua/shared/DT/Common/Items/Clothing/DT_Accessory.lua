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
    { item="Base.BunnyTail", basePrice=596, tags={"Clothing.Accessory.Cosmetic", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.SpiffoTail", basePrice=596, tags={"Clothing.Accessory.Cosmetic", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },

    -- [Clothing.Accessory.Neck] [Rarity.Rare] (16 items)
    { item="Base.Necklace_Choker", basePrice=803, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_Choker_Amber", basePrice=803, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_Choker_Diamond", basePrice=3141, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Necklace_Choker_Sapphire", basePrice=803, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_StripeBlackWhite", basePrice=821, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_StripeBlueWhite", basePrice=816, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_StripeRedWhite", basePrice=827, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Scarf_White", basePrice=833, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.ShemaghScarf", basePrice=830, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=7} },
    { item="Base.ShemaghScarf_Green", basePrice=830, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=7} },
    { item="Base.Tie_BowTieFull", basePrice=803, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Tie_BowTieWorn", basePrice=803, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Full", basePrice=803, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Full_Spiffo", basePrice=803, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Worn", basePrice=803, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Tie_Worn_Spiffo", basePrice=803, tags={"Clothing.Accessory.Neck", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },

    -- [Clothing.Accessory.Utility] [Rarity.Rare] (10 items)
    { item="Base.Belt2", basePrice=745, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Holster_DuctTape", basePrice=745, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Holster_Hide", basePrice=745, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HolsterAnkle", basePrice=745, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HolsterDouble", basePrice=745, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.HolsterSimple", basePrice=745, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HolsterSimple_Black", basePrice=745, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HolsterSimple_Brown", basePrice=745, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HolsterSimple_Green", basePrice=745, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.RopeBelt", basePrice=744, tags={"Clothing.Accessory.Utility", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },

    -- [Clothing.Accessory.Wrist.Watch] [Rarity.Rare] (16 items)
    { item="Base.WristWatch_Left_ClassicBlack", basePrice=793, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_ClassicBrown", basePrice=793, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_ClassicGold", basePrice=3125, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.WristWatch_Left_ClassicMilitary", basePrice=2096, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla", "Theme.Militia", "Clothing.Tactical"}, stockRange={min=0, max=9} },
    { item="Base.WristWatch_Left_DigitalBlack", basePrice=793, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_DigitalDress", basePrice=793, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_DigitalRed", basePrice=793, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Left_Expensive", basePrice=3125, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.WristWatch_Right_ClassicBlack", basePrice=793, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_ClassicBrown", basePrice=793, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_ClassicGold", basePrice=3125, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.WristWatch_Right_ClassicMilitary", basePrice=2096, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla", "Theme.Militia", "Clothing.Tactical"}, stockRange={min=0, max=9} },
    { item="Base.WristWatch_Right_DigitalBlack", basePrice=793, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_DigitalDress", basePrice=793, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_DigitalRed", basePrice=793, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.WristWatch_Right_Expensive", basePrice=3125, tags={"Clothing.Accessory.Wrist.Watch", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
})

print("[DynamicTrading] Accessory Registry Complete")
