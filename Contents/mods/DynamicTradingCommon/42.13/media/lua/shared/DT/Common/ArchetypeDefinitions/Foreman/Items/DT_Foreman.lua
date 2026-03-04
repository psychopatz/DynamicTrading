require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Foreman", {
    name = "Site Foreman",
    allocations = {
        { tags = {"Material"}, count = 8 },
        { tags = {"Build"}, count = 6 },
        { tags = {"Wood"}, count = 4 },
        { tags = {"Heavy"}, count = 2 },
        { item = "Base.Axe", count = 1 },
        { item = "Base.Woodglue", count = 2 }
    },
    wants = {
        ["Tool"] = 1.4,
        ["Alcohol"] = 1.2,
        ["HighCalorie"] = 1.2
    },
    forbid = { "Literature", "Jewelry" }
})

end
