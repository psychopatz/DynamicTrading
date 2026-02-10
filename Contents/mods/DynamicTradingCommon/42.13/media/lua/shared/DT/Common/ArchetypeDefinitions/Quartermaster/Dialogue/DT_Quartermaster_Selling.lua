DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Quartermaster"] = DynamicTrading.Dialogue.Archetypes["Quartermaster"] or {}

DynamicTrading.Dialogue.Archetypes["Quartermaster"].Selling = {
    Generic = {
        "I can use this {item} for the mission. Here's {price}.",
        "Logistical find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might be someone's supply later.",
    },
    HighValue = {
        "Whoa! That's some serious asset! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in rations. {price} incoming."
    },
    Trash = {
        "This {item} is basically waste. I'll give you {price}.",
        "Material's a bit damaged... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
