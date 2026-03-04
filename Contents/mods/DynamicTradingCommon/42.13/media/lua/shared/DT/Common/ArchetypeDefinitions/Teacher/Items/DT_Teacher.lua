require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Teacher", {
    name = "Teacher",
    allocations = {
        { tags={"Container.Organizer"}, count = 8 },
        { tags={"Resource.Material.Paper"}, count = 6 },
        { tags={"Theme.Business"}, count = 5 },
        { tags={"Literature.Book"}, count = 3 }
    },
    wants = {
        ["Misc.General"] = 1.5,
        ["Food.NonPerishable.Sweets"] = 1.2,
        ["Medical.General"] = 1.2
    },
    forbid = { "Food.Drink.Alcohol", "Medical.Tobacco", "Weapon.General" }
})

end