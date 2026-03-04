require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Chef", {
    name = "Chef",
    allocations = {
        { tags = {"Cooking"}, count = 6 },
        { tags = {"Food"}, count = 6 },
        { tags = {"Fresh"}, count = 4 },
        { tags = {"Spice"}, count = 3 },
        { tags = {"Ingredient"}, count = 3 }
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
