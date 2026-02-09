require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Butcher", {
    name = "Butcher",
    allocations = {
        ["Meat"] = 8,
        ["Butcher"] = 4,
        ["Container"] = 2
    },
    wants = {
        ["Ammo"] = 1.4,
        ["Blade"] = 1.3,
        ["Spice"] = 1.2
    },
    forbid = { "Vegetable", "Fruit", "Literature" }
})

end
