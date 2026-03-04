require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Bartender", {
    name = "Barkeep",
    allocations = {
        { tags = {"Alcohol"}, count = 8 },
        { tags = {"Drink"}, count = 6 },
        { tags = {"Glass"}, count = 4 },
        { tags = {"Fun"}, count = 2 }
    },
    wants = {
        ["Fruit"] = 1.3,
        ["Clean"] = 1.2,
        ["Junk"] = 1.1
    },
    forbid = { "Weapon", "Ammo" }
})

end
