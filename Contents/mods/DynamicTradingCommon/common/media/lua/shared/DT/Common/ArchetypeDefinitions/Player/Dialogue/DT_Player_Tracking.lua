require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Player", "Tracking", {
    EN = {
        Request = {
            "This is {player}. {npc}, send me your current coordinates.",
            "{npc}, I have your signal. Give me a location fix.",
            "{npc}, this is {player.firstname}. Need your exact position, over.",
            "I'm locking onto your channel, {npc}. Call out where you are.",
            "{npc}, radio check. Send your grid and surroundings.",
        },
        Approach100 = {
            "I'm getting closer, {npc}. Should be within a hundred meters now.",
            "Your signal is tightening up. I'm around a hundred meters out, {npc}.",
            "I'm nearly on your block, {npc}. Call anything out if you need to.",
        },
        Approach50 = {
            "I'm within fifty meters now, {npc}. Keep talking.",
            "Fifty meters or less. I should be close enough to spot you soon, {npc}.",
            "I'm right on top of the signal now, {npc}. Give me a visual cue.",
        },
        Approach10 = {
            "I'm within ten meters, {npc}. I think I can see you.",
            "Ten meters. Visual contact should be any second now, {npc}.",
            "I'm basically on you now, {npc}. Looking up from the radio.",
        }
    }
})