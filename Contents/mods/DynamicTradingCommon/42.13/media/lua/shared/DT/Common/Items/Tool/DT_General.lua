-- =============================================================================
-- DYNAMIC TRADING: TOOL - GENERAL
-- =============================================================================
-- Root Category: Tool
-- Sub Category: General
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Bullhorn",             tags={"Tool.General.Noise", "Origin.Police", "Rarity.Uncommon"}, basePrice=160, stockRange={min=0, max=2} },
    { item="Base.Extinguisher",     basePrice=150, tags={"Tool.General.Safety", "Quality.Sterile", "Rarity.Uncommon"}, stockRange={min=1, max=3} }, -- Saves bases,
    { item="Base.Fork",                 basePrice=1,  tags={"Tool.General", "Quality.Waste", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.ForkForged",           basePrice=2,  tags={"Tool.General", "Quality.Basic", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Fork_Bone",            basePrice=1,  tags={"Tool.General", "Origin.Nomad", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.Funnel",               tags={"Tool.General.Liquid", "Rarity.Common"},       basePrice=25,  stockRange={min=2, max=6} },
    { item="Base.HeavyChain",               tags={"Tool.General.Heavy", "Origin.Industrial", "Rarity.Uncommon"}, basePrice=140, stockRange={min=1, max=3} },
    { item="Base.HeavyChain_Hook",          tags={"Tool.General.Heavy", "Origin.Industrial", "Rarity.Uncommon"}, basePrice=180, stockRange={min=1, max=2} },
    { item="Base.KnifeSushi",           basePrice=65, tags={"Tool.General", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
    { item="Base.MagnifyingGlass",  basePrice=35, tags={"Tool.General.Survival", "Theme.Survival", "Rarity.Rare"}, stockRange={min=1, max=3} }, -- Foraging light fire,
    { item="Base.PlasticFork",          basePrice=0,  tags={"Tool.General", "Quality.Waste", "Rarity.Common"}, stockRange={min=10, max=50} },
    { item="Base.PlasticSpoon",         basePrice=0,  tags={"Tool.General", "Quality.Waste", "Rarity.Common"}, stockRange={min=10, max=50} },
    { item="Base.RailroadSpikePuller",      tags={"Tool.General.Heavy", "Origin.Industrial", "Rarity.Uncommon"}, basePrice=240, stockRange={min=0, max=1} },
    { item="Base.RubberHose",           tags={"Tool.General.Liquid", "Rarity.Common"},       basePrice=35,  stockRange={min=2, max=8} },
    { item="Base.SkewersWooden",        basePrice=0,  tags={"Tool.General", "Quality.Waste", "Rarity.Common"}, stockRange={min=10, max=50} },
    { item="Base.Spoon",                basePrice=1,  tags={"Tool.General", "Quality.Waste", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.SpoonForged",          basePrice=2,  tags={"Tool.General", "Quality.Basic", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Spoon_Bone",           basePrice=1,  tags={"Tool.General", "Origin.Nomad", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.SteelWool",            tags={"Tool.General.Clean", "Rarity.Common"},        basePrice=15,  stockRange={min=5, max=15} },
    { item="Base.Whistle",              basePrice=25,  tags={"Tool.General", "Theme.Combat", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Whistle_Bone",         basePrice=15,  tags={"Tool.General", "Theme.Survival", "Origin.Nomad"}, stockRange={min=1, max=5} },
    { item="Base.WoodenFork",           basePrice=1,  tags={"Tool.General", "Origin.Nomad", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.WoodenSpoon",          basePrice=1,  tags={"Tool.General", "Origin.Nomad", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.Zipties",              tags={"Tool.General.Restraint", "Rarity.Common"},    basePrice=25,  stockRange={min=5, max=20} },
})

print("[DynamicTrading] Tool/General Registry Loaded.")
