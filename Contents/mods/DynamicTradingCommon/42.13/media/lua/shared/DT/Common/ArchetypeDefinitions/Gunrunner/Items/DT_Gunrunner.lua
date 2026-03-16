require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Gunrunner", {
    name = "Gunrunner",
    allocations = {
        { tags={"Weapon.Ranged.Firearm"}, count = 5 },
        { tags={"Weapon.Ranged.Ammo"}, count = 8 },
        { tags={"Weapon.Part"}, count = 4 },
        { tags={"Rarity.Rare"}, count = 3 }
    },
    wants = {
        ["Clothing.Protective"] = 1.5,
        ["Medical.General"] = 1.3,
        ["Food.NonPerishable.Canned"] = 1.1
    },
    forbid = { "Tool.General", "Building.Garden", "Literature.Media" }
})

end
