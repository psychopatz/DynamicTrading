DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Player = DynamicTrading.Dialogue.Player or {}
DynamicTrading.Dialogue.General = DynamicTrading.Dialogue.General or {}

require "Dialogue/Player/Sell_ask"
require "Dialogue/General/Sell_ask"

-- =============================================================================
-- 1. PLAYER DIALOGUE
-- =============================================================================
-- The Player speaks naturally, proposing deals and confirming actions.
-- Tone: Survivor-to-Survivor. Not a robot.
local playerLines = {

    -- ACTION: Opening the Connection (Handshake) [NEW]
    Intro = {
        "This is {player}. Do you copy?",
        "Radio check. This is {player} calling on this frequency.",
        "Can anyone hear me? This is {player}.",
        "Signal check. {player.firstname} here. Are you open?",
        "Calling any traders. This is {player}, over.",
        "Broadcasting on open channel. {player} requesting trade.",
        "Is this thing working? This is {player}.",
        "Hey, it's {player.firstname}. Pick up if you're there.",
        "This is {player}. Seeking supplies, over."
    },
    
    -- ACTION: Player Buys Item
    -- Context: "I see it, I have the money, give it to me."
    Buy = {
        "I'm sending the {price} credits now. Gimme that {item}.",
        "That {item} looks decent. I'm wiring {price}. Copy?",
        "Alright, {price} sent. Don't lose that {item} before I get it.",
        "I really need that {item}. Transferring {price} now.",
        "I'm good for the {price}. Send the {item} over.",
        "Can you confirm the {price}? Okay, sending it now for the {item}.",
        "Price is a bit steep, but I'm paying {price}. Send the {item}.",
        "Done. {price} credits transferred. Hand over the {item}.",
        "I'm buying the {item}. Check your account for {price}.",
        "Just wired {price}. Pack up the {item} for me.",
        "Hope this {item} works. Sending {price}.",
        "Yeah, I'll take it. {price} inbound for the {item}.",
        "Mark the {item} as sold. {price} is on the way.",
        "I'm grabbing that {item} for {price}. Do you copy?",
        "Here's the {price}. Where can I pick up the {item}?"
    },

    -- ACTION: Player Buys the LAST Item
    -- Context: Urgency.
    BuyLast = {
        "Is that the last {item}? I'm buying it for {price}.",
        "I'll take the last {item} off your hands. {price} sent.",
        "Don't sell that final {item} to anyone else. Here's {price}.",
        "I'm clearing you out. {price} for the rest of the {item}.",
        "Might as well grab the last {item}. Sending {price}.",
        "Just one left? Fine, I'll take the {item} for {price}.",
        "Scraping the barrel here. {price} for the last {item}.",
        "I'll save you the storage space. Buying the last {item} for {price}.",
        "Inventory is getting low, huh? I'm taking that {item} for {price}.",
        "Sold. {price} for the final unit of {item}."
    },
        -- ACTION: Player Attempts to Buy with Insufficient Funds (Haggling) 
    NoCash = {
        "I'm a little short on credits... can you lower the price?",
        "Come on, I'm good for it. Can you put the {item} on my tab?",
        "That price is steep. Any wiggle room for a survivor?",
        "I don't have the cash right now... can you hold it for me?",
        "Credits are tight. Can we work something out for that {item}?",
        "I really need that {item}, but I'm broke. Help me out?",
        "Look, I'll pay you double next time. Just send it now.",
        "Any discount for a loyal customer? I'm short."
    },

    -- ACTION: Player Sells an Item
    -- Context: Proposing a deal. "I have X, I want Y. Yes or No?"
    Sell = {
        "I found a {item}. Would you take it for {price}?",
        "Got a spare {item} here. Can you do {price} for it?",
        "I'm looking to sell a {item}. asking {price}. You interested?",
        "Hey, I have a {item} in good condition. worth {price} to you?",
        "Found a {item}. I think it's worth {price}. What do you say?",
        "I need the cash. I'll trade this {item} for {price}. Deal?",
        "Any demand for a {item}? I'm letting it go for {price}.",
        "I'll trade you my {item} if you send me {price}. Copy?",
        "Clearing out my stash. You want this {item} for {price}?",
        "It's a little dusty, but this {item} works. {price} fair?",
        "I'm offering a {item}. Market value is {price}. You in?",
        "Take this {item} off my hands for {price}?",
        "Just looted a {item}. How about {price} for it?",
        "I've got a {item} taking up space. Asking {price}. Over.",
        "Quick sale: {item} for {price}. Do we have a deal?",
        }
}
for k,v in pairs(playerLines) do DynamicTrading.Dialogue.Player[k] = v end

