DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Tribal"] = DynamicTrading.Dialogue.Archetypes["Tribal"] or {}

DynamicTrading.Dialogue.Archetypes["Tribal"].Greetings = {
    Default = {
        "The spirits have guided you here, {player.firstname}. What do you seek?",
        "Just honor the ancestors. You need spears or spirit, {player}?",
        "The earth provides, even now. What can I do for ya, {player.firstname}?",
        "Checking the totems. You buying or just browsing, {player}?",
        "Got some fresh warding today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning chant. What do you need, {player.firstname}?",
        "Sun's up, the world is awake. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to return the fire. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your spirit is calm.",
    },
    Night = {
        "Chanting by moonlight... mesmerising. What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain and a fire... cozy mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your spirit dry, {player}.",
    },
    Fog = {
        "Can't see the spirits in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
