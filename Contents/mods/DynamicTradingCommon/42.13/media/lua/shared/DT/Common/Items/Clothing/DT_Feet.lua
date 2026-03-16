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
    { item="Base.Shoes_Black", basePrice=54, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_BlueTrainers", basePrice=52, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Bowling", basePrice=54, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Brown", basePrice=54, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_BurlapWrap", basePrice=47, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_CrudeLeatherFootwear", basePrice=54, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_DenimWrap", basePrice=58, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Fancy", basePrice=54, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_FlipFlop", basePrice=32, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_HideBoots", basePrice=134, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.BiteResistant", "Clothing.ScratchResistant", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_LeatherWrap", basePrice=65, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_RagWrap", basePrice=45, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Random", basePrice=57, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_RedTrainers", basePrice=52, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Sandals", basePrice=54, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Slippers", basePrice=32, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Strapped", basePrice=54, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_TarpWrap", basePrice=58, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_TireSandals", basePrice=54, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_TrainerTINT", basePrice=52, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Twine", basePrice=54, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Ankle", basePrice=38, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Ankle_Black", basePrice=38, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Ankle_White", basePrice=38, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Heavy", basePrice=50, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Long", basePrice=43, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Long_Black", basePrice=43, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Long_White", basePrice=43, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] Feet Registry Complete")
