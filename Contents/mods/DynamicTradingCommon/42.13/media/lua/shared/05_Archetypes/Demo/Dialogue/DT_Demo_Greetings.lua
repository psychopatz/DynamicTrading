DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Demo"] = DynamicTrading.Dialogue.Archetypes["Demo"] or {}

DynamicTrading.Dialogue.Archetypes["Demo"].Greetings = {
    Default = {
        "Careful with the fuse, {player.firstname}. What's the target?",
        "Just prepping the charges. You need explosives or gear, {player}?",
        "The world is a structure, let's take it down. What can I do for ya, {player.firstname}?",
        "Checking the detonation. You buying or just browsing, {player}?",
        "Got some fresh gunpowder today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning boom. What do you need, {player.firstname}?",
        "Sun's up, the world is quiet. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to finalize the blast. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your walls are solid.",
    },
    Night = {
        "Blasting by moonlight... mesmerizing. What do you want, {player.firstname}?",
        "Night's for the quiet prep. Speak up, {player}.",
    },
    Raining = {
        "Rain and explosives... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your powder dry, {player}.",
    },
    Fog = {
        "Can't see the markers in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
