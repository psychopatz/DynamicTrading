DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Scavenger"] = DynamicTrading.Dialogue.Archetypes["Scavenger"] or {}

DynamicTrading.Dialogue.Archetypes["Scavenger"].Selling = {
    Generic = {
        "I can trade this {item} for something else. Here's {price}.",
        "Good find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might be someone's treasure later.",
    },
    HighValue = {
        "Whoa! That's some serious loot! {price} for the {item}. You're a pro.",
        "Legendary haul! This {item} is worth its weight in gold. {price} incoming."
    },
    Trash = {
        "This {item} is basically trash. I'll give you {price}.",
        "Scraps... but I can find a use. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
