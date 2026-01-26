DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Janitor"] = DynamicTrading.Dialogue.Archetypes["Janitor"] or {}

DynamicTrading.Dialogue.Archetypes["Janitor"].Selling = {
    Generic = {
        "I can use this {item} for the cleaning. Here's {price}.",
        "Tidy find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might be someone's supply later.",
    },
    HighValue = {
        "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in floor-wax. {price} incoming."
    },
    Trash = {
        "This {item} is basically floor-waste. I'll give you {price}.",
        "Material's a bit dusty... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
