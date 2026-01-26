DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.General = DynamicTrading.Dialogue.General or {}

DynamicTrading.Dialogue.General.Greetings = {
    Default = {
        "I hear you, {player.firstname}. What do you need?",
        "Signal is decent. {player.firstname}, you buying or selling?",
        "I'm here, {player}. Make it quick, battery's dying.",
        "Yeah, I copy. Go ahead, {player.firstname}.",
        "Channel is open, {player.surname}. Keep it short.",
        "I'm listening, {player}. What's going on?",
        "Hey {player.firstname}. You still alive out there?",
        "Connection is stable. Talk to me, {player.firstname}.",
        "This is the trading post. {player}, state your business.",
        "I recognize the voice. Hello, {player.firstname}.",
        "Long time no see, {player}. Or... hear, I guess.",
        "You got credits, {player.firstname}? Then I'm listening."
    },
    Morning = { 
        "Morning, {player.firstname}. Sun's up.",
        "Early start, huh {player}? What do you need?",
        "Coffee's cold, but I'm here. Go ahead, {player.firstname}.",
        "Alive for another sunrise, {player.firstname}. Let's trade.",
        "Daylight's burning, {player}. Talk to me."
    },
    Evening = { 
        "Sun's going down, {player.firstname}. Be careful.",
        "Getting dark. Make this count, {player}.",
        "Evening, {player.surname}. Keep your voice down.",
        "I'm packing up soon, {player.firstname}. Hurry up.",
        "Shadows are getting long. What do you need, {player}?"
    },
    Night = { 
        "You should be asleep, {player.firstname}.",
        "Quiet night... let's keep it that way, {player}.",
        "Trading in the dark? Brave, {player.firstname}.",
        "Whisper if you can, {player}. Sound travels.",
        "It's pitch black, {player.firstname}. Hope you're safe."
    },
    Raining = {
        "It's pouring over here, {player.firstname}. Hard to hear you.",
        "Damn rain keeps messing with the signal. Say again, {player}?",
        "Miserable weather, {player.firstname}. Let's cheer up with a trade.",
        "Can barely hear you over the thunder, {player.firstname}.",
        "Storm's bad. Make it quick, {player}."
    },
    Fog = {
        "Can't see five feet in front of me, {player.firstname}.",
        "Fog is thick today. Watch your back, {player}.",
        "Spooky weather, {player.firstname}. You buying something?"
    }
}
