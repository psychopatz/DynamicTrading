require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Doctor", {
    module = "DynamicTradingCommon",
    name = "Field Medic",
    allocations = {
        { tags={"Medical.General"}, count = 10 },
        { tags={"Medical.Healthcare"}, count = 5 },
        { tags={"Medical.Consumable"}, count = 8 },
        { tags={"Medical.Consumable"}, count = 6 },
        { tags={"Misc.General"}, count = 4 },
        { module = "DynamicTradingCommon",  item = "Base.FirstAidKit", count = 1 }
    },
    expertTags = { "Medical.General", "Medical.Healthcare", "Tool.Medical", "Medical.Healthcare.Botanical", "Theme.Clinical" },
    wants = {
        ["Resource.Material.Paper"] = 1.3,
        ["Misc.General"] = 1.25,
        ["Food.Drink.Alcohol"] = 1.2,
        ["Electronics.LightSource"] = 1.15,
        ["Literature.SkillBook"] = 1.1
    },
    forbid = { "Quality.Waste", "Weapon.Melee.Blunt", "Resource.Material.Hardware", "Building.Garden", "Resource.Parts" }
})

end
