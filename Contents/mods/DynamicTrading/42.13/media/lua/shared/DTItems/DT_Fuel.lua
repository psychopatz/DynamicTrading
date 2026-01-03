require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
    -- ======================================================
    -- HIGH VALUE (Gold & Gems)
    -- ======================================================
    -- These are rare but provide a massive cash injection.
    { item="Base.Ring_Diamond",     basePrice=250, tags={"Luxury", "Legendary"}, stockRange={min=0, max=1}, chance=1 },
    { item="Base.Ring_Gold",        basePrice=80,  tags={"Luxury", "Rare"},      stockRange={min=0, max=1}, chance=5 },
    { item="Base.Necklace_Gold",    basePrice=120, tags={"Luxury", "Rare"},      stockRange={min=0, max=1}, chance=4 },
    { item="Base.Earring_Gold",     basePrice=60,  tags={"Luxury", "Rare"},      stockRange={min=0, max=2}, chance=5 },

    -- ======================================================
    -- SILVER & COMMON JEWELRY
    -- ======================================================
    -- Very common on corpses. Good steady income.
    { item="Base.Ring_Silver",      basePrice=30,  tags={"Luxury"}, stockRange={min=0, max=2} },
    { item="Base.Necklace_Silver",  basePrice=45,  tags={"Luxury"}, stockRange={min=0, max=2} },
    { item="Base.Earring_Silver",   basePrice=25,  tags={"Luxury"}, stockRange={min=0, max=3} },
    
    -- ======================================================
    -- WEDDING RINGS
    -- ======================================================
    -- Extremely common. The bread and butter of corpse looting.
    { item="Base.WeddingRing_Man",   basePrice=40, tags={"Luxury"}, stockRange={min=0, max=1} },
    { item="Base.WeddingRing_Woman", basePrice=40, tags={"Luxury"}, stockRange={min=0, max=1} },

    -- ======================================================
    -- COSMETICS & ACCESSORIES
    -- ======================================================
    -- Often found in bathroom cabinets/handbags.
    { item="Base.Perfume",          basePrice=25,  tags={"Luxury", "Glass"}, stockRange={min=1, max=3} },
    { item="Base.Cologne",          basePrice=25,  tags={"Luxury", "Glass"}, stockRange={min=1, max=3} },
    { item="Base.Locket",           basePrice=35,  tags={"Luxury"},          stockRange={min=0, max=1} },
    
    -- Makeup (Low value, but sellable)
    { item="Base.MakeupEyeshadow",  basePrice=10,  tags={"Luxury"}, stockRange={min=1, max=5} },
    { item="Base.Lipstick",         basePrice=10,  tags={"Luxury"}, stockRange={min=1, max=5} },
    { item="Base.MakeupFoundation", basePrice=10,  tags={"Luxury"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Luxury Items Registered.")