require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Painter", {
    name = "Renovator",
    allocations = {
        { tags={"Resource.Material.Textile"}, count = 8 },
        { tags={"Misc.Decor"}, count = 5 },
        { tags={"Resource.Material.General"}, count = 4 },
        { tags={"Tool.General"}, count = 3 }
    },
    wants = {
        ["Container.Fluid"] = 1.2,
        ["Clothing.General"] = 1.1,
        ["Food.General"] = 1.1
    },
    forbid = { "Weapon.General", "Quality.Rotten", "Quality.Dirty" }
})

end
