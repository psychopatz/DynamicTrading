require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Sheriff", {
    name = "Constable",
    allocations = {
        { tags={"Theme.Police"}, count = 5 },
        { tags={"Weapon.Ranged.Firearm"}, count = 4 },
        { tags={"Weapon.Ranged.Ammo"}, count = 4 },
        { tags={"Weapon.General"}, count = 3 }
    },
    wants = {
        ["Electronics.Gadget.Radio"] = 1.5,
        ["Food.NonPerishable.Sweets"] = 2.0,
        ["Food.NonPerishable.Sweets"] = 1.5,
        ["Food.NonPerishable.Drink"] = 1.5
    },
    forbid = { "Quality.Illegal", "Quality.Heavy" }
})

end
