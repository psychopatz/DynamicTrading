require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
    -- CANNED GOODS (General Store staples)
    { item="Base.TinnedBeans",  basePrice=8,   tags={"Food", "Canned"},     stockRange={min=2, max=10} },
    { item="Base.TinnedSoup",   basePrice=8,   tags={"Food", "Canned"},     stockRange={min=2, max=10} },
    { item="Base.DogFood",      basePrice=4,   tags={"Food", "Canned"},     stockRange={min=1, max=5} },

    -- FRESH PRODUCE (For Farmer & Harvest Event)
    { item="Farming.Cabbage",   basePrice=5,   tags={"Food", "Vegetable", "Fresh"}, stockRange={min=5, max=15} },
    { item="Farming.Potato",    basePrice=5,   tags={"Food", "Vegetable", "Fresh"}, stockRange={min=5, max=15} },
    { item="Farming.Tomato",    basePrice=6,   tags={"Food", "Vegetable", "Fresh"}, stockRange={min=5, max=10} },
    
    -- DRINKS
    { item="Base.WaterBottleFull", basePrice=10, tags={"Drink", "Water"},   stockRange={min=1, max=5} },
    { item="Base.Pop",             basePrice=5,  tags={"Drink", "Junk"},    stockRange={min=1, max=5} },

    -- RARE FOODS
    { item="Base.Chocolate",       basePrice=12, tags={"Food", "Luxury"},   stockRange={min=1, max=3} },
    { item="Base.BeefJerky",       basePrice=15, tags={"Food", "Meat"},     stockRange={min=1, max=3} }
})