require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Teacher", {
    name = "Teacher",
    allocations = {
        { tags={"Container.Misc"}, count = 8 },
        { tags={"Junk.Paper"}, count = 6 },
        { tags={"Theme.Office"}, count = 5 },
        { tags={"Literature.Book"}, count = 3 }
    },
    wants = {
        ["Junk.Toy"] = 1.5,
        ["Sweets"] = 1.2,
        ["Medical"] = 1.2
    },
    forbid = { "Food.Drink.Alcohol", "Tobacco", "Weapon" }
})

end