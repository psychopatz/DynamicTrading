require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Herbalist", {
    module = "DynamicTradingCommon",
    name = "Herbalist",
    allocations = {
        { tags={"Medical.Healthcare.Botanical"}, count = 10 },
        { tags={"Food.Perishable.Vegetable"}, count = 6 },
        { tags={"Building.Garden"}, count = 5 },
        { tags={"Resource.Material"}, count = 8 },
        { tags={"Tool.Farming"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.MortarPestle", count = 1 }
    },
    expertTags = { "Medical.Healthcare.Botanical", "Food.Perishable.Vegetable", "Building.Garden", "Resource.Material", "Tool.Farming" },
    wants = {
        ["Container.Liquid"] = 1.35,
        ["Literature.SkillBook"] = 1.3,
        ["Literature.SkillBook"] = 1.25,
        ["Medical.Consumable"] = 1.2,
        ["Container.Liquid"] = 1.15
    },
    forbid = { "Electronics", "Weapon.Ranged.Firearm", "Building.Vehicle", "Quality.Waste", "Theme.Industrial" }
})

end