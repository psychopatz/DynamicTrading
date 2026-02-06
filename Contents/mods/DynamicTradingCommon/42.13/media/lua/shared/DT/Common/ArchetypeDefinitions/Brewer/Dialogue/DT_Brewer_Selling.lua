DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Brewer"] = DynamicTrading.Dialogue.Archetypes["Brewer"] or {}

DynamicTrading.Dialogue.Archetypes["Brewer"].Selling = {
    Generic = {
        "I can use this {item} for a brew. Here's {price}.",
        "High-proof find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might be someone's drink later.",
    },
    HighValue = {
        "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in first editions. {price} incoming."
    },
    Trash = {
        "This {item} is basically brew-waste. I'll give you {price}.",
        "Material's a bit spoiled... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
