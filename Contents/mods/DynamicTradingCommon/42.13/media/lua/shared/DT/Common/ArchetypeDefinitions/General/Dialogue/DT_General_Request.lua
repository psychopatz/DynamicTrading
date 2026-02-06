DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.General = DynamicTrading.Dialogue.General or {}

DynamicTrading.Dialogue.General.Request = {
    -- HUB MENU
    HubIntro = {
        "{player.firstname}, good to hear you. What's the play?",
        "Reading you loud and clear. How can I help?",
        "This is {npc.name}. Go ahead, {player}.",
        "Channels are open. What do you need today?"
    },

    -- REQUEST TRADER FLOW
    Start = {
        "I know a few people. But the network's busy and information isn't free. Who are you looking for?",
        "You want a new contact? I can patch you through, but it'll cost you. Who do you need?",
        "I can scan the frequencies for you. Tell me what kind of specialist you're after."
    },
    
    Success = {
        "Got 'em. Sending encryption keys now. Treat them well, {player}.",
        "Patching you through. Signal is strong. Good luck.",
        "Found one matching that description. Coordinates validated. Pleasure doing business."
    },
    
    Scammed = {
        "Sent the funds... endless static. Looks like they ghosted us. Sorry, {player}. No refunds on dead signals.",
        "I tried, but the signal died halfway. Money's gone to the relay. Nothing I can do.",
        "Damn. They took the credit and went dark. Risk of the trade, my friend."
    },
    
    NoFunds = {
        "You don't have the credits for that scan. Bandwidth costs money.",
        "Come back when you're liquid. I run a business, not a charity relay.",
        "Insufficient funds, {player.firstname}. I can't work for free."
    }
}
