DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Angler"] = DynamicTrading.Dialogue.Archetypes["Angler"] or {}

DynamicTrading.Dialogue.Archetypes["Angler"].Selling = {
    Generic = {
        "I can use this {item} on the boat. Here's {price}.",
        "Good find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might need it for a trip later.",
    },
    HighValue = {
        "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in bass. {price} incoming."
    },
    Trash = {
        "This {item} is basically seaweed-waste. I'll give you {price}.",
        "Material's a bit tangled... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
