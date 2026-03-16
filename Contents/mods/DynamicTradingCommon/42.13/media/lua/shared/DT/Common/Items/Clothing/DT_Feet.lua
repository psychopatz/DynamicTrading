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

    -- [Clothing.Feet] [Rarity.Rare] (28 items)
    { item="Base.Shoes_Black", basePrice=25, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_BlueTrainers", basePrice=23, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Bowling", basePrice=25, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Brown", basePrice=25, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_BurlapWrap", basePrice=18, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_CrudeLeatherFootwear", basePrice=25, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_DenimWrap", basePrice=29, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Fancy", basePrice=25, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_FlipFlop", basePrice=3, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_HideBoots", basePrice=77, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.Protective", "Clothing.BiteResistant", "Clothing.ScratchResistant", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_LeatherWrap", basePrice=36, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_RagWrap", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Random", basePrice=28, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_RedTrainers", basePrice=23, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Sandals", basePrice=25, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Slippers", basePrice=3, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Strapped", basePrice=25, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_TarpWrap", basePrice=29, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_TireSandals", basePrice=25, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_TrainerTINT", basePrice=23, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Twine", basePrice=25, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Ankle", basePrice=9, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Ankle_Black", basePrice=9, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Ankle_White", basePrice=9, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Heavy", basePrice=21, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Long", basePrice=14, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Long_Black", basePrice=14, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Long_White", basePrice=14, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] Feet Registry Complete")
