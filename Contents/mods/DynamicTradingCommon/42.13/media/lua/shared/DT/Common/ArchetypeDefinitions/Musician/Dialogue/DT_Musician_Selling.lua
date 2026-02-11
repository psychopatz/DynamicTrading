require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Musician", "Selling", {
        EN = {
            Generic = {
                "I can use this {item} for a gig. Here's {price}.",
                "Melodic find! {price} sent for the {item}. What else you got, {player.firstname}?",
                "I'll take the {item}. Might be someone's inspiration later.",
            },
            HighValue = {
                "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
                "Legendary find! This {item} is worth its weight in gold records. {price} incoming."
            },
            HighMarkup = {
                "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
            },
            Trash = {
                "This {item} is basically noise. I'll give you {price}.",
                "Material's a bit out of tune... but salvageable. {price} for the {item}."
            }
        }
    })
end
