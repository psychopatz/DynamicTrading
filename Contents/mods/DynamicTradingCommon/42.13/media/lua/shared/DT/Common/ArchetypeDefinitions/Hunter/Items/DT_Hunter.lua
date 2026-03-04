require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Hunter", {
    name = "Trapper",
    allocations = {
        { tags={"Tool.Resource.Trapper"}, count = 5 },
        { tags={"Food.Perishable.Meat"}, count = 5 },
        { tags={"Resource.Material.Textile"}, count = 4 },
        { tags={"Theme.Hunting"}, count = 3 },
        { tags={"Resource.Material.Bio"}, count = 2 }
    },
    expertTags = { "Food.Perishable.Meat", "Tool.Resource.Trapper", "Resource.Material.Textile" },
    wants = {
        ["Food.Spice"] = 1.3,
        ["Tool.Utility.Survival"] = 1.4,
        ["Weapon.Melee.Blade"] = 1.2
    },
    forbid = { "Electronics.General", "Theme.Business", "Misc.General" }
})
end