DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Welder"] = DynamicTrading.Dialogue.Archetypes["Welder"] or {}

DynamicTrading.Dialogue.Archetypes["Welder"].Selling = {
    Generic = {
        "I can salvage some metal from this {item}. Here's {price}.",
        "Industrial gear! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might need it for a project later.",
    },
    HighValue = {
        "Whoa! That's some serious hardware! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in steel. {price} incoming."
    },
    Trash = {
        "This {item} is basically scrap metal. I'll give you {price}.",
        "Material's a bit rusty... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
