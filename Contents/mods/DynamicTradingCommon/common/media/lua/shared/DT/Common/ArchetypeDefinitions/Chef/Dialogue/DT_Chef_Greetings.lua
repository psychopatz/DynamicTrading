require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Chef", "Greetings", {
    EN = {
        Default = {
            "Smell that, {player.firstname}? It's progress. What can I cook up for ya?",
            "Kitchen is hot, orders are in. You need food or supplies, {player}?",
            "Life is short, eat well. What do you need, {player.firstname}?",
            "Checking the pantry. You buying or just browsing, {player}?",
            "Got some fresh ingredients today. What do you need, {player.firstname}?"
        },
        Morning = {
            "Early morning breakfast prep. What do you need, {player.firstname}?",
            "Sun's up, coffee's brewing. Ready for a trade, {player}?",
        },
        Evening = {
            "Sun's setting, dinner shift is starting. Quick trade, {player.firstname}?",
            "Evening, {player}. Hope you've got something for the pot.",
        },
        Night = {
            "Midnight snack? What do you want, {player.firstname}?",
            "Night's for the quiet prep. Speak up, {player}.",
        },
        Raining = {
            "Rain and ovens... cozy mix. What's up, {player.firstname}?",
            "Miserable weather. Come in and dry off, {player}.",
        },
        Fog = {
            "Can't see the stove in this fog. What's the word, {player.firstname}?",
            "Ghostly weather. You still there, {player}?"
        },
        NoBudget = {
            "Kitchen's open, but the till is empty. Buy some food?",
            "No cash for buying, but I've got fresh meals to sell.",
            "Broke as can be, but check out my daily specials!",
            "Can't afford purchases, but my kitchen is full of delicious goods."
        }
    }
})
