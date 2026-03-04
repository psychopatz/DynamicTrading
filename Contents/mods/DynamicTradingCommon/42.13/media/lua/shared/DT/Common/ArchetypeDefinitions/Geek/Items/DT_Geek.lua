require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Geek", {
    name = "Collector",
    allocations = {
        { tags={"Junk.Toy"}, count = 6 },
        { tags={"Luxury.Fun"}, count = 5 },
        { tags={"Electronics"}, count = 5 },
        { tags={"Literature.Book"}, count = 4 }
    },
    wants = {
        ["Electronics.Battery"] = 1.5,
        ["Sweets"] = 1.4,
        ["Drink"] = 1.2
    },
    forbid = { "Food.Drink.Alcohol", "Farm", "Tool" }
})

end
