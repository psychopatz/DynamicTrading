DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Blacksmith"] = DynamicTrading.Dialogue.Archetypes["Blacksmith"] or {}

DynamicTrading.Dialogue.Archetypes["Blacksmith"].Greetings = {
    Default = {
        "Hot forge, {player.firstname}. Watching the sparks?",
        "Just hammering the steel. You need blades or armor, {player}?",
        "The world is cold, let's fire it up. What can I do for ya, {player.firstname}?",
        "Checking the anvil. You buying or just browsing, {player}?",
        "Got some fresh iron today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning hammering. What do you need, {player.firstname}?",
        "Sun's up, the forge is hot. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to cool the metal. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your walls are reinforced.",
    },
    Night = {
        "Forging by moonlight... mesmerizing. What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain and a forge... cozy mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your steel dry, {player}.",
    },
    Fog = {
        "Can't see the arc in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
