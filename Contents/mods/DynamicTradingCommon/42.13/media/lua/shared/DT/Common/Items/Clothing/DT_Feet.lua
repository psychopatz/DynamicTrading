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
    { item="Base.Shoes_Black", basePrice=616, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_BlueTrainers", basePrice=613, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Bowling", basePrice=616, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Brown", basePrice=615, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_BurlapWrap", basePrice=608, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_CrudeLeatherFootwear", basePrice=616, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_DenimWrap", basePrice=619, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Fancy", basePrice=616, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_FlipFlop", basePrice=593, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_HideBoots", basePrice=1198, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.Protective", "Clothing.BiteResistant", "Clothing.ScratchResistant", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_LeatherWrap", basePrice=626, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_RagWrap", basePrice=606, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Random", basePrice=618, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_RedTrainers", basePrice=613, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Sandals", basePrice=616, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Slippers", basePrice=593, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Strapped", basePrice=616, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_TarpWrap", basePrice=619, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_TireSandals", basePrice=616, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_TrainerTINT", basePrice=613, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Shoes_Twine", basePrice=616, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.ScratchResistant"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Ankle", basePrice=599, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Ankle_Black", basePrice=599, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Ankle_White", basePrice=599, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Heavy", basePrice=611, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Long", basePrice=604, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Long_Black", basePrice=604, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Socks_Long_White", basePrice=604, tags={"Clothing.Feet", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] Feet Registry Complete")
