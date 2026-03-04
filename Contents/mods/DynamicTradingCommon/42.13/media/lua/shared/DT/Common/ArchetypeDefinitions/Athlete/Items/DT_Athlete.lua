require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Athlete", {
    name = "Coach",
    allocations = {
        { tags={"Theme.Sports"}, count = 8 },
        { tags={"Clothing.General"}, count = 4 },
        { tags={"Food.General.HighProtein"}, count = 4 },
        { tags={"Container.Fluid"}, count = 4 }
    },
    wants = {
        ["Medical.General"] = 1.3,
        ["Food.General.HighCalorie"] = 1.2,
        ["Medical.General.Vitamin"] = 1.4
    },
    forbid = { "Food.Drink.Alcohol", "Medical.Tobacco", "Quality.Waste" }
})

end
