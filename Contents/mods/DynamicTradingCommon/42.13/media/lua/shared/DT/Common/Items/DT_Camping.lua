
require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. SURVIVAL GADGETS & FIRE
-- =============================================================================
-- Magnesium Firestarter is the holy grail of fire starting (durable).
{ item="Base.MagnesiumFirestarter", basePrice=120, tags={"Tool.Camping.Fire", "Theme.Survival", "Rarity.Rare"}, stockRange={min=1, max=2} },
{ item="Base.MagnesiumShavings", basePrice=5, tags={"Resource.Fuel.Organic", "Rarity.Common"}, stockRange={min=5, max=10} },
{ item="Base.DryFirestarterBlock", basePrice=15, tags={"Resource.Fuel.Organic", "Rarity.Common"}, stockRange={min=2, max=10} },
 
-- Notched plank is craftable, but usable.
{ item="Base.PercedWood",              basePrice=45,  tags={"Tool.Camping.Fire", "Origin.Primitive", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.TwigsBundle",             basePrice=5,   tags={"Resource.Fuel.Organic", "Resource.Material.Wood", "Rarity.Common"}, stockRange={min=5, max=15} },

-- Survival Utilities
{ item="Base.CompassDirectional",      basePrice=45,  tags={"Tool.Navigation", "Theme.Survival", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.WaterPurificationTablets",basePrice=180, tags={"Medical.Utility.Purification", "Theme.Survival", "Rarity.Rare"}, stockRange={min=1, max=3} }, -- High value life-saver
{ item="Base.InsectRepellent",         basePrice=35,  tags={"Medical.Utility.Protection", "Rarity.Common"}, stockRange={min=2, max=8} },

-- Junk
{ item="Base.Spork",                   basePrice=5,   tags={"Tool.Cooking.Utensil", "Quality.Junk", "Rarity.Common"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 2. SLEEPING BAGS (Fatigue Management)
-- =============================================================================
-- Prices scale with Quality (Fatigue reduction speed)

-- Tier 1: Hide / Primitive (Craftable)
{ item="Base.SleepingBag_Hide",             basePrice=80,  tags={"Tool.Camping.Bedding", "Theme.Winter", "Quality.Primitive", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.SleepingBag_Hide_Packed",      basePrice=80,  tags={"Tool.Camping.Bedding", "Theme.Winter", "Quality.Primitive", "Rarity.Common"}, stockRange={min=1, max=3} },

-- Tier 2: Cheap (Low quality sleep)
{ item="Base.SleepingBag_Cheap_Blue",       basePrice=120, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.SleepingBag_Cheap_Green",      basePrice=120, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.SleepingBag_Cheap_Green2",     basePrice=120, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.SleepingBag_Cheap_Blue_Packed",  basePrice=120, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.SleepingBag_Cheap_Green_Packed", basePrice=120, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.SleepingBag_Cheap_Green2_Packed",basePrice=120, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Common"}, stockRange={min=1, max=3} },

-- Tier 3: Standard (Good sleep)
{ item="Base.SleepingBag_BluePlaid",        basePrice=200, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.SleepingBag_Camo",             basePrice=220, tags={"Tool.Camping.Bedding", "Theme.Winter", "Origin.Military", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.SleepingBag_Green",            basePrice=200, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.SleepingBag_GreenPlaid",       basePrice=200, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.SleepingBag_RedPlaid",         basePrice=200, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.SleepingBag_BluePlaid_Packed", basePrice=200, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.SleepingBag_Camo_Packed",      basePrice=220, tags={"Tool.Camping.Bedding", "Theme.Winter", "Origin.Military", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.SleepingBag_GreenPlaid_Packed",basePrice=200, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.SleepingBag_Green_Packed",     basePrice=200, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.SleepingBag_RedPlaid_Packed",  basePrice=200, tags={"Tool.Camping.Bedding", "Theme.Winter", "Rarity.Uncommon"}, stockRange={min=1, max=2} },

-- Tier 4: High Quality
{ item="Base.SleepingBag_HighQuality_Brown",        basePrice=350, tags={"Tool.Camping.Bedding", "Theme.Winter", "Quality.Premium", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.SleepingBag_HighQuality_Brown_Packed", basePrice=350, tags={"Tool.Camping.Bedding", "Theme.Winter", "Quality.Premium", "Rarity.Rare"}, stockRange={min=0, max=1} },

-- Tier 5: Spiffo
{ item="Base.SleepingBag_Spiffo",           basePrice=600, tags={"Tool.Camping.Bedding", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=1} },
{ item="Base.SleepingBag_Spiffo_Packed",    basePrice=600, tags={"Tool.Camping.Bedding", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=1} },

-- =============================================================================
-- 3. TENTS (Shelter)
-- =============================================================================

-- Primitive
{ item="Base.HideTent",                 basePrice=25, tags={"Tool.Camping.Shelter", "Winter"}, stockRange={min=1, max=2} },
{ item="Base.HideTent_Packed",          basePrice=25, tags={"Tool.Camping.Shelter", "Winter"}, stockRange={min=1, max=2} },
{ item="Base.ImprovisedTentKit",        basePrice=15, tags={"Tool.Camping.Shelter", "Junk"},   stockRange={min=1, max=5} },
{ item="Base.ImprovisedTentKit_Packed", basePrice=15, tags={"Tool.Camping.Shelter", "Junk"},   stockRange={min=1, max=5} },

-- Manufactured (Modern)
-- Standard Kit
{ item="Base.CampingTentKit2",          basePrice=50, tags={"Tool.Camping.Shelter", "Winter", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.CampingTentKit2_Packed",   basePrice=50, tags={"Tool.Camping.Shelter", "Winter", "Uncommon"}, stockRange={min=1, max=3} },

-- Colored Tents (Higher value as they imply pre-war quality)
{ item="Base.TentBlue",                 basePrice=65, tags={"Tool.Camping.Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentBrown",                basePrice=65, tags={"Tool.Camping.Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentGreen",                basePrice=65, tags={"Tool.Camping.Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentYellow",               basePrice=65, tags={"Tool.Camping.Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
-- Packed versions
{ item="Base.TentBlue_Packed",          basePrice=65, tags={"Tool.Camping.Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentBrown_Packed",         basePrice=65, tags={"Tool.Camping.Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentGreen_Packed",         basePrice=65, tags={"Tool.Camping.Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentYellow_Packed",        basePrice=65, tags={"Tool.Camping.Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },

-- Lighters (High Convenience)
{ item="Base.Lighter",           basePrice=80, tags={"Tool.Camping.Fire", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.LighterBBQ",        basePrice=60, tags={"Tool.Camping.Fire", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.LighterDisposable", basePrice=45, tags={"Tool.Camping.Fire", "Rarity.Common"}, stockRange={min=2, max=5} },
{ item="Base.Lighter_Battery",   basePrice=35, tags={"Tool.Camping.Fire", "Quality.Primitive", "Rarity.Common"}, stockRange={min=0, max=2} },

-- Matches
{ item="Base.Matchbox",          basePrice=25, tags={"Tool.Camping.Fire", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.Matches",           basePrice=10, tags={"Tool.Camping.Fire", "Rarity.Common"}, stockRange={min=3, max=12} },
})

print("[DynamicTrading] Camping Registry Complete \n.")
