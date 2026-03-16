require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Tribal", {
    name = "Primitive Survivor",
    allocations = {
        { tags={"Theme.Primitive"}, count = 8 },
        { tags={"Weapon.Melee.General"}, count = 6 },
        { tags={"Resource.Material.Leather"}, count = 4 },
        { tags={"Resource.Material.Textile"}, count = 3 }
    },
    wants = {
        ["Weapon.Melee.Blade"] = 1.3,
        ["Resource.Material.Textile"] = 1.2,
        ["Medical.General"] = 1.4
    },
    forbid = { "Electronics", "Weapon.Ranged.Firearm", "Electronics" }
})

end
