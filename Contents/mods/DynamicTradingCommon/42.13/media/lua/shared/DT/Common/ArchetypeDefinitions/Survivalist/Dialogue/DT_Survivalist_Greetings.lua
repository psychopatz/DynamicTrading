DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Survivalist"] = DynamicTrading.Dialogue.Archetypes["Survivalist"] or {}

DynamicTrading.Dialogue.Archetypes["Survivalist"].Greetings = {
    Default = {
        "You're too loud, {player.firstname}. What do you want?",
        "Watching the treeline... oh, it's you. Speak up, {player}.",
        "Stay low, stay alive. You need supplies, {player.firstname}?",
        "The world's ending, but the trade goes on. What's the word?",
        "Checking the perimeter. You safe out there, {player.firstname}?"
    },
    Morning = {
        "Morning light is dangerous. Be quick, {player.firstname}.",
        "Sun's up, trackers are out. What do you need, {player}?",
    },
    Evening = {
        "Sun's going down, eyes on the shadows. What's up, {player.firstname}?",
        "Evening, {player}. Hope you've got a secure spot for the night.",
    },
    Night = {
        "Whisper. There's things out here. What do you want, {player.firstname}?",
        "Night's for the dead. Talk fast, {player}.",
    },
    Raining = {
        "Rain covers the sounds. Good for moving, bad for hearing. What's up, {player}?",
        "Miserable weather. Keep your powder dry, {player.firstname}.",
    },
    Fog = {
        "Fog is a killer's best friend. Watch your back, {player.firstname}.",
        "Can't see five feet. You still there, {player}?"
    }
}
