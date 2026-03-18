require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Scavenger", {
    name = "Scavenger",
    allocations = {
        { tags={"Quality.Waste"}, count = 10 },
        { tags={"Quality.Waste"}, count = 5 },
        { tags={"Tool.General"}, count = 5 },
        { tags={"Resource.Material.General"}, count = 3 }
    },
    wants = {
        ["Container.Bag.Backpack"] = 1.5,
        ["Container.Liquid"] = 1.2,
        ["Food"] = 1.2
    },
    forbid = {}
})

end
