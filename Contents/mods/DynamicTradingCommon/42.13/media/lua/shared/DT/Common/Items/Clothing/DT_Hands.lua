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
    { item="Base.Gloves_BoneGloves", basePrice=127, tags={"Clothing.Hands", "Rarity.Rare", "Clothing.Protective", "Clothing.BiteResistant", "Clothing.ScratchResistant"}, stockRange={min=0, max=4} },
    { item="Base.Gloves_BurlapWrap", basePrice=27, tags={"Clothing.Hands", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_DenimWrap", basePrice=37, tags={"Clothing.Hands", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_Dish", basePrice=17, tags={"Clothing.Hands", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_FingerlessGloves", basePrice=30, tags={"Clothing.Hands", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_FingerlessLeatherGloves", basePrice=30, tags={"Clothing.Hands", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_FingerlessLeatherGloves_Black", basePrice=30, tags={"Clothing.Hands", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_FingerlessLeatherGloves_Brown", basePrice=30, tags={"Clothing.Hands", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_HuntingCamo", basePrice=46, tags={"Clothing.Hands", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_LeatherGloves", basePrice=128, tags={"Clothing.Hands", "Rarity.Rare", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_LeatherGlovesBlack", basePrice=128, tags={"Clothing.Hands", "Rarity.Rare", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_LeatherGlovesBrown", basePrice=128, tags={"Clothing.Hands", "Rarity.Rare", "Clothing.Protective", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_LeatherWrap", basePrice=69, tags={"Clothing.Hands", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_LongWomenGloves", basePrice=20, tags={"Clothing.Hands", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_RagWrap", basePrice=21, tags={"Clothing.Hands", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_Surgical", basePrice=17, tags={"Clothing.Hands", "Rarity.Rare", "Origin.Clinical"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_TarpWrap", basePrice=37, tags={"Clothing.Hands", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=10} },
    { item="Base.Gloves_WhiteTINT", basePrice=46, tags={"Clothing.Hands", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Hands Registry Complete")
