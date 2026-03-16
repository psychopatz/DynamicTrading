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
    { item="Base.Gloves_BoneGloves", basePrice=91, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.BiteResistant", "Clothing.ScratchResistant"}, stockRange={min=0, max=4} },
    { item="Base.Gloves_BurlapWrap", basePrice=23, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_DenimWrap", basePrice=27, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_Dish", basePrice=15, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessGloves", basePrice=19, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessLeatherGloves", basePrice=19, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessLeatherGloves_Black", basePrice=19, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_FingerlessLeatherGloves_Brown", basePrice=19, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_HuntingCamo", basePrice=34, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherGloves", basePrice=47, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherGlovesBlack", basePrice=47, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherGlovesBrown", basePrice=47, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LeatherWrap", basePrice=33, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_LongWomenGloves", basePrice=19, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_RagWrap", basePrice=21, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_Surgical", basePrice=17, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Theme.Clinical"}, stockRange={min=0, max=9} },
    { item="Base.Gloves_TarpWrap", basePrice=27, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Gloves_WhiteTINT", basePrice=34, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] Hands Registry Complete")
