require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Gunrunner", {
    name = "Gunrunner",
    allocations = {
        ["Gun"] = 5,
        ["Ammo"] = 8,
        ["WeaponPart"] = 4,
        ["Gunrunner"] = 3
    },
    wants = {
        ["Armor"] = 1.5,
        ["Medical"] = 1.3,
        ["Canned"] = 1.1
    },
    forbid = { "Tool", "Farming", "Literature" }
})

end
