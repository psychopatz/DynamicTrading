require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Sheriff", "Buying", {
        EN = {
            Generic = {
                "Approved. Use the {item} responsibly.",
                "Logged in the precinct database. Take it.",
                "Just don't cause trouble with this {item}, okay {player.surname}?"
            },
            HighValue = {
                "High-priority ordinance right here. {price} for the {item}.",
                "Law and order gear, {player}. Worth every bit of {price}."
            },
            HighMarkup = {
                "Budget cuts are hitting us hard. {price} for the {item}.",
                "Escalation of costs. {price} for the {item}."
            },
            LowMarkup = {
                "Civil asset forfeiture surplus. {price} for the {item}.",
                "Community outreach discount. {item} for {price}."
            },
            LastStock = {
                "That's the last one in the armory. Keep it safe.",
                "Stock's dry. Only this {item} left."
            },
            SoldOut = {
                "No more {item} in evidence. Check back later."
            },
            NoCash = {
                "Citizen {player.surname}, you have insufficient funds for {price}.",
                "I can't authorize this transfer. You're short {price}."
            }
        }
    })
end
