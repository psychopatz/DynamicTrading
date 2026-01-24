DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Survivalist"] = DynamicTrading.Dialogue.Archetypes["Survivalist"] or {}

DynamicTrading.Dialogue.Archetypes["Survivalist"].Selling = {
    Generic = {
        "I can use this {item} in the field. Here's {price}.",
        "Fair trade. {price} sent for the {item}. Stay safe, {player.firstname}.",
        "I'll take the {item}. Better than nothing out here.",
    },
    HighValue = {
        "Now that's a find! {price} for the {item}. You're good at this.",
        "Impressive. This {item} is worth its weight in gold. {price} incoming."
    },
    Trash = {
        "This {item} is mostly junk. I'll give you {price}.",
        "Scraps... but everything has a use. {price} for the {item}."
    },
    HighMarkup = {
        "You're a shark, {player.firstname}. {price} for a {item}? Alright, I'll pay."
    }
}
