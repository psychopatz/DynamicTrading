require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
    -- WOODWORK
    { item="Base.Plank",            basePrice=5,   tags={"Material", "Build"}, stockRange={min=5, max=20} },
    { item="Base.NailsBox",         basePrice=15,  tags={"Material", "Build"}, stockRange={min=2, max=5} },
    
    -- METALWORK
    { item="Base.WeldingRods",      basePrice=30,  tags={"Material", "Metal"}, stockRange={min=1, max=3} },
    { item="Base.MetalSheet",       basePrice=20,  tags={"Material", "Metal"}, stockRange={min=1, max=4} },
    { item="Base.ScrapMetal",       basePrice=8,   tags={"Material", "Metal"}, stockRange={min=3, max=10} },

    -- FIXERS (High Value)
    { 
        item="Base.DuctTape", 
        basePrice=25, 
        tags={"Material", "Fix", "Uncommon"}, 
        stockRange={min=1, max=4} 
    },
    { 
        item="Base.WoodGlue", 
        basePrice=20, 
        tags={"Material", "Fix", "Uncommon"}, 
        stockRange={min=1, max=3} 
    },
    { 
        item="Base.Glue", 
        basePrice=15, 
        tags={"Material", "Fix"}, 
        stockRange={min=1, max=4} 
    }
})