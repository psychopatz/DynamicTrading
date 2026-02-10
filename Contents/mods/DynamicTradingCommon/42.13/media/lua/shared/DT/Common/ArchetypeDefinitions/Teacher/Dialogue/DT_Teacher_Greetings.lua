DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Teacher"] = DynamicTrading.Dialogue.Archetypes["Teacher"] or {}

DynamicTrading.Dialogue.Archetypes["Teacher"].Greetings = {
    Default = {
        "Eyes on the board, {player.firstname}. What's the lesson for today?",
        "Just grading the survival skills. You need knowledge or supplies, {player}?",
        "Learning is a lifelong journey, even now. What can I do for ya, {player.firstname}?",
        "Checking the curriculum. You buying or just browsing, {player}?",
        "Got some fresh chalk today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning lecture. What do you need, {player.firstname}?",
        "Sun's up, the classroom is quiet. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to reflect on the day's learning. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your mind is sharp.",
    },
    Night = {
        "Late night study? What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain and a warm classroom... cozy mix. What's up, {player.firstname}?",
        "Miserable weather. Come in and dry off, {player}.",
    },
    Fog = {
        "Can't see the indices in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
