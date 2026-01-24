DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Scavenger"] = DynamicTrading.Dialogue.Archetypes["Scavenger"] or {}

DynamicTrading.Dialogue.Archetypes["Scavenger"].Greetings = {
    Default = {
        "Found some good loot! Want to see? Oh, it's you {player.firstname}.",
        "Sifting through the piles... What do you need, {player}?",
        "One man's trash, right? What's the word, {player.firstname}?",
        "Searching the ruins. You here for the finds, {player}?",
        "Check this out... oh, wait, you're buying? Hey {player}!"
    },
    Morning = {
        "Early scrounging pays off. What do you need, {player.firstname}?",
        "Morning, {player}. Just back from a raid. Want to trade?",
    },
    Evening = {
        "Sun's setting, time to hide. Quick trade, {player.firstname}?",
        "Evening, {player}. Scored some loot today. Take a look.",
    },
    Night = {
        "Night's for the brave. What do you want, {player.firstname}?",
        "Sifting in the dark is hard work. Speak up, {player}.",
    },
    Raining = {
        "Rain's making the junk wet. Hate this. What's up, {player.firstname}?",
        "Miserable weather for a scavenge. What do you need, {player}?",
    },
    Fog = {
        "Can't see any loot in this fog. What's the word, {player.firstname}?",
        "Ghost town out there. You still around, {player}?"
    }
}
