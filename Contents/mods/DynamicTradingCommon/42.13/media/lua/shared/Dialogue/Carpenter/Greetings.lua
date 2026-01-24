DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Carpenter"] = DynamicTrading.Dialogue.Archetypes["Carpenter"] or {}

DynamicTrading.Dialogue.Archetypes["Carpenter"].Greetings = {
    Default = {
        "Measure twice, cut once, {player.firstname}. What's the project?",
        "Just finishing a frame. You need wood or tools, {player}?",
        "The world's in pieces, but we can build it back. What can I do for ya, {player.firstname}?",
        "Checking the lumber. You buying or just browsing, {player}?",
        "Got some fresh cedar today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning sawing. What do you need, {player.firstname}?",
        "Sun's up, the shop is busy. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to pack the chisel. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your structures are sound.",
    },
    Night = {
        "Sawing in the dark... not ideal. What do you want, {player.firstname}?",
        "Night's for the quiet joinery. Speak up, {player}.",
    },
    Raining = {
        "Rain and wood... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your planks dry, {player}.",
    },
    Fog = {
        "Can't see the level in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
