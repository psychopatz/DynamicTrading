require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Athlete", {
    name = "Coach",
    allocations = {
        { tags={"Clothing.Protective"}, count = 8 },
        { tags={"Clothing"}, count = 4 },
        { tags={"Food.HighNutrition"}, count = 4 },
        { tags={"Container.Liquid"}, count = 4 }
    },
    wants = {
        ["Medical.General"] = 1.3,
        ["Food.HighNutrition"] = 1.2,
        ["Medical.General.Vitamin"] = 1.4
    },
    forbid = { "Food.Drink.Alcohol", "Medical.General.Drug", "Quality.Waste" }
})

end
