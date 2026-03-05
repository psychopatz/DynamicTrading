-- =============================================================================
-- DYNAMIC TRADING: RESOURCE - FUEL
-- =============================================================================
-- Root Category: Resource
-- Sub Category: Fuel
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BBQStarterFluid",  basePrice=35, tags={"Resource.Fuel.Igniter", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Charcoal",          tags={"Resource.Fuel.Solid", "Theme.Survival", "Rarity.Common"},        basePrice=15, stockRange={min=10, max=40} },
    { item="Base.Coke",              tags={"Resource.Fuel.Industrial", "Rarity.Uncommon"},                   basePrice=25, stockRange={min=5, max=20} },
    { item="Base.DryFirestarterBlock", basePrice=15, tags={"Resource.Fuel.Organic", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.LighterFluid",     basePrice=35, tags={"Resource.Fuel.Igniter", "Rarity.Common"}, stockRange={min=2, max=10} }, -- Accelerant,
    { item="Base.MagnesiumShavings", basePrice=5, tags={"Resource.Fuel.Organic", "Rarity.Common"}, stockRange={min=5, max=10} },
    { item="Base.PetrolCan", basePrice=250, tags={"Resource.Fuel.Container", "Theme.Survival", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
    { item="Base.PropaneTank",       tags={"Resource.Fuel.Liquid", "Rarity.Rare"},          basePrice=500, stockRange={min=1, max=3} }, -- Worth: 250.0,
})

print("[DynamicTrading] Resource/Fuel Registry Loaded.")
