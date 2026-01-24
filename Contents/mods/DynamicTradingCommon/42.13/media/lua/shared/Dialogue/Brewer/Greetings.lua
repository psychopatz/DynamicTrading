DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Brewer"] = DynamicTrading.Dialogue.Archetypes["Brewer"] or {}

DynamicTrading.Dialogue.Archetypes["Brewer"].Greetings = {
    Default = {
        "Smell that, {player.firstname}? It's the hops. What can I brew for ya?",
        "Just checking the fermenters. You need drinks or gear, {player}?",
        "The world is dry, let's wet it up. What can I do for ya, {player.firstname}?",
        "Checking the mash. You buying or just browsing, {player}?",
        "Got some fresh grains today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning mash-in. What do you need, {player.firstname}?",
        "Sun's up, the brewery is busy. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to start the boil. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your glass is full.",
    },
    Night = {
        "Brewing by moonlight... mesmerizing. What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain and a brewery... cozy mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your yeast dry, {player}.",
    },
    Fog = {
        "Can't see the airlock in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
