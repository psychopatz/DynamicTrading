require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Blacksmith", "Greetings", {
    EN = {
        Default = {
            "Hot forge, {player.firstname}. Watching the sparks?",
            "Just hammering the steel. You need blades or armor, {player}?",
            "The world is cold, let's fire it up. What can I do for ya, {player.firstname}?",
            "Checking the anvil. You buying or just browsing, {player}?",
            "Got some fresh iron today. What do you need, {player.firstname}?"
        },
        Morning = {
            "Early morning hammering. What do you need, {player.firstname}?",
            "Sun's up, the forge is hot. Ready for a trade, {player}?",
        },
        Evening = {
            "Sun's setting, time to cool the metal. Quick trade, {player.firstname}?",
            "Evening, {player}. Hope your walls are reinforced.",
        },
        Night = {
            "Forging by moonlight... mesmerizing. What do you want, {player.firstname}?",
            "Night's for the quiet work. Speak up, {player}.",
        },
        Raining = {
            "Rain and a forge... cozy mix. What's up, {player.firstname}?",
            "Miserable weather. Keep your steel dry, {player}.",
        },
        Fog = {
            "Can't see the arc in this fog. What's the word, {player.firstname}?",
            "Ghostly weather. You still there, {player}?"
        },
        NoBudget = {
            "The forge is hot, but my budget's cold. Want to buy some gear?",
            "No cash for buying, but I've got weapons and tools to sell.",
            "Broke as can be, but check out my latest forged items.",
            "Can't afford purchases, but my anvil is full of quality work."
        }
    }
})
