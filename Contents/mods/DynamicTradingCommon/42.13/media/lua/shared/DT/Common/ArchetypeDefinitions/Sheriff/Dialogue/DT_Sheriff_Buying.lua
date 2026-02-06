DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Sheriff"] = DynamicTrading.Dialogue.Archetypes["Sheriff"] or {}

DynamicTrading.Dialogue.Archetypes["Sheriff"].Buying = {
    Generic = {
        "Approved. Use the {item} responsibly.",
        "Logged in the precinct database. Take it.",
        "Just don't cause trouble with this {item}, okay {player.surname}?"
    },
    NoCash = {
        "Citizen {player.surname}, you have insufficient funds for {price}.",
        "I can't authorize this transfer. You're short {price}."
    }
}
