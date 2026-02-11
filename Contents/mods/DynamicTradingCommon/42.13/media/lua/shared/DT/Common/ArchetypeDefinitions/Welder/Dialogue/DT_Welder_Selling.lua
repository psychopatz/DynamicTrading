require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Welder", "Selling", {
        EN = {
            Generic = {
                "I can salvage some metal from this {item}. Here's {price}.",
                "Industrial gear! {price} sent for the {item}. What else you got, {player.firstname}?",
                "I'll take the {item}. Might need it for a project later.",
            },
            HighValue = {
                "Whoa! That's some serious hardware! {price} for the {item}. You're a pro.",
                "Legendary find! This {item} is worth its weight in steel. {price} incoming."
            },
            HighMarkup = {
                "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
            },
            Trash = {
                "This {item} is basically scrap metal. I'll give you {price}.",
                "Material's a bit rusty... but salvageable. {price} for the {item}."
            }
        }
    })
end
