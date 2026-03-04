require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Painter", {
    name = "Renovator",
    allocations = {
        { tags={"Resource.Material.Dye"}, count = 8 },
        { tags={"Luxury.Decor"}, count = 5 },
        { tags={"Resource.Material"}, count = 4 },
        { tags={"Tool"}, count = 3 }
    },
    wants = {
        ["Container.Fluid"] = 1.2,
        ["Wearable"] = 1.1,
        ["Food"] = 1.1
    },
    forbid = { "Weapon", "Rotten", "Dirty" }
})

end
