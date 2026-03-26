require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetypeSkills then
    DynamicTrading.RegisterArchetypeSkills("Hiker", {
        primarySkill = "Animals",
        secondarySkills = { "Plants", "Melee" },
        skills = {
            Construction = { min = 0, max = 8, mastery = 0 },
            Crafting = { min = 0, max = 8, mastery = 0 },
            Mining = { min = 0, max = 8, mastery = 0 },
            Plants = { min = 3, max = 12, mastery = 0 },
            Medical = { min = 0, max = 8, mastery = 0 },
            Cooking = { min = 0, max = 8, mastery = 0 },
            Intellectual = { min = 0, max = 8, mastery = 0 },
            Social = { min = 0, max = 8, mastery = 0 },
            Animals = { min = 8, max = 18, mastery = 20 },
            Shooting = { min = 0, max = 8, mastery = 0 },
            Melee = { min = 3, max = 12, mastery = 0 },
            Maintenance = { min = 0, max = 8, mastery = 0 }
        }
    })
end
