-- =============================================================================
-- DYNAMIC TRADING: TOOL - COOKING
-- =============================================================================
-- Root Category: Tool
-- Sub Category: Cooking
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BastingBrush",         basePrice=2,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.BottleOpener", basePrice=10, tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.BottleOpener_Keychain",basePrice=10, tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.CheeseGrater",         basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Chopsticks",           basePrice=1,  tags={"Tool.Cooking.Utensil", "Theme.Asian", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.Corkscrew", basePrice=10, tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.CuttingBoardPlastic",  basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.CuttingBoardWooden",   basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Fork_Gold",            basePrice=15, tags={"Tool.Cooking.Utensil", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=2} },
    { item="Base.Fork_Silver",          basePrice=10, tags={"Tool.Cooking.Utensil", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.GrillBrush",           basePrice=2,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.KitchenTongs",         basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.KnifeFillet",          basePrice=65, tags={"Tool.Cooking", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=3} },
    { item="Base.Ladle",                basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.PizzaCutter",          basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Spatula",              basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Spoon_Gold",           basePrice=15, tags={"Tool.Cooking.Utensil", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=2} },
    { item="Base.Spoon_Silver",         basePrice=10, tags={"Tool.Cooking.Utensil", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.Spork",                   basePrice=5,   tags={"Tool.Cooking.Utensil", "Quality.Waste", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.TinOpener", basePrice=45, tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.TinOpener_Old", basePrice=35, tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Whisk",                basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=2, max=10} },
})

print("[DynamicTrading] Tool/Cooking Registry Loaded.")
