DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Welder"] = DynamicTrading.Dialogue.Archetypes["Welder"] or {}

DynamicTrading.Dialogue.Archetypes["Welder"].Greetings = {
    Default = {
        "Hold the mask, {player.firstname}. Watching the arc?",
        "Just finishing a bead. You need metal or armor, {player}?",
        "The shop is hot today. What can I do for ya, {player.firstname}?",
        "Checking the joints. You buying or just browsing, {player}?",
        "Got some fresh steel today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning sparks. What do you need, {player.firstname}?",
        "Sun's up, torches are on. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to cool down the forge. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your walls are reinforced.",
    },
    Night = {
        "Welding in the dark... not ideal. What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain and torches... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your metal dry, {player}.",
    },
    Fog = {
        "Can't see the sparks in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
