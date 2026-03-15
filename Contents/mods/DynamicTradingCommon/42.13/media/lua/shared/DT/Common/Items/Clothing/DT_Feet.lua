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
    { item="Base.Shoes_Black", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_BlueTrainers", basePrice=1, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_Bowling", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_Brown", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_BurlapWrap", basePrice=21, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Shoes_CrudeLeatherFootwear", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_DenimWrap", basePrice=40, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
    { item="Base.Shoes_Fancy", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_FlipFlop", basePrice=1, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_HideBoots", basePrice=58, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.Protective", "Clothing.BiteResistant", "Clothing.ScratchResistant", "Clothing.WindResistant"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_LeatherWrap", basePrice=72, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
    { item="Base.Shoes_RagWrap", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Shoes_Random", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_RedTrainers", basePrice=1, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_Sandals", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_Slippers", basePrice=1, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_Strapped", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_TarpWrap", basePrice=40, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
    { item="Base.Shoes_TireSandals", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_TrainerTINT", basePrice=1, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Shoes_Twine", basePrice=16, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.ScratchResistant"}, stockRange={min=0, max=6} },
    { item="Base.Socks_Ankle", basePrice=5, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Socks_Ankle_Black", basePrice=5, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Socks_Ankle_White", basePrice=5, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Socks_Heavy", basePrice=19, tags={"Clothing.Feet", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=10} },
    { item="Base.Socks_Long", basePrice=13, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Socks_Long_Black", basePrice=13, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Socks_Long_White", basePrice=13, tags={"Clothing.Feet", "Rarity.Rare"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Feet Registry Complete")
