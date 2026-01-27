DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Butcher"] = DynamicTrading.Dialogue.Archetypes["Butcher"] or {}

DynamicTrading.Dialogue.Archetypes["Butcher"].Greetings = {
    Default = {
        "Yeah? I'm busy carving. What do you want, {player.firstname}?",
        "Watch the fingers. You here for the good cuts, {player}?",
        "Cutter's block is full today. Make it quick.",
        "Got some fresh meat... or at least, meat. What's the word, {player.firstname}?",
        "Sharp blades, steady hands. What can I do for ya, {player}?"
    },
    Morning = {
        "Sun's up, knives are sharpened. Early bird gets the prime cuts, {player.firstname}.",
        "Morning, {player}. Just finished the first prep. You buying?",
    },
    Evening = {
        "Sun's going down, cleaning up the blood. Speak up, {player.firstname}.",
        "Late for a trade, {player}. I was about to pack the shears.",
    },
    Night = {
        "Dark out there. Hope you're not the one getting carved, {player.firstname}.",
        "Working by candlelight is dangerous. This better be good, {player}.",
    },
    Raining = {
        "Rain's washing the gutters. Hard to keep the floor dry. What's up, {player}?",
        "Miserable out. Hope your stock isn't soaked, {player.firstname}.",
    },
    Fog = {
        "Can't see the end of my own blade in this fog. Be careful, {player}.",
        "Quiet like a slaughterhouse in here today. You there, {player}?"
    }
}
