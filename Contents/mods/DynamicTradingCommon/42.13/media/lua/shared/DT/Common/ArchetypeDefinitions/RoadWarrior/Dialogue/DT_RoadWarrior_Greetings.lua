DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["RoadWarrior"] = DynamicTrading.Dialogue.Archetypes["RoadWarrior"] or {}

DynamicTrading.Dialogue.Archetypes["RoadWarrior"].Greetings = {
    Default = {
        "Keep the engine running, {player.firstname}. The road is calling. What do you need?",
        "Just checking the exhaust. You need fuel or gear, {player}?",
        "The world is a highway, and it's full of dead ends. What can I do for ya, {player.firstname}?",
        "Checking the tires. You buying or just browsing, {player}?",
        "Got some fresh gas today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning burn. What do you need, {player.firstname}?",
        "Sun's up, the asphalt is hot. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to find a secure spot. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your tank is full.",
    },
    Night = {
        "Driving by moonlight... mesmerizing. What do you want, {player.firstname}?",
        "Night's for the quiet patrol. Speak up, {player}.",
    },
    Raining = {
        "Rain and a highway... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your goggles dry, {player}.",
    },
    Fog = {
        "Can't see the markers in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
