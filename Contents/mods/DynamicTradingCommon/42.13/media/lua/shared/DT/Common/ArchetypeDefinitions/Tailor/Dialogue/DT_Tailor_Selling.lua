DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Tailor"] = DynamicTrading.Dialogue.Archetypes["Tailor"] or {}

DynamicTrading.Dialogue.Archetypes["Tailor"].Selling = {
    Generic = {
        "I can use this {item} for parts. Here's {price}.",
        "Interesting texture. {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might be someone's treasure later.",
    },
    HighValue = {
        "Whoa! That's some serious craftsmanship! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in silk. {price} incoming."
    },
    Trash = {
        "This {item} is basically rags. I'll give you {price}.",
        "Material's a bit worn... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
