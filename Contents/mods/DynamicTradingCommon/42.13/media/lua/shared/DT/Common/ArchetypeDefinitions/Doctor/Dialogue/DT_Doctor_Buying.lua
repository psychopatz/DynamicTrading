require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Doctor", "Buying", {
        EN = {
            Generic = {
                "Here's the prescription: {item}. Use it wisely.",
                "Payment of {price} received. Hope this helps.",
                "Dispatching supplies now. Stay healthy, {player.firstname}.",
                "Sterilize the {item} before use. Confirmed.",
                "Take two of these and call me in the morning."
            },
            HighValue = {
                "Life-saving equipment right here. {price} for the {item}.",
                "Top-tier medical grade, {player.firstname}. Worth every bit of {price}."
            },
            HighMarkup = {
                "Meds are scarce these days. {price} for the {item}. Take it or leave it.",
                "Professional care isn't cheap. {price} for the {item}."
            },
            LowMarkup = {
                "Found a surplus in the cabinet. {price} for the {item}.",
                "Clearing out expiring stock. {item} for {price}."
            },
            LastStock = {
                "That's the last dose I have. Better make it count.",
                "Stock's critical. Only this {item} left."
            },
            SoldOut = {
                "Out of stock for {item}. Try the pharmacy.",
                "Inventory's zeroed out for {item}."
            },
            NoCash = {
                "I can't give out {item} without payment, I need to buy supplies too. You need {price}.",
                "Sorry, {player.firstname}, your card declined."
            }
        }
    })
end
