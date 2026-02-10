DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Musician"] = DynamicTrading.Dialogue.Archetypes["Musician"] or {}

DynamicTrading.Dialogue.Archetypes["Musician"].Selling = {
    Generic = {
        "I can use this {item} for a gig. Here's {price}.",
        "Melodic find! {price} sent for the {item}. What else you got, {player.firstname}?",
        "I'll take the {item}. Might be someone's inspire later.",
    },
    HighValue = {
        "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
        "Legendary find! This {item} is worth its weight in gold records. {price} incoming."
    },
    Trash = {
        "This {item} is basically noise. I'll give you {price}.",
        "Material's a bit out of tune... but salvageable. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
    }
}
