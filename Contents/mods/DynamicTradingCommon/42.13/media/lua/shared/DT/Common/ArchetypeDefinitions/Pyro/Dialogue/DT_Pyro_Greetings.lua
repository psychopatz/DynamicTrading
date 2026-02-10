DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Pyro"] = DynamicTrading.Dialogue.Archetypes["Pyro"] or {}

DynamicTrading.Dialogue.Archetypes["Pyro"].Greetings = {
    Default = {
        "Got a light, {player.firstname}? Everything's better when it's burning.",
        "Just playing with matches. You need fuels or explosives, {player}?",
        "The world is cold, let's warm it up. What can I do for ya, {player.firstname}?",
        "Watching the embers. You buying or just browsing, {player}?",
        "Got some fresh accelerant today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning campfire. What do you need, {player.firstname}?",
        "Sun's up, the fire is out. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to light the night. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your fires are bright.",
    },
    Night = {
        "Burning by moonlight... mesmerizing. What do you want, {player.firstname}?",
        "Night's for the quiet burn. Speak up, {player}.",
    },
    Raining = {
        "Rain and fire... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your tinder dry, {player}.",
    },
    Fog = {
        "Can't see the light in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
