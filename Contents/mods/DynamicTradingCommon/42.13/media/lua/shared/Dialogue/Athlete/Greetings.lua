DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Athlete"] = DynamicTrading.Dialogue.Archetypes["Athlete"] or {}

DynamicTrading.Dialogue.Archetypes["Athlete"].Greetings = {
    Default = {
        "Keep up the pace, {player.firstname}. What's the workout today?",
        "Just finishing a set. You need gear or a boost, {player}?",
        "Stay fit, stay alive. What can I do for ya, {player.firstname}?",
        "Checking the training room. You buying or just browsing, {player}?",
        "Got some fresh supplements today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning cardio. What do you need, {player.firstname}?",
        "Sun's up, the gym is quiet. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time for the cool down. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your muscles are strong.",
    },
    Night = {
        "Training by moon light... refreshing. What do you want, {player.firstname}?",
        "Night's for the quiet prep. Speak up, {player}.",
    },
    Raining = {
        "Rain and a workout... natural mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your sneakers dry, {player}.",
    },
    Fog = {
        "Can't see the laps in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
