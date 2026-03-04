require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Gunrunner", {
    name = "Gunrunner",
    allocations = {
        { tags={"Weapon.Ranged.Firearm"}, count = 5 },
        { tags={"Weapon.Ranged.Ammo"}, count = 8 },
        { tags={"Weapon.Part"}, count = 4 },
        { tags={"Quality.Illegal"}, count = 3 }
    },
    wants = {
        ["Clothing.Protection"] = 1.5,
        ["Medical.General"] = 1.3,
        ["Food.NonPerishable.Canned"] = 1.1
    },
    forbid = { "Tool.General", "Theme.Farming", "Literature.Media" }
})

end
