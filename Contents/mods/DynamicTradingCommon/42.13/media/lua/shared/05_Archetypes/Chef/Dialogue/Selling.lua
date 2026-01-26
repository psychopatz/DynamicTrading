DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Chef"] = DynamicTrading.Dialogue.Archetypes["Chef"] or {}

DynamicTrading.Dialogue.Archetypes["Chef"].Selling = {
    Generic = {
        "I can use this {item} in a dish. Here's {price}.",
        "Gourmet find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might need it for a recipe later.",
    },
    HighValue = {
        "Whoa! That's some serious ingredient! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in saffron. {price} incoming."
    },
    Trash = {
        "This {item} is basically food waste. I'll give you {price}.",
        "Material's a bit stale... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
