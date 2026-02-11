require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Sheriff", "Selling", {
        EN = {
            Generic = {
                "We can use this {item} at the station. {price} paid.",
                "Submitting this to evidence. Here's your cut: {price}.",
                "Good work, Citizen {player.surname}. {price} transferred."
            },
            HighValue = {
                "That's some serious datum! {price} for the {item}. You're a pro.",
                "Legendary find! This {item} is worth its weight in evidence. {price} incoming."
            },
            HighMarkup = {
                "That's some serious gear! {price} for the {item}. Authorized.",
                "Extortionate, but necessary for public safety. {price} sent."
            },
            Trash = {
                "This {item} is basically contraband waste. I'll give you {price}.",
                "Material's a bit weathered... but salvageable. {price} for the {item}."
            }
        }
    })
end
