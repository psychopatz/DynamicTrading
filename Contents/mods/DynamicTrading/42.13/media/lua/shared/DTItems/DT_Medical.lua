require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
    -- BASICS
    { item="Base.Bandage",          basePrice=5,   tags={"Medical"},         stockRange={min=5, max=15} },
    { item="Base.RippedSheets",     basePrice=2,   tags={"Medical", "Junk"}, stockRange={min=5, max=20} },
    { item="Base.Painkillers",      basePrice=15,  tags={"Medical"},         stockRange={min=2, max=6} },
    { item="Base.BetaBlockers",     basePrice=15,  tags={"Medical"},         stockRange={min=2, max=6} },
    { item="Base.Vitamins",         basePrice=10,  tags={"Medical"},         stockRange={min=2, max=8} },

    -- WOUND CARE
    { item="Base.Disinfectant",     basePrice=25,  tags={"Medical", "Clean"}, stockRange={min=1, max=4} },
    { item="Base.AlcoholWipes",     basePrice=8,   tags={"Medical", "Clean"}, stockRange={min=3, max=10} },
    { item="Base.SutureNeedle",     basePrice=20,  tags={"Medical", "Rare"},  stockRange={min=1, max=2} },

    -- RARE / LIFE SAVING
    { 
        item="Base.Antibiotics", 
        basePrice=120, 
        tags={"Medical", "Rare"}, 
        stockRange={min=1, max=1}, 
        chance=3 -- Hard to find
    },
    { 
        item="Base.FirstAidKit", 
        basePrice=100, 
        tags={"Medical", "Rare", "Container"}, 
        stockRange={min=1, max=1},
        chance=5
    }
})