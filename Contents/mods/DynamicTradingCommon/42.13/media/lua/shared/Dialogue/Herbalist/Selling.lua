DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Herbalist"] = DynamicTrading.Dialogue.Archetypes["Herbalist"] or {}

DynamicTrading.Dialogue.Archetypes["Herbalist"].Selling = {
    Generic = {
        "I can use this {item} in a remedy. Here's {price}.",
        "Natural find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might need it for a tonic later.",
    },
    HighValue = {
        "Whoa! That's some serious botanical! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in ginseng. {price} incoming."
    },
    Trash = {
        "This {item} is basically weed-waste. I'll give you {price}.",
        "Material's a bit withered... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
