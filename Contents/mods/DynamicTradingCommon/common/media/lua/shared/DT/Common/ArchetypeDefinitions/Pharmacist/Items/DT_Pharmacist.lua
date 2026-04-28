require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Pharmacist", {
    module = "DynamicTradingCommon",
    name = "Pharmacist",
    allocations = {
        { tags={"Medical.General.Drug"}, count = 5 },
        { tags={"Medical.General.Pills"}, count = 10 },
        { tags={"Medical.General.Vitamin"}, count = 8 },
        { tags={"Medical.Consumable"}, count = 10 },
        { tags={"Resource.Material.Packaging"}, count = 5 },
        { module = "DynamicTradingCommon",  item = "Base.PillsVitamins", count = 2 }
    },
    expertTags = { "Medical.General.Pills", "Medical.General.Drug", "Medical.General.Vitamin", "Medical.Consumable", "Tool.Medical" },
    wants = {
        ["Container.Liquid"] = 1.3,
        ["Resource.Material.Paper"] = 1.25,
        ["Misc.General"] = 1.2,
        ["Literature.SkillBook"] = 1.15,
        ["Quality.Luxury"] = 1.1
    },
    forbid = { "Weapon.Ranged.Firearm", "Weapon.Ranged.Ammo", "Resource.Material.Wood", "Building.Survival", "Theme.Combat" }
})

end
