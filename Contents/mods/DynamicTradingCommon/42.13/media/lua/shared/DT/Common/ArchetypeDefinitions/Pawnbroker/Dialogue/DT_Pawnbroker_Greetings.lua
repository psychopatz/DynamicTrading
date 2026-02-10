DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Pawnbroker"] = DynamicTrading.Dialogue.Archetypes["Pawnbroker"] or {}

DynamicTrading.Dialogue.Archetypes["Pawnbroker"].Greetings = {
    Default = {
        "Let me see what you've got, {player.firstname}. No junk, please.",
        "Just appraising the ruins. You need cash or a deal, {player}?",
        "Everything has a price, even you. What can I do for ya, {player.firstname}?",
        "Checking the vaults. You buying or just browsing, {player}?",
        "Got some fresh collectibles today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning appraisal. What do you need, {player.firstname}?",
        "Sun's up, the shop is quiet. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to lock the safe. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your items are authentic.",
    },
    Night = {
        "Appraising by candlelight... risky. What do you want, {player.firstname}?",
        "Night's for the quiet valuations. Speak up, {player}.",
    },
    Raining = {
        "Rain and gold... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your valuables dry, {player}.",
    },
    Fog = {
        "Can't see the hallmark in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
