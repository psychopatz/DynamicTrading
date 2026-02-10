DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Geek"] = DynamicTrading.Dialogue.Archetypes["Geek"] or {}

DynamicTrading.Dialogue.Archetypes["Geek"].Greetings = {
    Default = {
        "Level up, {player.firstname}. What's the quest today?",
        "Just debugging the apocalypse. You need tech or gear, {player}?",
        "The world is a glitch, let's optimize it. What can I do for ya, {player.firstname}?",
        "Checking the codebase. You buying or just browsing, {player}?",
        "Got some fresh hardware today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning compile. What do you need, {player.firstname}?",
        "Sun's up, the world is live. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to push the changes. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your connection is stable.",
    },
    Night = {
        "Coding by moonlight... mesmerizing. What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain and electronics... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your device dry, {player}.",
    },
    Fog = {
        "Can't see the depth in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