-- =============================================================================
-- 2. GENERAL TRADER RESPONSES
-- =============================================================================
local generalLines = {

    -- GREETINGS
    Greetings = {
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
    },

    -- IDLE
    Idle = {
        Default = {
            "{player.firstname}? You still there? All I hear is static.",
            "Hello? Did the signal cut out, {player}?",
            "Hey, battery's running low. Make a choice, {player.firstname}.",
            "I haven't got all day, {player.surname}.",
            "The airwaves are getting crowded, hurry up, {player}.",
            "You checking your pockets or did you fall asleep, {player.firstname}?",
            "Cat got your tongue, {player}? Over.",
            "I'm gonna switch channels if you don't say something.",
            "Time is money, friend. Speak up.",
            "Copy? You still on the line, {player.firstname}?"
        }
    },

    -- TRADER RESPONSE TO BUYING (Player says: "Sending money")
    Buying = {
        Generic = {
            "Yeah, I see the {price}. The {item} is yours.",
            "Alright, transfer of {price} verified. Sending the {item}.",
            "Received {price}. Pleasure doing business, {player.firstname}.",
            "Done. Enjoy the {item}.",
            "Okay, confirmed {price}. Try not to break the {item}.",
            "Money's in the account. Good luck out there, {player.firstname}.",
            "The {item} is in the drop box. Thanks for the {price}.",
            "Got it. {item} is on its way.",
            "Good choice. That {item} is handy. Payment cleared.",
            "Signal confirmed. {price} credits deducted.",
            "Roger that. The {item} is yours.",
            "Solid copy, {player.firstname}. Enjoy the gear.",
            "I see the transfer. Thanks.",
            "Fair trade. {price} for a {item}. Done.",
            "Okay, locked the {item} in for you.",
            "Wiring the {item} to your location. {price} received.",
            "Safe travels, {player.firstname}. {item} provided.",
            "Standard transaction. Confirmed.",
            "I appreciate the business, {player}. Take the {item}.",
            "Deal verified. Systems green."
        },
        LastStock = {
            "That was the last {item}. Sold for {price}.",
            "Lucky you, {player.firstname}. You got the final piece.",
            "Sold. Now I gotta go scavenge for more {item}.",
            "Payment of {price} received. I'm officially out of those.",
            "You cleaned me out. Deal confirmed.",
            "That was the last unit. Good timing, {player.firstname}.",
            "Stock's gone now. You got the last {item} for {price}.",
            "Scraping the bottom of the barrel, but the {item} is yours.",
            "Inventory updated: 0 remaining. Thanks for the {price}.",
            "You beat the rush, {player}. That was the last one.",
            "I'm closing the listing now. It's yours.",
            "Final one goes to you, {player.firstname}. Enjoy.",
            "Sold out. You got lucky."
        },
        NoCash = {
            "I'm checking the wire... {player.firstname}, it bounced. You don't have {price}.",
            "Card declined. Check your wallet, {player}. You're short.",
            "I don't see the {price} credits here. Try again when you're liquid.",
            "This isn't a charity, {player.firstname}. Come back when you have {price}.",
            "Signal is clear, but your funds aren't. You need {price}.",
            "Not enough cash. Stop wasting my time, {player.surname}.",
            "You're short, pal. Can't do it for less than {price}.",
            "No credit, no trade. That's the rule.",
            "Transaction failed. You're broke, {player.firstname}.",
            "Come back later when you have the {price}.",
            "I can't give you a {item} for free. Check your balance.",
            "Check your pockets, {player}. You're short on funds."
        }
    },

    -- TRADER RESPONSE TO SELLING (Player says: "Will you buy X for Y?")
    Selling = {
        Generic = {
            "Yeah, I see the {item}. I'll take it for {price}.",
            "Sure, I can find a buyer for a {item}. Sending {price}.",
            "Solid condition. Deal at {price}.",
            "Transferring {price} credits to your account now.",
            "Received. Payment is on the way for the {item}.",
            "Not bad. I'll add the {item} to my stock. {price} sent.",
            "Scanning it... looks okay. Bought for {price}.",
            "I can resell this {item}. {price} wired to you, {player.firstname}.",
            "Roger. Adding it to my inventory. Check your balance.",
            "Standard price applied. {price} sent.",
            "Accepted. Pleasure doing business, {player.firstname}.",
            "Fair enough. {price} credits sent.",
            "I'll take the {item} off your hands. Done.",
            "Looks useful. Sending {price}.",
            "Copy that. {item} received. Payment sent.",
            "Buying it now. Thanks, {player.firstname}.",
            "Good find. Paying standard rate of {price}.",
            "I'm always looking for those. Here's the {price}.",
            "Space allocated. {price} transferred.",
            "We have a deal. Check your balance for {price}.",
            "Credits inbound. Thanks for the {item}.",
            "Sold. {price} has been added."
        },
        HighMarkup = { 
            -- Player is asking a high price, Trader hesitates but agrees
            "Oof... {price} is steep for a {item}, but fine. Deal.",
            "You're robbing me blind asking {price}, {player.firstname}... but I'll take it.",
            "Ugh. Fine. I'll pay {price}, but bring me something better next time.",
            "{price}? You drive a hard bargain, {player}. Deal.",
            "I shouldn't pay {price} for a {item}, but I'm desperate. Done.",
            "High price... but good condition. I'll wire the {price}.",
            "Alright, {player.firstname}, you win. {price} for the {item}."
        },
        Trash = { 
            -- Player offering junk
            "I guess I can take this junk off your hands for {price}.",
            "Not worth much, but I'll pay {price} bucks.",
            "Scraps... better than nothing. Here's {price}.",
            "Fine, I'll toss you {price} change for the {item}.",
            "It's barely holding together, {player}. {price} is my best offer.",
            "This {item} is garbage, but I'll recycle it for {price}.",
            "I'm doing you a favor taking this trash for {price}."
        }
    }
}
for k,v in pairs(generalLines) do DynamicTrading.Dialogue.General[k] = v end

