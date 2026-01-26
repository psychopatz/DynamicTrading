require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
-- =============================================================================
-- 1. SURVIVAL GADGETS & FIRE
-- =============================================================================
-- Magnesium Firestarter is the holy grail of fire starting (durable).
{ item="Base.MagnesiumFirestarter", basePrice=40, tags={"Camping", "Tool", "Survival", "Rare"}, stockRange={min=1, max=3} },
{ item="Base.MagnesiumShavings", basePrice=2, tags={"Camping", "Fuel"}, stockRange={min=5, max=10} },
{ item="Base.DryFirestarterBlock", basePrice=5, tags={"Camping", "Fuel"}, stockRange={min=2, max=10} },
 
-- Notched plank is craftable trash, but usable.
{ item="Base.PercedWood",              basePrice=2,  tags={"Camping", "Tool", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.TwigsBundle",             basePrice=1,  tags={"Camping", "Fuel", "Junk"}, stockRange={min=5, max=15} },

-- Survival Utilities
{ item="Base.CompassDirectional",      basePrice=15, tags={"Camping", "Tool", "Survival"}, stockRange={min=1, max=4} },
{ item="Base.WaterPurificationTablets",basePrice=25, tags={"Camping", "Medical", "Survival"}, stockRange={min=2, max=8} }, -- High value life-saver
{ item="Base.InsectRepellent",         basePrice=12, tags={"Camping", "Medical", "Survival"}, stockRange={min=2, max=8} },

-- Junk
{ item="Base.Spork",                   basePrice=0.1,tags={"Camping", "Junk"}, stockRange={min=1, max=1} },

-- =============================================================================
-- 2. SLEEPING BAGS (Fatigue Management)
-- =============================================================================
-- Prices scale with Quality (Fatigue reduction speed)

-- Tier 1: Hide / Primitive (Craftable)
{ item="Base.SleepingBag_Hide",             basePrice=15, tags={"Camping", "Bedding", "Winter"}, stockRange={min=1, max=3} },
{ item="Base.SleepingBag_Hide_Packed",      basePrice=15, tags={"Camping", "Bedding", "Winter"}, stockRange={min=1, max=3} },

-- Tier 2: Cheap (Low quality sleep)
{ item="Base.SleepingBag_Cheap_Blue",       basePrice=20, tags={"Camping", "Bedding", "Winter", "Common"}, stockRange={min=1, max=5} },
{ item="Base.SleepingBag_Cheap_Green",      basePrice=20, tags={"Camping", "Bedding", "Winter", "Common"}, stockRange={min=1, max=5} },
{ item="Base.SleepingBag_Cheap_Green2",     basePrice=20, tags={"Camping", "Bedding", "Winter", "Common"}, stockRange={min=1, max=5} },
-- Packed versions
{ item="Base.SleepingBag_Cheap_Blue_Packed",  basePrice=20, tags={"Camping", "Bedding", "Winter", "Common"}, stockRange={min=1, max=5} },
{ item="Base.SleepingBag_Cheap_Green_Packed", basePrice=20, tags={"Camping", "Bedding", "Winter", "Common"}, stockRange={min=1, max=5} },
{ item="Base.SleepingBag_Cheap_Green2_Packed",basePrice=20, tags={"Camping", "Bedding", "Winter", "Common"}, stockRange={min=1, max=5} },

-- Tier 3: Standard (Good sleep)
{ item="Base.SleepingBag_BluePlaid",        basePrice=35, tags={"Camping", "Bedding", "Winter", "Uncommon"}, stockRange={min=1, max=4} },
{ item="Base.SleepingBag_Camo",             basePrice=35, tags={"Camping", "Bedding", "Winter", "Uncommon"}, stockRange={min=1, max=4} },
{ item="Base.SleepingBag_Green",            basePrice=35, tags={"Camping", "Bedding", "Winter", "Uncommon"}, stockRange={min=1, max=4} },
{ item="Base.SleepingBag_GreenPlaid",       basePrice=35, tags={"Camping", "Bedding", "Winter", "Uncommon"}, stockRange={min=1, max=4} },
{ item="Base.SleepingBag_RedPlaid",         basePrice=35, tags={"Camping", "Bedding", "Winter", "Uncommon"}, stockRange={min=1, max=4} },
-- Packed versions
{ item="Base.SleepingBag_BluePlaid_Packed", basePrice=35, tags={"Camping", "Bedding", "Winter", "Uncommon"}, stockRange={min=1, max=4} },
{ item="Base.SleepingBag_Camo_Packed",      basePrice=35, tags={"Camping", "Bedding", "Winter", "Uncommon"}, stockRange={min=1, max=4} },
{ item="Base.SleepingBag_GreenPlaid_Packed",basePrice=35, tags={"Camping", "Bedding", "Winter", "Uncommon"}, stockRange={min=1, max=4} },
{ item="Base.SleepingBag_Green_Packed",     basePrice=35, tags={"Camping", "Bedding", "Winter", "Uncommon"}, stockRange={min=1, max=4} },
{ item="Base.SleepingBag_RedPlaid_Packed",  basePrice=35, tags={"Camping", "Bedding", "Winter", "Uncommon"}, stockRange={min=1, max=4} },

-- Tier 4: High Quality (Best sleep)
{ item="Base.SleepingBag_HighQuality_Brown",        basePrice=60, tags={"Camping", "Bedding", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.SleepingBag_HighQuality_Brown_Packed", basePrice=60, tags={"Camping", "Bedding", "Winter", "Rare"}, stockRange={min=0, max=2} },

-- Tier 5: Spiffo (Collector's Item)
{ item="Base.SleepingBag_Spiffo",           basePrice=100, tags={"Camping", "Bedding", "Luxury", "Rare"}, stockRange={min=0, max=1} },
{ item="Base.SleepingBag_Spiffo_Packed",    basePrice=100, tags={"Camping", "Bedding", "Luxury", "Rare"}, stockRange={min=0, max=1} },

-- =============================================================================
-- 3. TENTS (Shelter)
-- =============================================================================

-- Primitive
{ item="Base.HideTent",                 basePrice=25, tags={"Camping", "Shelter", "Winter"}, stockRange={min=1, max=2} },
{ item="Base.HideTent_Packed",          basePrice=25, tags={"Camping", "Shelter", "Winter"}, stockRange={min=1, max=2} },
{ item="Base.ImprovisedTentKit",        basePrice=15, tags={"Camping", "Shelter", "Junk"},   stockRange={min=1, max=5} },
{ item="Base.ImprovisedTentKit_Packed", basePrice=15, tags={"Camping", "Shelter", "Junk"},   stockRange={min=1, max=5} },

-- Manufactured (Modern)
-- Standard Kit
{ item="Base.CampingTentKit2",          basePrice=50, tags={"Camping", "Shelter", "Winter", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.CampingTentKit2_Packed",   basePrice=50, tags={"Camping", "Shelter", "Winter", "Uncommon"}, stockRange={min=1, max=3} },

-- Colored Tents (Higher value as they imply pre-war quality)
{ item="Base.TentBlue",                 basePrice=65, tags={"Camping", "Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentBrown",                basePrice=65, tags={"Camping", "Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentGreen",                basePrice=65, tags={"Camping", "Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentYellow",               basePrice=65, tags={"Camping", "Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
-- Packed versions
{ item="Base.TentBlue_Packed",          basePrice=65, tags={"Camping", "Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentBrown_Packed",         basePrice=65, tags={"Camping", "Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentGreen_Packed",         basePrice=65, tags={"Camping", "Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.TentYellow_Packed",        basePrice=65, tags={"Camping", "Shelter", "Winter", "Rare"}, stockRange={min=0, max=2} },

-- Lighters (High Convenience)
    { item="Base.Lighter", category="Survival", tags={"Survival", "General"}, basePrice=55, stockRange={min=1, max=3} },
    { item="Base.LighterBBQ", category="Survival", tags={"Survival", "General"}, basePrice=45, stockRange={min=1, max=4} },
    { item="Base.LighterDisposable", category="Survival", tags={"Survival", "General"}, basePrice=40, stockRange={min=2, max=6} },
    { item="Base.Lighter_Battery", category="Survival", tags={"Survival", "Scavenger"}, basePrice=20, stockRange={min=0, max=2} },

    -- Matches (Low Cost / Single Use focus)
    { item="Base.Matchbox", category="Survival", tags={"Survival", "General"}, basePrice=25, stockRange={min=2, max=8} },
    { item="Base.Matches", category="Survival", tags={"Survival", "General"}, basePrice=10, stockRange={min=3, max=12} },

    -- Primitive (Infinite Use Utility)
    { item="Base.PercedWood", category="Survival", tags={"Survival", "Build", "Carpenter"}, basePrice=35, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Camping Registry Complete.")
