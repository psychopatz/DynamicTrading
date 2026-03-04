require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. ESSENTIAL GROOMING TOOLS
-- =============================================================================
-- Scissors are vital for Tailoring (Leather/Denim strips).
{ item="Base.Scissors", basePrice=45, tags={"Tool.Household", "Theme.Society", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Razor", basePrice=15, tags={"Luxury.Grooming", "Theme.Society", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Mirror", basePrice=25, tags={"Luxury.Grooming", "Theme.Society", "Rarity.Common"}, stockRange={min=1, max=3} },


-- =============================================================================
-- 2. COSMETICS (Luxury / Vanity)
-- =============================================================================
-- These items are useless for survival but valuable for roleplay/happiness.
{ item="Base.Lipstick",         basePrice=35,  tags={"Luxury.Cosmetic", "Theme.Social", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.MakeupEyeshadow",  basePrice=35,  tags={"Luxury.Cosmetic", "Theme.Social", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.MakeupFoundation", basePrice=35,  tags={"Luxury.Cosmetic", "Theme.Social", "Rarity.Uncommon"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 3. HAIR CARE & DYES
-- =============================================================================
{ item="Base.Hairgel",          basePrice=10, tags={"Luxury.Grooming", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=2, max=8} },
{ item="Base.Hairspray2",       basePrice=15, tags={"Luxury.Grooming", "Resource.Fuel.Aerosol", "Rarity.Common"},   stockRange={min=2, max=8} }, -- Tagged 'Fuel' as it is often flammable/accelerant in mods

-- Dyes are tiered by their internal rarity definition
{ item="Base.HairDyeCommon",    basePrice=45,  tags={"Luxury.Cosmetic", "Theme.Social", "Rarity.Common"},   stockRange={min=1, max=3} },
{ item="Base.HairDyeUncommon",  basePrice=85,  tags={"Luxury.Cosmetic", "Theme.Social", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.HairDyeRare",      basePrice=250, tags={"Luxury.Cosmetic", "Theme.Social", "Quality.Premium", "Rarity.Rare"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Appearance Registry Complete \n.")
