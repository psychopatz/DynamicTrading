DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Painter"] = DynamicTrading.Dialogue.Archetypes["Painter"] or {}

DynamicTrading.Dialogue.Archetypes["Painter"].Greetings = {
    Default = {
        "Catch the light, {player.firstname}. What's the masterpiece today?",
        "Just mixing the colors. You need palettes or gear, {player}?",
        "The world is grey, let's add some life. What can I do for ya, {player.firstname}?",
        "Checking the sketch. You buying or just browsing, {player}?",
        "Got some fresh pigments today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning sketch. What do you need, {player.firstname}?",
        "Sun's up, the light is perfect. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time for the evening wash. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your colors are bright.",
    },
    Night = {
        "Painting by moonlight... mesmerising. What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain and a wash... cozy mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your canvas dry, {player}.",
    },
    Fog = {
        "Can't see the depth in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
