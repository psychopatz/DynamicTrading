require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
    -- BASICS
    { item="Base.Tshirt_White",     basePrice=10,  tags={"Clothing"}, stockRange={min=2, max=8} },
    { item="Base.Jeans",            basePrice=20,  tags={"Clothing"}, stockRange={min=2, max=6} },
    { item="Base.Sneakers",         basePrice=25,  tags={"Clothing"}, stockRange={min=1, max=4} },
    { item="Base.Socks_Ankle",      basePrice=5,   tags={"Clothing"}, stockRange={min=2, max=10} },

    -- BAGS (High Value)
    { item="Base.Bag_Schoolbag",    basePrice=40,  tags={"Clothing", "Container"}, stockRange={min=1, max=2} },
    { item="Base.Bag_DuffelBag",    basePrice=80,  tags={"Clothing", "Container", "Uncommon"}, stockRange={min=1, max=1} },
    { 
        item="Base.Bag_BigHikingBag", 
        basePrice=150, 
        tags={"Clothing", "Container", "Rare"}, 
        stockRange={min=1, max=1},
        chance=3
    },

    -- WINTER GEAR (Tagged for Winter Events)
    { item="Base.Jacket_Padded",    basePrice=60,  tags={"Clothing", "Winter"}, stockRange={min=1, max=2} },
    { item="Base.Hat_Wooly",        basePrice=15,  tags={"Clothing", "Winter"}, stockRange={min=1, max=4} },
    { item="Base.Gloves_Leather",   basePrice=25,  tags={"Clothing", "Winter", "Protection"}, stockRange={min=1, max=2} }
})