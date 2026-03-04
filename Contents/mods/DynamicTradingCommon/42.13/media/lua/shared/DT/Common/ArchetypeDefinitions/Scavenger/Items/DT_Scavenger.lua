require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Scavenger", {
    name = "Scavenger",
    allocations = {
        { tags={"Quality.Junk"}, count = 10 },
        { tags={"Junk.Trash"}, count = 5 },
        { tags={"Tool.Crafting.Scavenger"}, count = 5 },
        { tags={"Resource.Material"}, count = 3 }
    },
    wants = {
        ["Container.Backpack"] = 1.5,
        ["Container.Fluid"] = 1.2,
        ["Food"] = 1.2
    },
    forbid = {}
})

end
