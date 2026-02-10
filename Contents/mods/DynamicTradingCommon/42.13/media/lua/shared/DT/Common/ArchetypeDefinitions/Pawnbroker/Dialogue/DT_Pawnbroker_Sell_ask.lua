DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Pawnbroker"] = DynamicTrading.Dialogue.Archetypes["Pawnbroker"] or {}

DynamicTrading.Dialogue.Archetypes["Pawnbroker"].SellAskResponse = {
    "Need {wants} for some appraising. Don't bother with {forbid}.",
    "I'm low on {wants}. Keep your {forbid}, I can't use it.",
    "Looking for {wants}. {forbid} is just taking up space, so keep it.",
}
