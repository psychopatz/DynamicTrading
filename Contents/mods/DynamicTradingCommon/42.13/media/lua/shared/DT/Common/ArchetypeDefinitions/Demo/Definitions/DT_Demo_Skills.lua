require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeSkills then
    DynamicTrading.RegisterArchetypeSkills("Demo", {
        primarySkill = "Mining",
        secondarySkills = { "Construction", "Shooting" },
        skills = {
            Construction = { min = 3, max = 12, mastery = 0 },
            Crafting = { min = 0, max = 8, mastery = 0 },
            Mining = { min = 8, max = 18, mastery = 20 },
            Plants = { min = 0, max = 8, mastery = 0 },
            Medical = { min = 0, max = 8, mastery = 0 },
            Cooking = { min = 0, max = 8, mastery = 0 },
            Intellectual = { min = 0, max = 8, mastery = 0 },
            Social = { min = 0, max = 8, mastery = 0 },
            Animals = { min = 0, max = 8, mastery = 0 },
            Shooting = { min = 3, max = 12, mastery = 0 },
            Melee = { min = 0, max = 8, mastery = 0 },
            Maintenance = { min = 0, max = 8, mastery = 0 }
        }
    })
end
