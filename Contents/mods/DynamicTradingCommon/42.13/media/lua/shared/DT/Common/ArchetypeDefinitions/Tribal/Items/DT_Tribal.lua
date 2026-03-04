require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Tribal", {
    name = "Primitive Survivor",
    allocations = {
        { tags={"Origin.Primitive"}, count = 8 },
        { tags={"Weapon.Melee.Spear"}, count = 6 },
        { tags={"Resource.Material.Bone"}, count = 4 },
        { tags={"Resource.Material.Leather"}, count = 3 }
    },
    wants = {
        ["Blade"] = 1.3,
        ["Resource.Textile"] = 1.2,
        ["Medicine"] = 1.4
    },
    forbid = { "Electronics", "Weapon.Ranged.Firearm", "Computer" }
})

end