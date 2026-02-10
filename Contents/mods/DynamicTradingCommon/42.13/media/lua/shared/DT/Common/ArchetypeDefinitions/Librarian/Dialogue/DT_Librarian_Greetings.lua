DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Librarian"] = DynamicTrading.Dialogue.Archetypes["Librarian"] or {}

DynamicTrading.Dialogue.Archetypes["Librarian"].Greetings = {
    Default = {
        "Quiet please, {player.firstname}. Knowledge is being preserved. What do you need?",
        "Just cataloging the survivors. You need information or supplies, {player}?",
        "A world without books is a world without soul. What can I do for ya, {player.firstname}?",
        "Checking the archives. You buying or just browsing, {player}?",
        "Got some fresh ink today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning study. What do you need, {player.firstname}?",
        "Sun's up, the archives are open. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to reflect on the day's learning. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your mind is sharp.",
    },
    Night = {
        "Reading by candlelight... enlightening. What do you want, {player.firstname}?",
        "Night's for the deep research. Speak up, {player}.",
    },
    Raining = {
        "Rain and parchment... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your books dry, {player}.",
    },
    Fog = {
        "Can't see the indices in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
