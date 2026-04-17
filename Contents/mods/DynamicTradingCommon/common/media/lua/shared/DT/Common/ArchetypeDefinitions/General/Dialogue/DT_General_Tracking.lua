require "DT/Common/Config"

DynamicTrading.RegisterDialogue("General", "Tracking", {
    EN = {
        ReplyLive = {
            "Copy, {player.firstname}. I'm at {coords}, {site}.",
            "You have me now. {coords}. I'm {site}.",
            "Signal is clean enough. Mark {coords}; I'm {site}.",
            "Reading you. I'm holding at {coords}, {site}.",
            "Keep this frequency open. I'm at {coords}, {site}.",
        },
        ReplyLastKnown = {
            "Last clean ping had me at {coords}, {site}. I may have moved since then.",
            "My last solid position was {coords}. I was {site} when the relay caught me.",
            "If the tracker slips, start at {coords}. Last report had me {site}.",
            "The relay only caught my last beacon: {coords}, {site}.",
            "Best lead I've got for you is {coords}. I was {site} on the last burst.",
        },
        Approach100 = {
            "You're close. Keep following the signal and watch the approaches.",
            "About right. I'm nearby, still {site}.",
            "I hear you getting closer. Stay sharp and keep coming.",
        },
        Approach50 = {
            "Fifty meters sounds right. Look for movement near {building}.",
            "You're almost on me now. I'm still {site}.",
            "Close enough now that you should start seeing my position.",
        },
        Approach10 = {
            "There you are. I've got you in sight too.",
            "Visual confirmed. Lower the radio and look my way.",
            "I can see you now. No need to shout into the handset anymore.",
        }
    }
})