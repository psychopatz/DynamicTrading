DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Hiker"] = DynamicTrading.Dialogue.Archetypes["Hiker"] or {}

DynamicTrading.Dialogue.Archetypes["Hiker"].Selling = {
    Generic = {
        "I can use this {item} on the trail. Here's {price}.",
        "Wanderer find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might be someone's gear later.",
    },
    HighValue = {
        "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in first editions. {price} incoming."
    },
    Trash = {
        "This {item} is basically trail-waste. I'll give you {price}.",
        "Material's a bit worn... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
