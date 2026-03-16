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

    -- [Clothing.Hands] [Rarity.Rare] (18 items)
    { item="Base.Gloves_BoneGloves", basePrice=1448, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.BiteResistant", "Clothing.ScratchResistant"}, stockRange={min=0, max=4} },
    { item="Base.Gloves_BurlapWrap", basePrice=849, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_DenimWrap", basePrice=853, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_Dish", basePrice=841, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessGloves", basePrice=845, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessLeatherGloves", basePrice=845, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessLeatherGloves_Black", basePrice=845, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessLeatherGloves_Brown", basePrice=845, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_HuntingCamo", basePrice=860, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherGloves", basePrice=1123, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherGlovesBlack", basePrice=1123, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherGlovesBrown", basePrice=1123, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherWrap", basePrice=860, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LongWomenGloves", basePrice=845, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_RagWrap", basePrice=847, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_Surgical", basePrice=942, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Theme.Clinical"}, stockRange={min=0, max=9} },
    { item="Base.Gloves_TarpWrap", basePrice=853, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_WhiteTINT", basePrice=860, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] Hands Registry Complete")
