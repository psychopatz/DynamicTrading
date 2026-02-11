require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Burglar", "Selling", {
        EN = {
            Generic = {
                "I can use this {item} for the job. Here's {price}.",
                "Silent find! {price} sent for the {item}. What else you got, {player.firstname}?",
                "I'll take the {item}. Might be someone's treasure later.",
            },
            HighValue = {
                "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
                "Legendary find! This {item} is worth its weight in gold. {price} incoming."
            },
            Trash = {
                "This {item} is basically junk. I'll give you {price}.",
                "Material's a bit rusty... but salvageable. {price} for the {item}."
            },
            HighMarkup = {
                "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
            }
        }
    })
end
