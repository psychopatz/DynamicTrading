require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Athlete", {
    name = "Coach",
    allocations = {
        { tags={"Quality.Sport"}, count = 8 },
        { tags={"Clothing"}, count = 4 },
        { tags={"Food.Perishable.Protein"}, count = 4 },
        { tags={"Container.Fluid"}, count = 4 }
    },
    wants = {
        ["Medical"] = 1.3,
        ["HighCalorie"] = 1.2,
        ["Vitamin"] = 1.4
    },
    forbid = { "Food.Drink.Alcohol", "Tobacco", "Quality.Junk" }
})

end
