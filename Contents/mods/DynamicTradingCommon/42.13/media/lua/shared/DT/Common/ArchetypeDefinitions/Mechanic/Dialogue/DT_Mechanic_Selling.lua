DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Mechanic"] = DynamicTrading.Dialogue.Archetypes["Mechanic"] or {}

DynamicTrading.Dialogue.Archetypes["Mechanic"].Selling = {
    Generic = {
        "I can salvage some parts from this {item}. Here's {price}.",
        "Looks useful. {price} sent for the {item}. Keep 'em coming.",
        "I'll take the {item}. Might need it for a project later.",
    },
    HighValue = {
        "Now that's what I call a find! {price} for the {item}. Good work.",
        "Precision gear! This {item} is exactly what I needed. {price} incoming."
    },
    Trash = {
        "This {item} is barely worth the scrap. I'll give you {price}.",
        "Total junk... but I might find a bolt in it. {price} for the {item}."
    },
    HighMarkup = {
        "You're a tough negotiator, {player.firstname}. {price} for a {item}? Alright."
    }
}
