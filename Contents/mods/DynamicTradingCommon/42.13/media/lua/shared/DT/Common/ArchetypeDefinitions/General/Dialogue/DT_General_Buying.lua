require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("General", "Buying", {
        EN = {
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
            HighValue = {
                "Strategic asset right there. {price} for the {item}. A real priority.",
                "Top-shelf quality supplies, {player.firstname}. Worth every bit of {price}.",
                "A major acquisition. {price} received for the {item}.",
                "Heavy-hitting gear. Confirmed {price} for the {item}."
            },
            HighMarkup = {
                "Supply chain is tight. {price} for the {item}. Best price I can offer.",
                "Logistics for this {item} are expensive. {price} confirmed.",
                "High demand area. {price} for the {item}."
            },
            LowMarkup = {
                "Surplus stock today. {price} for the {item}.",
                "Got a good deal on these. {price} for the {item}.",
                "Liquidating inventory. {item} for {price}."
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
        }
    })
end
