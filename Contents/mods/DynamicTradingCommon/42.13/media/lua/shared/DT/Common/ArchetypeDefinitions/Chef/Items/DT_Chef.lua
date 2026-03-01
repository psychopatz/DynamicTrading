require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Chef", {
    name = "Chef",
    allocations = {
        ["Cooking"] = 6,
        ["Food"] = 6,
        ["Fresh"] = 4,
        ["Spice"] = 3,
        ["Ingredient"] = 3
    },
    expertTags = { "Food", "Spice" },
    wants = {
        ["Preservation"] = 1.5,
        ["Fuel"] = 1.2,
        ["Water"] = 1.2
    },
    forbid = { "Weapon", "Ammo", "Junk" }
})

end
