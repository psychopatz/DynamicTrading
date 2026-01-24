require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
-- =============================================================================
-- 1. ESSENTIAL GROOMING TOOLS
-- =============================================================================
-- Scissors are vital for Tailoring (Leather/Denim strips).
{ item="Base.Scissors", basePrice=15, tags={"Tool", "Clothing"}, stockRange={min=2, max=8} },
-- Razors are purely aesthetic/roleplay.
{ item="Base.Razor", basePrice=4, tags={"Tool", "Hygiene"}, stockRange={min=2, max=10} },
-- Mirrors allow self-customization.
{ item="Base.Mirror", basePrice=8, tags={"Misc", "Hygiene"}, stockRange={min=1, max=5} },


-- =============================================================================
-- 2. COSMETICS (Luxury / Vanity)
-- =============================================================================
-- These items are useless for survival but valuable for roleplay/happiness.
{ item="Base.Lipstick",         basePrice=6,  tags={"Cosmetic", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.MakeupEyeshadow",  basePrice=6,  tags={"Cosmetic", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.MakeupFoundation", basePrice=6,  tags={"Cosmetic", "Luxury"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 3. HAIR CARE & DYES
-- =============================================================================
{ item="Base.Hairgel",          basePrice=5,  tags={"Cosmetic", "Luxury"}, stockRange={min=2, max=8} },
{ item="Base.Hairspray2",       basePrice=8,  tags={"Cosmetic", "Fuel"},   stockRange={min=2, max=8} }, -- Tagged 'Fuel' as it is often flammable/accelerant in mods

-- Dyes are tiered by their internal rarity definition
{ item="Base.HairDyeCommon",    basePrice=10, tags={"Cosmetic", "Common"},   stockRange={min=2, max=6} }, -- Brown/Black/Blonde
{ item="Base.HairDyeUncommon",  basePrice=18, tags={"Cosmetic", "Uncommon"}, stockRange={min=1, max=4} }, -- Red/White/Grey
{ item="Base.HairDyeRare",      basePrice=30, tags={"Cosmetic", "Rare", "Luxury"}, stockRange={min=0, max=2} }, -- Pink/Blue/Green (The "E-Girl" tax)
})