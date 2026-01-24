DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Angler"] = DynamicTrading.Dialogue.Archetypes["Angler"] or {}

DynamicTrading.Dialogue.Archetypes["Angler"].Greetings = {
    Default = {
        "Quiet on the line, {player.firstname}. Fish are biting. What do you need?",
        "Just checking the lures. You need gear or a story, {player}?",
        "The water is calm today. What can I do for ya, {player.firstname}?",
        "Watching the ripples. You buying or just browsing, {player}?",
        "Got some fresh bait today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning cast. What do you need, {player.firstname}?",
        "Sun's up, the lake is awake. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to pack the tackle. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your catch was a big one.",
    },
    Night = {
        "Night fishing... peaceful. What do you want, {player.firstname}?",
        "Night's for the quiet wait. Speak up, {player}.",
    },
    Raining = {
        "Rain and ripples... good for fishing. What's up, {player.firstname}?",
        "Miserable weather. Keep your gear dry, {player}.",
    },
    Fog = {
        "Can't see the bobber in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
