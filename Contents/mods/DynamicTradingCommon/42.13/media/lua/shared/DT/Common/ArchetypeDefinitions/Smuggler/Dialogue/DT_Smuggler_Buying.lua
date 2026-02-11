require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Smuggler", "Buying", {
        EN = {
            Generic = {
                "Clean transfer of {price}. Pleasure.",
                "Don't ask where I got the {item}. It's yours now.",
                "Credits washed and received. Enjoy the {item}.",
                "Drop point established. Go get it.",
                "It fell off a truck. You want the {item} or not?"
            },
            HighValue = {
                "Premium black-market gear. {price} for the {item}.",
                "Top shelf stuff, {player}. Worth every credit of {price}."
            },
            HighMarkup = {
                "Dangerous route to get this. {price} for the {item}. Take it or leave it.",
                "The heat is on. {price} for the {item}."
            },
            LowMarkup = {
                "I need to move this fast. {price} for the {item}.",
                "Hot item, low price. {item} for {price}."
            },
            LastStock = {
                "That's my last one. Better hide it well.",
                "Stock's dry. Only this {item} left."
            },
            SoldOut = {
                "Supply line's cut. No {item}."
            },
            NoCash = {
                "You trying to scam me, {player.firstname}? You don't have {price}.",
                "Empty pockets? Get off my channel."
            }
        }
    })
end
