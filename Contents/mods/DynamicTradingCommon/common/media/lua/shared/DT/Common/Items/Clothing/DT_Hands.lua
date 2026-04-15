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
    { item="Base.Gloves_BoneGloves", basePrice=159, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.BiteResistant", "Clothing.ScratchResistant"}, stockRange={min=0, max=4} },
    { item="Base.Gloves_BurlapWrap", basePrice=63, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_DenimWrap", basePrice=67, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_Dish", basePrice=55, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessGloves", basePrice=59, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessLeatherGloves", basePrice=59, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessLeatherGloves_Black", basePrice=59, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessLeatherGloves_Brown", basePrice=59, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_HuntingCamo", basePrice=74, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherGloves", basePrice=101, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherGlovesBlack", basePrice=101, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherGlovesBrown", basePrice=101, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherWrap", basePrice=74, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LongWomenGloves", basePrice=59, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_RagWrap", basePrice=61, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_Surgical", basePrice=62, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Theme.Clinical"}, stockRange={min=0, max=9} },
    { item="Base.Gloves_TarpWrap", basePrice=67, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_WhiteTINT", basePrice=74, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] Hands Registry Complete")
