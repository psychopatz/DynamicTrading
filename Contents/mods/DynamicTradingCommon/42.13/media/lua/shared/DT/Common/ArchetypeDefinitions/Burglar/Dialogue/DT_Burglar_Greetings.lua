DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Burglar"] = DynamicTrading.Dialogue.Archetypes["Burglar"] or {}

DynamicTrading.Dialogue.Archetypes["Burglar"].Greetings = {
    Default = {
        "Quiet, {player.firstname}. I'm trying to work. What do you want?",
        "Just checking the locks. You need tools or loot, {player}?",
        "The world is locked, let's open it up. What can I do for ya, {player.firstname}?",
        "Checking the vaults. You buying or just browsing, {player}?",
        "Got some fresh lockpicks today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning raid. What do you need, {player.firstname}?",
        "Sun's up, the world is quiet. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to start the shift. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your locks are solid.",
    },
    Night = {
        "Raid by moonlight... mesmerizing. What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain and a raid... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your tools dry, {player}.",
    },
    Fog = {
        "Can't see the pins in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
