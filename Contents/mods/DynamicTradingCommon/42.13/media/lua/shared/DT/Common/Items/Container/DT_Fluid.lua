-- =============================================================================
-- DYNAMIC TRADING: CONTAINER - FLUID
-- =============================================================================
-- Root Category: Container
-- Sub Category: Fluid
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Bag_LeatherWaterBag", tags={"Container.Fluid", "Origin.Nomad", "Rarity.Common"}, basePrice=85, stockRange={min=1, max=2} },
    { item="Base.BeerCanEmpty",     tags={"Container.Fluid", "Resource.Material.Metal", "Origin.Civ"}, basePrice=1, stockRange={min=10, max=30} },
    { item="Base.BeerEmpty",        tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"}, basePrice=1, stockRange={min=10, max=30} },
    { item="Base.BucketEmpty",     tags={"Container.Fluid", "Resource.Material.Plastic", "Rarity.Common"}, basePrice=20, stockRange={min=2, max=6} },
    { item="Base.BucketForged",    tags={"Container.Fluid", "Resource.Material.Metal", "Rarity.Uncommon"},      basePrice=45, stockRange={min=0, max=2} },
    { item="Base.BucketLargeWood", tags={"Container.Fluid", "Resource.Material.Wood", "Rarity.Common"}, basePrice=30, stockRange={min=1, max=3} },
    { item="Base.BucketWood",      tags={"Container.Fluid", "Origin.Nomad", "Rarity.Common"},     basePrice=15, stockRange={min=2, max=5} },
    { item="Base.Canteen",             tags={"Container.Fluid", "Rarity.Common"}, basePrice=45, stockRange={min=1, max=4} },
    { item="Base.CanteenClay",         tags={"Container.Fluid", "Quality.Primitive", "Rarity.Common"}, basePrice=35, stockRange={min=1, max=3} },
    { item="Base.CanteenCowboy",       tags={"Container.Fluid", "Theme.Survival", "Rarity.Common"}, basePrice=65, stockRange={min=1, max=3} },
    { item="Base.CanteenMilitary",            tags={"Container.Fluid", "Origin.Militia", "Rarity.Uncommon"}, basePrice=100, stockRange={min=1, max=2} },
    { item="Base.CanteenMilitaryFull",        tags={"Container.Fluid", "Origin.Militia", "Rarity.Uncommon"}, basePrice=120, stockRange={min=1, max=2} },
    { item="Base.Flask",               tags={"Container.Fluid", "Rarity.Common"}, basePrice=55, stockRange={min=1, max=2} },
    { item="Base.Goblet_Wood",    tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"},         basePrice=4,  stockRange={min=1, max=4} },
    { item="Base.JerryCan",                tags={"Container.Fluid", "Theme.Survival", "Rarity.Uncommon"}, basePrice=350, stockRange={min=1, max=2} },
    { item="Base.MayonnaiseEmpty",  tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"}, basePrice=2, stockRange={min=2, max=8} },
    { item="Base.PopBottle",        tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"}, basePrice=3, stockRange={min=5, max=15} },
    { item="Base.PopEmpty",         tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"}, basePrice=1, stockRange={min=10, max=30} },
    { item="Base.Sportsbottle",        tags={"Container.Fluid", "Rarity.Common"}, basePrice=25, stockRange={min=2, max=5} },
    { item="Base.WaterBottle",      tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"}, basePrice=4, stockRange={min=5, max=15} },
    { item="Base.WaterDispenserBottle",    tags={"Container.Fluid", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=220, stockRange={min=1, max=2} },
    { item="Base.WateredCan",      tags={"Container.Fluid", "Theme.Utility", "Rarity.Common"},          basePrice=25, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Container/Fluid Registry Loaded.")
