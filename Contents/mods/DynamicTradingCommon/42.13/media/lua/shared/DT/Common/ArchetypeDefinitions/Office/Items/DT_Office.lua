require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Office", {
    name = "White Collar",
    allocations = {
        { tags={"Theme.Business"}, count = 8 },
        { tags={"Resource.Material.Paper"}, count = 6 },
        { tags={"Electronics.General"}, count = 4 },
        { tags={"Theme.Business"}, count = 2 }
    },
    wants = {
        ["Food.NonPerishable.Drink"] = 2.0,
        ["Food.NonPerishable.Sweets"] = 1.3,
        ["Medical.Tobacco"] = 1.2
    },
    forbid = { "Theme.Farming", "Quality.Heavy", "Quality.Dirty" }
})

end
