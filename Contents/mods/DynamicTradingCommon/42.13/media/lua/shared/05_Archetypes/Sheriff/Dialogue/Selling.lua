DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Sheriff"] = DynamicTrading.Dialogue.Archetypes["Sheriff"] or {}

DynamicTrading.Dialogue.Archetypes["Sheriff"].Selling = {
    Generic = {
        "We can use this {item} at the station. {price} paid.",
        "Submitting this to evidence. Here's your cut: {price}.",
        "Good work, Citizen {player.surname}. {price} transferred."
    },
    HighMarkup = {
        "That's above budget, but we need the {item}. {price} authorized.",
        "Extortionate, but necessary for public safety. {price} sent."
    }
}
