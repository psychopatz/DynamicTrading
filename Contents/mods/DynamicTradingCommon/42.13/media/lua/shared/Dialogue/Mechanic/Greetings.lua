DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Mechanic"] = DynamicTrading.Dialogue.Archetypes["Mechanic"] or {}

DynamicTrading.Dialogue.Archetypes["Mechanic"].Greetings = {
    Default = {
        "Hold on, just wiping my hands. What's the engine trouble, {player.firstname}?",
        "Checking the valves. You need a tune-up or just parts, {player}?",
        "Sounds like a piston's knocking... oh, it's just you. Hey, {player.firstname}.",
        "Garage is open. What's your project status, {player}?",
        "Grease, oil, and more oil. What do you need, {player.firstname}?"
    },
    Morning = {
        "Sun's up, compressors are humming. What's on the block today, {player.firstname}?",
        "Morning, {player}. Ready to get your hands dirty?",
    },
    Evening = {
        "Putting the tools away soon. Make it quick, {player.firstname}.",
        "Sun's setting, but the work never ends. What's the word, {player}?",
    },
    Night = {
        "Tinkering in the dark... not ideal. You need something, {player.firstname}?",
        "Flashlight's dying. Tell me what you need, {player}.",
    },
    Raining = {
        "Rain's making everything rust. Hate this weather. What you got, {player.firstname}?",
        "Damp air is bad for the filters. Keep it dry, {player}.",
    },
    Fog = {
        "Can't see the bumper in front of me. Watch those corners, {player.firstname}.",
        "Visibility is zero. Safe driving, {player}. What can I do for ya?"
    }
}
