require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
    -- PURE JUNK
    { item="Base.RubberBand",       basePrice=1,   tags={"Junk"}, stockRange={min=5, max=20} },
    { item="Base.Paperclip",        basePrice=1,   tags={"Junk"}, stockRange={min=5, max=20} },
    { item="Base.EmptyBottle",      basePrice=2,   tags={"Junk"}, stockRange={min=3, max=10} },
    { item="Base.SheetPaper",       basePrice=1,   tags={"Junk"}, stockRange={min=10, max=50} },
    
    -- USEFUL JUNK (Materials)
    { item="Base.UnusableWood",     basePrice=2,   tags={"Junk", "Fuel"}, stockRange={min=5, max=15} },
    { item="Base.Garbagebag",       basePrice=3,   tags={"Junk", "Container"}, stockRange={min=3, max=8} },
    
    -- TOYS
    { item="Base.ToyBear",          basePrice=5,   tags={"Junk", "Luxury"}, stockRange={min=1, max=1} },
    { item="Base.Spiffo",           basePrice=50,  tags={"Junk", "Rare", "Luxury"}, stockRange={min=1, max=1}, chance=2 }
})