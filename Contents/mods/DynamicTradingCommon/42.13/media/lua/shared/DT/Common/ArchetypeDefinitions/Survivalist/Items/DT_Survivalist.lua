require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Survivalist", {
    name = "Prepper",
    allocations = {
        { tags = {"Canned"}, count = 6 },
        { tags = {"Survival"}, count = 5 },
        { tags = {"Ammo"}, count = 4 },
        { tags = {"Battery"}, count = 2 }
    },
    wants = {
        ["Weapon"] = 1.3,
        ["Fuel"] = 1.5,
        ["Generator"] = 1.4
    },
    forbid = { "Fresh", "Luxury", "Toy" }
})

end
