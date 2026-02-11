require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Butcher", "Selling", {
        EN = {
            Generic = {
                "I can use this {item}. Here's {price} for your trouble.",
                "Fair enough. {price} sent for the {item}. What else you got?",
                "I'll take the {item}. It's not exactly what I'd carve, but it'll do.",
            },
            HighValue = {
                "Solid stuff! {price} is a lot, but this {item} is quality.",
                "Hot damn, {player}. This {item} is a keeper. {price} incoming."
            },
            Trash = {
                "This {item} is basically offal. Take {price} and get it out of my sight.",
                "Scraps... but I can find a use. {price} for the {item}."
            },
            HighMarkup = {
                "You're a tough negotiator, {player.firstname}! {price} for a {item}? Fine, fine."
            }
        }
    })
end
