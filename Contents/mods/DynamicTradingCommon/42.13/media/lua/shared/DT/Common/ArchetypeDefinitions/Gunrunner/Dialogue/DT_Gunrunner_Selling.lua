require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Gunrunner", "Selling", {
        EN = {
            Generic = {
                "I can scrap this {item} for parts. Here's {price}.",
                "Interesting hardware. {price} sent for the {item}. What else you got, {player}?",
                "I'll take the {item}. Might save a life later."
            },
            HighValue = {
                "Whoa! That's a rare piece of hardware! {price} for the {item}. You're a pro.",
                "Legendary find! This {item} is worth its weight in brass. {price} incoming."
            },
            HighMarkup = {
                "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
            },
            Trash = {
                "This {item} is basically scrap metal. I'll give you {price}.",
                "Barrel's worn... but salvageable. {price} for the {item}."
            }
        }
    })
end
