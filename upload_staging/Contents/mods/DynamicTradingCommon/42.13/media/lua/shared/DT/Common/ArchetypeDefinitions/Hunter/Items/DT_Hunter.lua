require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Hunter", {
    name = "Trapper",
    allocations = {
        { tags={"Building.Survival.Trap"}, count = 5 },
        { tags={"Food.Perishable.Meat"}, count = 5 },
        { tags={"Resource.Material.Textile"}, count = 4 },
        { tags={"Theme.Survival"}, count = 3 },
        { tags={"Resource.Material.Leather"}, count = 2 }
    },
    expertTags = { "Food.Perishable.Meat", "Building.Survival.Trap", "Resource.Material.Textile" },
    wants = {
        ["Food.Cooking.Spice"] = 1.3,
        ["Theme.Survival"] = 1.4,
        ["Weapon.Melee.Blade"] = 1.2
    },
    forbid = { "Electronics", "Resource.Material.Paper", "Misc.General" }
})
end