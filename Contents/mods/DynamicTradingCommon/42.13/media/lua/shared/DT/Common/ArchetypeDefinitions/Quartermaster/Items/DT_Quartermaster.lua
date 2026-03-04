require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Quartermaster", {
    name = "Deserter",
    allocations = {
        { tags = {"Military"}, count = 8 },
        { tags = {"Tactical"}, count = 5 },
        { tags = {"Stockpile"}, count = 4 },
        { tags = {"MRE"}, count = 3 },
        { tags = {"Canned"}, count = 3 }
    },
    wants = {
        ["Alcohol"] = 1.5,
        ["Tobacco"] = 1.5,
        ["Luxury"] = 1.2
    },
    forbid = { "Farming", "Decor", "Toy" }
})

end
