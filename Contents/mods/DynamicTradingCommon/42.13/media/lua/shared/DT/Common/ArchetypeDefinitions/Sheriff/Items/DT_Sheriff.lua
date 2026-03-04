require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Sheriff", {
    name = "Constable",
    allocations = {
        { tags = {"Police"}, count = 5 },
        { tags = {"Gun"}, count = 4 },
        { tags = {"Ammo"}, count = 4 },
        { tags = {"Weapon"}, count = 3 }
    },
    wants = {
        ["Communication"] = 1.5,
        ["Donut"] = 2.0,
        ["Sweets"] = 1.5,
        ["Coffee"] = 1.5
    },
    forbid = { "Illegal", "Heavy" }
})

end
