require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeSkills then
    DynamicTrading.RegisterArchetypeSkills("Bandit", {
        primarySkill = "Melee",
        secondarySkills = { "Shooting", "Maintenance" },
        skills = {
            Construction = { min = 0, max = 6, mastery = 0 },
            Crafting = { min = 0, max = 6, mastery = 0 },
            Mining = { min = 0, max = 5, mastery = 0 },
            Plants = { min = 0, max = 5, mastery = 0 },
            Medical = { min = 1, max = 8, mastery = 0 },
            Cooking = { min = 0, max = 6, mastery = 0 },
            Intellectual = { min = 0, max = 5, mastery = 0 },
            Social = { min = 2, max = 10, mastery = 0 },
            Animals = { min = 0, max = 5, mastery = 0 },
            Shooting = { min = 2, max = 12, mastery = 10 },
            Melee = { min = 6, max = 16, mastery = 20 },
            Maintenance = { min = 3, max = 12, mastery = 10 },
        }
    })
end
