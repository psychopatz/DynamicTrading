require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Tribal", {
    module = "DynamicTradingCommon",
    name = "Primitive Survivor",
    allocations = {
        { tags={"Theme.Primitive"}, count = 10 },
        { tags={"Medical.Healthcare.Botanical"}, count = 8 },
        { tags={"Food.Perishable.Meat"}, count = 6 },
        { tags={"Resource.Material"}, count = 12 },
        { tags={"Weapon.Melee.Axe"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.StoneAxeLarge", count = 2 }
    },
    expertTags = { "Theme.Primitive", "Medical.Healthcare.Botanical", "Food.Perishable.Meat", "Resource.Material", "Weapon.Melee.Axe" },
    wants = {
        ["Building.Survival.Trap"] = 1.35,
        ["Food.NonPerishable"] = 1.3,
        ["Container.Utility"] = 1.25,
        ["Weapon.Melee.Blade"] = 1.2,
        ["Clothing"] = 1.15
    },
    forbid = { "Electronics", "Building.Vehicle", "Quality.Luxury", "Literature.Book", "Weapon.Ranged.Firearm" }
})

end
