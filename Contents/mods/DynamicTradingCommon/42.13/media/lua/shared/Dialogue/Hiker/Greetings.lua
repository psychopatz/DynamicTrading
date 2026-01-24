DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Hiker"] = DynamicTrading.Dialogue.Archetypes["Hiker"] or {}

DynamicTrading.Dialogue.Archetypes["Hiker"].Greetings = {
    Default = {
        "Keep moving, {player.firstname}. The trail is long. What do you need?",
        "Just enjoying the view... or whatever's left. You need maps or gear, {player}?",
        "Stepping lightly, staying high. What can I do for ya, {player.firstname}?",
        "Checking the trail markers. You buying or just browsing, {player}?",
        "Got some fresh jerky today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning summit. What do you need, {player.firstname}?",
        "Sun's up, the world is wide. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to find a camp. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your shoes are solid.",
    },
    Night = {
        "Hiking by moonlight... peaceful. What do you want, {player.firstname}?",
        "Night's for the quiet camp. Speak up, {player}.",
    },
    Raining = {
        "Rain and mud... tough trail. What's up, {player.firstname}?",
        "Miserable weather. Keep your pack dry, {player}.",
    },
    Fog = {
        "Can't see the markers in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
