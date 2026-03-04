require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Pyro", {
    name = "Firebug",
    allocations = {
        { tags = {"Fuel"}, count = 8 },
        { tags = {"Fire"}, count = 6 },
        { tags = {"Burnable"}, count = 4 },
        { tags = {"Explosive"}, count = 2 }
    },
    wants = {
        ["Alcohol"] = 1.3,
        ["Textile"] = 1.2,
        ["Glass"] = 1.2
    },
    forbid = { "Water", "FireExtinguisher", "Ice" }
})

end
