require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Survivalist", "Selling", {
        EN = {
            Generic = {
                "I can use this {item} in the field. Here's {price}.",
                "Fair trade. {price} sent for the {item}. Stay safe, {player.firstname}.",
                "I'll take the {item}. Better than nothing out here.",
            },
            HighValue = {
                "Now that's a find! {price} for the {item}. You're good at this.",
                "Impressive. This {item} is worth its weight in gold. {price} incoming."
            },
            HighMarkup = {
                "You're a shark, {player.firstname}. {price} for a {item}? Alright, I'll pay."
            },
            Trash = {
                "This {item} is mostly junk. I'll give you {price}.",
                "Scraps... but everything has a use. {price} for the {item}."
            }
        }
    })
end
