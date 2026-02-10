DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Sheriff"] = DynamicTrading.Dialogue.Archetypes["Sheriff"] or {}

DynamicTrading.Dialogue.Archetypes["Sheriff"].Greetings = {
    Default = {
        "This is the Sheriff. Behave yourself, {player.surname}.",
        "Keeping the peace is hard work. What do you need, {player}?",
        "Identify yourself. Citizen {player.surname}, you friendly?",
        "Police band is for official business, but go ahead.",
        "I'm listening, {player.surname}, but don't waste my time."
    }
}
