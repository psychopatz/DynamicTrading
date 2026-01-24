DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Office"] = DynamicTrading.Dialogue.Archetypes["Office"] or {}

DynamicTrading.Dialogue.Archetypes["Office"].Greetings = {
    Default = {
        "Filing the reports, {player.firstname}. What's the requisition?",
        "Just checking the manifest. You need supplies or gear, {player}?",
        "The world is a cubicle, let's keep it organized. What can I do for ya, {player.firstname}?",
        "Checking the inventory. You buying or just browsing, {player}?",
        "Got some fresh ink today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning roll call. What do you need, {player.firstname}?",
        "Sun's up, the warehouse is busy. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to finalize the manifest. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your stores are full.",
    },
    Night = {
        "Night shift logistics? What do you want, {player.firstname}?",
        "Night's for the quiet inventory. Speak up, {player}.",
    },
    Raining = {
        "Rain and shipments... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your crates dry, {player}.",
    },
    Fog = {
        "Can't see the pallets in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