-- =============================================================================
-- 3. ARCHETYPE OVERRIDES
-- =============================================================================
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}

-- SHERIFF (Uses Surname, authoritative)
DynamicTrading.Dialogue.Archetypes["Sheriff"] = {
    Greetings = {
        Default = {
            "This is the Sheriff. Behave yourself, {player.surname}.",
            "Keeping the peace is hard work. What do you need, {player}?",
            "Identify yourself. Citizen {player.surname}, you friendly?",
            "Police band is for official business, but go ahead.",
            "I'm listening, {player.surname}, but don't waste my time."
        }
    },
    Buying = {
        Generic = {
            "Approved. Use the {item} responsibly.",
            "Logged in the precinct database. Take it.",
            "Just don't cause trouble with this {item}, okay {player.surname}?"
        },
        NoCash = {
            "Citizen {player.surname}, you have insufficient funds for {price}.",
            "I can't authorize this transfer. You're short {price}."
        }
    },
    Selling = {
        Generic = {
            "We can use this {item} at the station. {price} paid.",
            "Submitting this to evidence. Here's your cut: {price}.",
            "Good work, Citizen {player.surname}. {price} transferred."
        },
        HighMarkup = {
            "That's above budget, but we need the {item}. {price} authorized.",
            "Extortionate, but necessary for public safety. {price} sent."
        }
    }
}

