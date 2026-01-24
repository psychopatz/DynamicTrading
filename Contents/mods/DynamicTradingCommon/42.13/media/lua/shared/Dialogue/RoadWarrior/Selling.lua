DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["RoadWarrior"] = DynamicTrading.Dialogue.Archetypes["RoadWarrior"] or {}

DynamicTrading.Dialogue.Archetypes["RoadWarrior"].Selling = {
    Generic = {
        "I can use this {item} for a burn. Here's {price}.",
        "High-speed find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might be someone's fuel later.",
    },
    HighValue = {
        "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in first editions. {price} incoming."
    },
    Trash = {
        "This {item} is basically asphalt-waste. I'll give you {price}.",
        "Material's a bit worn... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
