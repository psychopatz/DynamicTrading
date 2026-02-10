DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Herbalist"] = DynamicTrading.Dialogue.Archetypes["Herbalist"] or {}

DynamicTrading.Dialogue.Archetypes["Herbalist"].Greetings = {
    Default = {
        "Walk softly, {player.firstname}. The earth is speaking. What do you need?",
        "Just harvesting some roots. You need herbs or healing, {player}?",
        "The garden is thriving today. What can I do for ya, {player.firstname}?",
        "Checking the leaves. You buying or just browsing, {player}?",
        "Got some fresh blooms today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning dew. What do you need, {player.firstname}?",
        "Sun's up, the forest is awake. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to return to the earth. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your spirit is calm.",
    },
    Night = {
        "Gathering moon-herbs... not ideal. What do you want, {player.firstname}?",
        "Night's for the quiet growth. Speak up, {player}.",
    },
    Raining = {
        "Rain and growth... natural mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your plants dry, {player}.",
    },
    Fog = {
        "Can't see the blossoms in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
