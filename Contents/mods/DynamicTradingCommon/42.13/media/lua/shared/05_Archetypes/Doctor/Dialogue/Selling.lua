DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Doctor"] = DynamicTrading.Dialogue.Archetypes["Doctor"] or {}

DynamicTrading.Dialogue.Archetypes["Doctor"].Selling = {
    Generic = {
        "This {item} will help the patients. Thank you. {price} sent.",
        "I can sterilize this {item}. Credits sent.",
        "Medical supplies are always needed. Good find, {player.firstname}."
    },
    HighMarkup = {
        "That's a lot of money ({price}) for a {item}... but lives are at stake. Deal.",
        "I'll pay {price}, just make sure it's clean."
    }
}
