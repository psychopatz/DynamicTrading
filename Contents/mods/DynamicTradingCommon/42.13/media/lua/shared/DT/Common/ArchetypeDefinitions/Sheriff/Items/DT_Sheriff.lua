require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Sheriff", {
    name = "Constable",
    allocations = {
        { tags={"Origin.Police"}, count = 5 },
        { tags={"Weapon.Ranged.Firearm"}, count = 4 },
        { tags={"Weapon.Ranged.Ammo"}, count = 4 },
        { tags={"Weapon"}, count = 3 }
    },
    wants = {
        ["Electronics.Communication"] = 1.5,
        ["Donut"] = 2.0,
        ["Sweets"] = 1.5,
        ["Coffee"] = 1.5
    },
    forbid = { "Quality.Illegal", "Quality.Heavy" }
})

end
