require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Pawnbroker", "Selling", {
        EN = {
            Generic = {
                "I can use this {item} for the shop. Here's {price}.",
                "Collectible find! {price} sent for the {item}. What else you got, {player.firstname}?",
                "I'll take the {item}. Might be someone's treasure later.",
            },
            HighValue = {
                "Whoa! That's some serious collectible! {price} for the {item}. You're a pro.",
                "Legendary find! This {item} is worth its weight in gold. {price} incoming."
            },
            HighMarkup = {
                "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
            },
            Trash = {
                "This {item} is basically shop-waste. I'll give you {price}.",
                "Material's a bit dusty... but salvageable. {price} for the {item}."
            }
        }
    })
end
