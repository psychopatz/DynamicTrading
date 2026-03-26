require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeSkills then
    DynamicTrading.RegisterArchetypeSkills("General", {
        primarySkill = "Social",
        secondarySkills = { "Construction", "Crafting" },
        skills = {
            Construction = { min = 1, max = 8, mastery = 0 },
            Crafting = { min = 1, max = 8, mastery = 0 },
            Mining = { min = 0, max = 6, mastery = 0 },
            Plants = { min = 0, max = 6, mastery = 0 },
            Medical = { min = 0, max = 6, mastery = 0 },
            Cooking = { min = 0, max = 6, mastery = 0 },
            Intellectual = { min = 0, max = 6, mastery = 0 },
            Social = { min = 2, max = 10, mastery = 0 },
            Animals = { min = 0, max = 6, mastery = 0 },
            Shooting = { min = 0, max = 6, mastery = 0 },
            Melee = { min = 0, max = 6, mastery = 0 },
            Maintenance = { min = 0, max = 6, mastery = 0 }
        }
    })
end
