require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Gunrunner", {
    name = "Gunrunner",
    allocations = {
        { tags = {"Gun"}, count = 5 },
        { tags = {"Ammo"}, count = 8 },
        { tags = {"WeaponPart"}, count = 4 },
        { tags = {"Gunrunner"}, count = 3 }
    },
    wants = {
        ["Armor"] = 1.5,
        ["Medical"] = 1.3,
        ["Canned"] = 1.1
    },
    forbid = { "Tool", "Farming", "Literature" }
})

end
