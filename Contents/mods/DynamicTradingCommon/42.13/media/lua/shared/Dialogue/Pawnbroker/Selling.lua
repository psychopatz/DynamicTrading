DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Pawnbroker"] = DynamicTrading.Dialogue.Archetypes["Pawnbroker"] or {}

DynamicTrading.Dialogue.Archetypes["Pawnbroker"].Selling = {
    Generic = {
        "I can use this {item} for the shop. Here's {price}.",
        "Collectible find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might be someone's treasure later.",
    },
    HighValue = {
        "Whoa! That's some serious collectible! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in gold. {price} incoming."
    },
    Trash = {
        "This {item} is basically shop-waste. I'll give you {price}.",
        "Material's a bit dusty... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
