require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Gunrunner", "Buying", {
        EN = {
            Generic = {
                "Click-clack. You're ready for war with this {item}.",
                "Good iron. Keep it clean.",
                "Sending the package. Point it away from me.",
                "Payment of {price} confirmed. Happy hunting, {player}."
            },
            HighValue = {
                "Military grade kit. {price} for the {item}. Don't miss.",
                "Top-tier firepower, {player}. Worth every bit of {price}."
            },
            HighMarkup = {
                "Smuggling these past the checkpoints is getting harder. {price} for the {item}.",
                "Guns are in high demand. {price} is the market rate."
            },
            LowMarkup = {
                "Old stock from a raid. {price} for the {item}.",
                "Clearing out the surplus. {item} for {price}."
            },
            LastStock = {
                "That's my last piece of iron in that caliber. Better cherish it.",
                "Stock's dry. Only this {item} left."
            },
            SoldOut = {
                "No more {item} in the armory. Check back later."
            },
            NoCash = {
                "Bullets ain't free, {player}. You need {price}.",
                "No cash, no bang. Get lost."
            }
        }
    })
end
