DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Tailor"] = DynamicTrading.Dialogue.Archetypes["Tailor"] or {}

DynamicTrading.Dialogue.Archetypes["Tailor"].Greetings = {
    Default = {
        "Mind the needles, {player.firstname}. What's the thread count?",
        "Looking a bit ragged, {player}. Need a patch or some new threads?",
        "Dress for success, even in the apocalypse. What can I do for ya, {player.firstname}?",
        "Measuring up the stock. You buying or just browsing, {player}?",
        "Got some fine fabrics today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning sew-in. What do you need, {player.firstname}?",
        "Sun's up, stitching's started. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, hard to see the stitches. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your gear is holding up.",
    },
    Night = {
        "Sewing by candlelight... tricky. What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain's making the cotton damp. Terrible. What's up, {player.firstname}?",
        "Miserable weather. Hope your clothes are waterproof, {player}.",
    },
    Fog = {
        "Can't see the patterns in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
