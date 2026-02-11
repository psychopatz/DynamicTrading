require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("General", "Selling", {
        EN = {
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
            HighValue = {
                "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
                "Legendary find! This {item} is worth its weight in first editions. {price} incoming.",
                "High-end equipment right here. Confirmed {price} for the {item}.",
                "Impressive find, {player}. I'll pay top dollar: {price}."
            },
            HighMarkup = {
                "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine.",
                "Draining my budget, but I need that {item}. {price} sent.",
                "I'll pay the premium. {price} for the {item}."
            },
            Trash = {
                "I guess I can take this junk off your hands for {price}.",
                "Not worth much, but I'll pay {price} bucks.",
                "Scraps... better than nothing. Here's {price}.",
                "Fine, I'll toss you {price} change for the {item}.",
                "It's barely holding together, {player}. {price} is my best offer.",
                "This {item} is garbage, but I'll recycle it for {price}.",
                "I'm doing you a favor taking this trash for {price}."
            },
            NoCash = {
                "Man, I'm dry. I'd take it, but the till is empty.",
                "System says I'm over budget for today. Can't buy that {item} right now.",
                "I'all out of credits, {player.firstname}. Come back when I've moved some stock.",
                "Radio network's tapped me out. No cash left for a {item}.",
                "I'm running on empty here. I can't afford to pay you what that's worth."
            }
        }
    })
end
