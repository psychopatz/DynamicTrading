DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = {}

-- =============================================================================
-- 1. GENERAL DIALOGUE (Default for all traders)
-- =============================================================================
DynamicTrading.Dialogue.General = {

    -- GREETINGS (Triggered on Window Open)
    Greetings = {
        Default = {
            "Receiving you loud and clear. What do you need?",
            "Signal is good. Let's trade.",
            "I'm here. You buying or selling?",
            "Make it quick, battery's not eternal.",
            "Radio check... five by five. Go ahead."
        },
        Morning = { -- 05:00 to 10:00
            "Early bird gets the worm, eh?",
            "Sun's barely up and we're already trading.",
            "Good morning. Coffee's brewing, what do you need?",
            "Start the day right with a good deal."
        },
        Evening = { -- 17:00 to 21:00
            "Sun's going down. Stay safe out there.",
            "Getting dark. Make this count.",
            "Evening. Keep your voice down, the freaks come out at night."
        },
        Night = { -- 21:00 to 05:00
            "You should be asleep. What's so urgent?",
            "Quiet night... let's keep it that way.",
            "Trading in the dark? My kind of business.",
            "Whisper if you can. They hear everything."
        },
        Raining = {
            "Hope you're staying dry. It's pouring over here.",
            "Static is bad with this rain... speak up.",
            "Miserable weather. Let's make a deal to cheer up."
        },
        Fog = {
            "Can't see five feet in front of me. You still there?",
            "Thick fog today. Keep your eyes peeled.",
            "Spooky weather for a trade, don't you think?"
        }
    },

    -- IDLE (Triggered if player does nothing for 60s)
    Idle = {
        Default = {
            "Are you still there? All I hear is static.",
            "Hello? Did the signal cut out?",
            "Battery's running low on my end, make a choice.",
            "I haven't got all day.",
            "The airwaves are getting crowded, hurry up.",
            "You checking your pockets or did you fall asleep?"
        }
    },

    -- PLAYER BUYS (Trader reacts to you buying their stuff)
    Buying = {
        Generic = {
            "Sold. Sending it to the drop point.",
            "Good choice. {item} is yours.",
            "Transaction complete. Enjoy.",
            "A pleasure doing business."
        },
        HighValue = { -- Purchases over $200
            "Big spender! I like you.",
            "Now that is a serious purchase.",
            "Wait, you actually have the cash for that? Deal!",
            "Jackpot. Pleasure trading with you."
        },
        HighMarkup = { -- Trader sold item for >120% base price (Rip-off)
            "Heh, supply and demand, friend.",
            "Expensive, I know. But worth it.",
            "You won't find it cheaper... probably.",
            "Pleasure doing business. *Cha-ching*"
        },
        LowMarkup = { -- Trader sold item for <90% base price (Discount)
            "You're robbing me blind here.",
            "I'm practically giving this away.",
            "Take it before I change my mind.",
            "Ugh, fine. At that price, it's a steal."
        },
        SoldOut = {
            "Too slow. That's gone.",
            "Fresh out of stock on that one.",
            "Someone beat you to it.",
            "Dry as a bone. Check back later."
        },
        NoCash = {
            "This isn't a charity. Come back with cash.",
            "You're short on funds, pal.",
            "I don't trade on credit.",
            "Show me the money first."
        }
    },

    -- PLAYER SELLS (Trader reacts to buying your loot)
    Selling = {
        Generic = {
            "I'll take it.",
            "Sure, I can find a buyer for that.",
            "Solid condition. Deal.",
            "Transferring funds now."
        },
        HighValue = { -- Selling item worth >$200
            "Woah, where did you find this?",
            "That's some premium gear. Paying top dollar.",
            "Finally, some good stock!",
            "I've been looking for one of these."
        },
        Trash = { -- Selling very cheap items
            "I guess I can take this junk off your hands.",
            "Not worth much, but I'll pay a few bucks.",
            "Scraps... better than nothing.",
            "Fine, I'll toss you some change for it."
        }
    }
}

-- =============================================================================
-- 2. ARCHETYPE OVERRIDES
-- =============================================================================
DynamicTrading.Dialogue.Archetypes = {}

-- SHERIFF (Lawful, stern)
DynamicTrading.Dialogue.Archetypes["Sheriff"] = {
    Greetings = {
        Default = {
            "This is the Sheriff. State your business.",
            "Keeping the peace is expensive. What do you need?",
            "Identify yourself. You friendly?"
        }
    },
    Idle = {
        Default = {
            "Loitering on the channel is ill-advised.",
            "State your business or clear the frequency.",
            "Make a decision, citizen."
        }
    },
    Buying = {
        HighValue = {
            "Good gear keeps you alive. Smart buy.",
            "Approved. Don't use it on civilians."
        }
    },
    Selling = {
        Illegal = { 
            "I'm confiscating this... for evidence. Here's a finder's fee.",
            "You shouldn't have this. I'll take it off the streets."
        }
    }
}

-- SMUGGLER (Shady, relaxed)
DynamicTrading.Dialogue.Archetypes["Smuggler"] = {
    Greetings = {
        Default = {
            "Keep your voice down. What are you looking for?",
            "I got the stuff if you got the cash.",
            "No names. Just business."
        }
    },
    Idle = {
        Default = {
            "You're taking too long. It's getting hot.",
            "Hurry up, I got other buyers waiting.",
            "Dead air makes me nervous, friend."
        }
    },
    Buying = {
        HighMarkup = {
            "Price of doing business in the apocalypse, friend.",
            "You pay for the quality... and the discretion."
        }
    },
    Selling = {
        HighValue = {
            "Ooh, shiny. I know a guy who wants this.",
            "Hot item? Don't tell me. Just take the cash."
        }
    }
}

-- DOCTOR (Professional, caring)
DynamicTrading.Dialogue.Archetypes["Doctor"] = {
    Greetings = {
        Default = {
            "Medical station listening. Are you injured?",
            "Stay safe out there. Do you need supplies?",
            "Hygiene is priority. Wash your hands."
        }
    },
    Idle = {
        Default = {
            "Triage requires quick decisions.",
            "Do you require assistance or not?",
            "I have other patients waiting on this frequency."
        }
    },
    Buying = {
        Generic = {
            "Here's the prescription.",
            "Use it sparingly.",
            "Hope this helps."
        }
    }
}

-- FARMER (Simple, rustic)
DynamicTrading.Dialogue.Archetypes["Farmer"] = {
    Greetings = {
        Default = {
            "Howdy. Crops are looking good.",
            "Hard work pays off. You buyin' or sellin'?",
            "Ain't much, but it's honest work."
        },
        Rain = {
            "Good for the crops, bad for the radio.",
            "Let it rain, the corn needs it."
        }
    },
    Idle = {
        Default = {
            "Daylight's burnin'.",
            "Cows won't milk themselves while I wait here.",
            "You there? Or did the zombies getcha?"
        }
    }
}