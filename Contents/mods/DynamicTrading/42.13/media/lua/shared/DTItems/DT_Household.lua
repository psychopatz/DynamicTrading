require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
    -- CLEANING (Valuable for Doctor Archetype)
    { item="Base.Soap",             basePrice=15,  tags={"Household", "Clean"}, stockRange={min=2, max=6} },
    { item="Base.Bleach",           basePrice=20,  tags={"Household", "Clean"}, stockRange={min=1, max=4} },
    { item="Base.DishCloth",        basePrice=3,   tags={"Household", "Clean"}, stockRange={min=2, max=8} },

    -- COOKING
    { item="Base.Pot",              basePrice=15,  tags={"Household", "Cooking"}, stockRange={min=1, max=2} },
    { item="Base.Pan",              basePrice=12,  tags={"Household", "Cooking"}, stockRange={min=1, max=2} },
    { item="Base.BucketEmpty",      basePrice=10,  tags={"Household", "Farm"},    stockRange={min=1, max=3} },

    -- FIRE / LIGHT
    { item="Base.Matches",          basePrice=5,   tags={"Household", "Fire"},    stockRange={min=5, max=15} },
    { item="Base.Lighter",          basePrice=10,  tags={"Household", "Fire"},    stockRange={min=2, max=6} },
    { item="Base.Candle",           basePrice=8,   tags={"Household", "Light"},   stockRange={min=2, max=8} }
})