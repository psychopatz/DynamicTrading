DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Designer"] = DynamicTrading.Dialogue.Archetypes["Designer"] or {}

DynamicTrading.Dialogue.Archetypes["Designer"].Greetings = {
    Default = {
        "Style is eternal, {player.firstname}. What's the look today?",
        "Just finishing a sketch. You need aesthetics or gear, {player}?",
        "The world is ugly, let's make it beautiful. What can I do for ya, {player.firstname}?",
        "Checking the blueprints. You buying or just browsing, {player}?",
        "Got some fresh swatches today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning layout. What do you need, {player.firstname}?",
        "Sun's up, the studio is quiet. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to finalize the design. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your space is elegant.",
    },
    Night = {
        "Designing by moonlight... mesmerising. What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain and a studio... cozy mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your sketches dry, {player}.",
    },
    Fog = {
        "Can't see the depth in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
