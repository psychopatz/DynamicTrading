require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Player", "Greetings", {
    EN = {
        Default = {
            "This is {player}. Do you copy?",
            "Radio check. This is {player} calling on this frequency.",
            "Can anyone hear me? This is {player}.",
            "Signal check. {player.firstname} here. Are you open?",
            "Calling any traders. This is {player}, over.",
            "Broadcasting on open channel. {player} requesting trade.",
            "Is this thing working? This is {player}.",
            "Hey, it's {player.firstname}. Pick up if you're there.",
            "This is {player}. Seeking supplies, over."
        }
    },
    PH = {
        Default = {
            "Ito si {player}. Naririnig niyo ba ako?",
            "Radio check. Ito si {player} na tumatawag sa frequency na ito.",
            "May nakakarinig ba sa akin? Ito si {player}.",
            "Signal check. Si {player.firstname} ito. Bukas ba kayo?",
            "Tumatawag sa anumang trader. Ito si {player}, over.",
            "Nagbo-broadcast sa open channel. Si {player} ay humihiling ng trade.",
            "Gumagana ba 'to? Ito si {player}.",
            "Hey, si {player.firstname} ito. Sumagot naman kayo kung nandiyan kayo.",
            "Ito si {player}. Naghahanap ng supplies, over."
        }
    }
})
