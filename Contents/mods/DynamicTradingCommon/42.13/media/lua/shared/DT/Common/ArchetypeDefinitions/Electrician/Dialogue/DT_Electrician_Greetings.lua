DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Electrician"] = DynamicTrading.Dialogue.Archetypes["Electrician"] or {}

DynamicTrading.Dialogue.Archetypes["Electrician"].Greetings = {
    Default = {
        "Careful around the terminals, {player.firstname}. What's the voltage?",
        "Just fixing a short. You need parts or power, {player}?",
        "The grid is down, but the trade is live. What can I do for ya, {player.firstname}?",
        "Measuring the current. You buying or just browsing, {player}?",
        "Got some fresh batteries today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning recharge. What do you need, {player.firstname}?",
        "Sun's up, solar's charging. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to conserve power. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your lights are staying on.",
    },
    Night = {
        "Working in the dark... not ideal. What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain and electricity... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your device dry, {player}.",
    },
    Fog = {
        "Can't see the wires in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
