DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Designer"] = DynamicTrading.Dialogue.Archetypes["Designer"] or {}

DynamicTrading.Dialogue.Archetypes["Designer"].Selling = {
    Generic = {
        "I can use this {item} for a design. Here's {price}.",
        "Stylish find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might be someone's art later.",
    },
    HighValue = {
        "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in silk. {price} incoming."
    },
    Trash = {
        "This {item} is basically design-waste. I'll give you {price}.",
        "Material's a bit worn... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
