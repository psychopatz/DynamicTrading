require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Pharmacist", "Selling", {
        EN = {
            Generic = {
                "I can use this {item} for research. Here's {price}.",
                "Medical find! {price} sent for the {item}. What else you got, {player.firstname}?",
                "I'll take the {item}. Might be someone's cure later.",
            },
            HighValue = {
                "Whoa! That's some serious datum! {price} for the {item}. You're a pro.",
                "Legendary find! This {item} is worth its weight in insulin. {price} incoming."
            },
            HighMarkup = {
                "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
            },
            Trash = {
                "This {item} is basically drug-waste. I'll give you {price}.",
                "Material's a bit oxidized... but salvageable. {price} for the {item}."
            }
        }
    })
end
