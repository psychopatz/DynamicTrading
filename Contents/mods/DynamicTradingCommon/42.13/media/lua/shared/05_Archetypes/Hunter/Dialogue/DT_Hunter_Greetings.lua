DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Hunter"] = DynamicTrading.Dialogue.Archetypes["Hunter"] or {}

DynamicTrading.Dialogue.Archetypes["Hunter"].Greetings = {
    Default = {
        "Quiet, {player.firstname}. You'll spook the prey. What do you need?",
        "Just tracking a scent. You need gear or a trophies, {player}?",
        "The woods are silent today. What can I do for ya, {player.firstname}?",
        "Watching the tracks. You buying or just browsing, {player}?",
        "Got some fresh pelts today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning stalk. What do you need, {player.firstname}?",
        "Sun's up, the forest is awake. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to return from the hunt. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your trap was full.",
    },
    Night = {
        "Hunting by moonlight... dangerous. What do you want, {player.firstname}?",
        "Night's for the quiet wait. Speak up, {player}.",
    },
    Raining = {
        "Rain and scents... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your hide dry, {player}.",
    },
    Fog = {
        "Can't see the quarry in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
