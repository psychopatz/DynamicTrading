require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeSkills then
    DynamicTrading.RegisterArchetypeSkills("Brewer", {
        primarySkill = "Cooking",
        secondarySkills = { "Intellectual", "Social" },
        skills = {
            Construction = { min = 0, max = 8, mastery = 0 },
            Crafting = { min = 0, max = 8, mastery = 0 },
            Mining = { min = 0, max = 8, mastery = 0 },
            Plants = { min = 0, max = 8, mastery = 0 },
            Medical = { min = 0, max = 8, mastery = 0 },
            Cooking = { min = 8, max = 18, mastery = 20 },
            Intellectual = { min = 3, max = 12, mastery = 0 },
            Social = { min = 3, max = 12, mastery = 0 },
            Animals = { min = 0, max = 8, mastery = 0 },
            Shooting = { min = 0, max = 8, mastery = 0 },
            Melee = { min = 0, max = 8, mastery = 0 },
            Maintenance = { min = 0, max = 8, mastery = 0 }
        }
    })
end
