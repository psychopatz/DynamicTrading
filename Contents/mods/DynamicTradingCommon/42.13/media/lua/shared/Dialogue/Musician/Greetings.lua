DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Musician"] = DynamicTrading.Dialogue.Archetypes["Musician"] or {}

DynamicTrading.Dialogue.Archetypes["Musician"].Greetings = {
    Default = {
        "Catch the rhythm, {player.firstname}. What's the melody today?",
        "Just tuning the soul. You need harmony or gear, {player}?",
        "The world is quiet, but the music never stops. What can I do for ya, {player.firstname}?",
        "Checking the scales. You buying or just browsing, {player}?",
        "Got some fresh vinyl today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning overture. What do you need, {player.firstname}?",
        "Sun's up, the world is in tune. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time for the evening sonata. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your song is a good one.",
    },
    Night = {
        "Composing by moonlight... inspiring. What do you want, {player.firstname}?",
        "Night's for the quiet ballads. Speak up, {player}.",
    },
    Raining = {
        "Rain and rhythm... natural mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your instruments dry, {player}.",
    },
    Fog = {
        "Can't see the notes in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
