require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Hiker", {
    name = "Drifter",
    allocations = {
        { tags={"Theme.Survival"}, count = 8 },
        { tags={"Container"}, count = 5 },
        { tags={"Container.Bag.Backpack"}, count = 4 },
        { tags={"Theme.Survival"}, count = 3 }
    },
    wants = {
        ["Food.NonPerishable.Canned"] = 1.3,
        ["Food.NonPerishable.Sweets"] = 1.2,
        ["Clothing"] = 1.2
    },
    forbid = { "Clothing.Armor.Heavy", "Electronics.PowerGenerator", "Resource.Material.Hardware" }
})

end
