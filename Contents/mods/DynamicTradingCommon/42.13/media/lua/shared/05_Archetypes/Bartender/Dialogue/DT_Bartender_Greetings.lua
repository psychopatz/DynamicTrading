DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Bartender"] = DynamicTrading.Dialogue.Archetypes["Bartender"] or {}

DynamicTrading.Dialogue.Archetypes["Bartender"].Greetings = {
    Default = {
        "What can I get for ya, {player.firstname}? Pouring the usual?",
        "Bar's open, rumors are free. You need a drink or some info, {player}?",
        "Pull up a stool, {player.firstname}. What's the word on the street?",
        "Checking the taps. You buying or just browsing, {player}?",
        "Got some fresh bottles today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning hair of the dog. What do you need, {player.firstname}?",
        "Sun's up, the bar is quiet. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, happy hour is starting. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your night is smooth.",
    },
    Night = {
        "Last call soon? What do you want, {player.firstname}?",
        "Night's for the quiet talks. Speak up, {player}.",
    },
    Raining = {
        "Rain and a warm bar... cozy mix. What's up, {player.firstname}?",
        "Miserable weather. Come in and dry off, {player}.",
    },
    Fog = {
        "Can't see the mirror in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
