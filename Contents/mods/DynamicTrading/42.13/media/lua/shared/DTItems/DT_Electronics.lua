require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
    -- COMPONENTS
    { item="Base.Battery",          basePrice=15,  tags={"Electronics", "Ammo"},  stockRange={min=2, max=10} }, -- "Ammo" for flashlights roughly
    { item="Base.ElectronicsScrap", basePrice=10,  tags={"Electronics", "Material"}, stockRange={min=3, max=10} },
    { item="Base.ElectricWire",     basePrice=8,   tags={"Electronics", "Material"}, stockRange={min=2, max=8} },
    { item="Base.LightBulb",        basePrice=5,   tags={"Electronics"},          stockRange={min=2, max=6} },

    -- DEVICES
    { item="Base.Torch",            basePrice=25,  tags={"Electronics", "Light"}, stockRange={min=1, max=3} },
    { item="Radio.RadioRed",        basePrice=40,  tags={"Electronics", "Comms"}, stockRange={min=1, max=1} },
    { item="Base.DigitalWatch",     basePrice=20,  tags={"Electronics", "Luxury"}, stockRange={min=1, max=5} },
    
    -- GENERATOR (Ultra Rare)
    { 
        item="Base.Generator", 
        basePrice=800, 
        tags={"Electronics", "Heavy", "Rare"}, 
        stockRange={min=1, max=1}, 
        chance=1 -- Extremely rare
    }
})