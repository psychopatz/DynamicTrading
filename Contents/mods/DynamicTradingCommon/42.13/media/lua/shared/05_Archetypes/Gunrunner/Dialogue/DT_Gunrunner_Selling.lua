DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Gunrunner"] = DynamicTrading.Dialogue.Archetypes["Gunrunner"] or {}

DynamicTrading.Dialogue.Archetypes["Gunrunner"].Selling = {
    Generic = {
        "I can strip this {item} for parts. Deal at {price}.",
        "Looks like it shoots straight. I'll buy the {item} for {price}.",
        "Never have enough brass. Sending {price} credits."
    },
    HighMarkup = {
        "You're bleeding me dry at {price}... but I need the firepower. Done.",
        "Fine. {price}. But this {item} better not jam."
    }
}