-- SMUGGLER (Uses Firstname, casual, shady)
DynamicTrading.Dialogue.Archetypes["Smuggler"] = {
    Greetings = {
        Default = {
            "Keep your voice down, {player.firstname}. What are you looking for?",
            "I got the stuff if you got the cash. {player}, right?",
            "No names. Just business. You want something?",
            "This line isn't secure. Talk fast, {player.firstname}.",
            "You didn't hear this frequency from me. Go."
        }
    },
    Buying = {
        Generic = {
            "Clean transfer of {price}. Pleasure.",
            "Don't ask where I got the {item}. It's yours now.",
            "Credits washed and received. Enjoy the {item}.",
            "Drop point established. Go get it.",
            "It fell off a truck. You want the {item} or not?"
        },
        NoCash = {
            "You trying to scam me, {player.firstname}? You don't have {price}.",
            "Empty pockets? Get off my channel."
        }
    },
    Selling = {
        HighMarkup = {
            "Man, {price} is highway robbery... I respect it. Deal.",
            "You learned from the best, {player.firstname}. {price} sent.",
            "Fine. Take the {price} and don't tell anyone."
        }
    }
}

-- DOCTOR (Uses Firstname, caring, concerned)
DynamicTrading.Dialogue.Archetypes["Doctor"] = {
    Greetings = {
        Default = {
            "Clinic is open. {player.firstname}, are you injured?",
            "Stay safe out there. Do you need meds, {player}?",
            "Hygiene is priority. Wash your hands, {player.firstname}.",
            "Triage center here. Is this an emergency?",
            "Pulse check. You still alive out there, {player.firstname}?"
        }
    },
    Buying = {
        Generic = {
            "Here's the prescription: {item}. Use it wisely.",
            "Payment of {price} received. Hope this helps.",
            "Dispatching supplies now. Stay healthy, {player.firstname}.",
            "Sterilize the {item} before use. Confirmed.",
            "Take two of these and call me in the morning."
        },
        NoCash = {
            "I can't give out {item} without payment, I need to buy supplies too. You need {price}.",
            "Sorry, {player.firstname}, your card declined."
        }
    },
    Selling = {
        Generic = {
            "This {item} will help the patients. Thank you. {price} sent.",
            "I can sterilize this {item}. Credits sent.",
            "Medical supplies are always needed. Good find, {player.firstname}."
        },
        HighMarkup = {
            "That's a lot of money ({price}) for a {item}... but lives are at stake. Deal.",
            "I'll pay {price}, just make sure it's clean."
        }
    }
}

-- FARMER (Uses 'Partner' or Firstname, rustic)
DynamicTrading.Dialogue.Archetypes["Farmer"] = {
    Greetings = {
        Default = {
            "Howdy, {player.firstname}. Crops are looking good.",
            "Hard work pays off. You buyin' or sellin'?",
            "Ain't much, but it's honest work.",
            "Barn's open. What do you need, partner?",
            "Just finished the harvest. Got plenty of stock."
        }
    },
    Buying = {
        Generic = {
            "Much obliged for the {price}. I'll pack the {item} up for ya.",
            "Got the payment. Thanks, {player.firstname}.",
            "Fresh from the stockpile. Enjoy the {item}.",
            "Y'all come back now, ya hear?",
            "I'll load the {item} onto the truck. It's yours."
        }
    },
    Selling = {
        HighMarkup = {
            "Whew, {price} is a pretty penny for a {item}. I reckon I need it though.",
            "That's city prices, {player.firstname}! But alright, {price} sent."
        }
    }
}

-- GUNRUNNER (Uses 'Player' or no name, aggressive)
DynamicTrading.Dialogue.Archetypes["Gunrunner"] = {
    Greetings = {
        Default = {
            "Lock and load, {player}. What do you need?",
            "Ammo is life. Do you have enough, {player}?",
            "Stay strapped or die. Talk to me.",
            "The world's ending, buy a gun.",
            "Caliber check. What are you firing, {player}?"
        }
    },
    Buying = {
        Generic = {
            "Click-clack. You're ready for war with this {item}.",
            "Good iron. Keep it clean.",
            "Sending the package. Point it away from me.",
            "Payment of {price} confirmed. Happy hunting, {player}."
        },
        NoCash = {
            "Bullets ain't free, {player}. You need {price}.",
            "No cash, no bang. Get lost."
        }
    },
    Selling = {
        Generic = {
            "I can strip this {item} for parts. Deal at {price}.",
            "Looks like it shoots straight. I'll buy the {item} for {price}.",
            "Never have enough brass. Sending {price} credits."
        },
        HighMarkup = {
            "You're bleeding me dry at {price}... but I need the firepower. Done.",
            "Fine. {price}. But this {item} better not jam."
        }
    }
}