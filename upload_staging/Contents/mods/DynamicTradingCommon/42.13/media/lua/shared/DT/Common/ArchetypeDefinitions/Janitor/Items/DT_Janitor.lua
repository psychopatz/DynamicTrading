require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Janitor", {
    name = "The Cleaner",
    allocations = {
        { tags={"Container.Liquid"}, count = 8 },
        { tags={"Misc.General"}, count = 6 },
        { tags={"Container.Liquid"}, count = 3 },
        { tags={"Misc.General"}, count = 3 },
        { tags={"Quality.Waste"}, count = 4 }
    },
    wants = {
        ["Clothing.Protective"] = 1.4,
        ["Clothing"] = 1.2,
        ["Container.Liquid"] = 1.2
    },
    forbid = { "Food", "Food.Perishable", "Quality.Luxury" }
})

end
