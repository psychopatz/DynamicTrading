DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Janitor"] = DynamicTrading.Dialogue.Archetypes["Janitor"] or {}

DynamicTrading.Dialogue.Archetypes["Janitor"].Greetings = {
    Default = {
        "Mind the wet floor, {player.firstname}. What's the mess today?",
        "Just keeping the place tidy. You need soaps or supplies, {player}?",
        "Someone's gotta clean up the apocalypse. What can I do for ya, {player.firstname}?",
        "Checking the supply closet. You buying or just browsing, {player}?",
        "Got some fresh bleach today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning sweep. What do you need, {player.firstname}?",
        "Sun's up, the halls are quiet. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to empty the bins. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your walls are clean.",
    },
    Night = {
        "Mopping in the dark... not ideal. What do you want, {player.firstname}?",
        "Night's for the quiet scrub. Speak up, {player}.",
    },
    Raining = {
        "Rain and mud... extra work. What's up, {player.firstname}?",
        "Miserable weather. Wipe your feet, {player}.",
    },
    Fog = {
        "Can't see the stains in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
