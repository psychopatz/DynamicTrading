require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Farmer", "Buying", {
        EN = {
            Generic = {
                "Much obliged for the {price}. I'll pack the {item} up for ya.",
                "Got the payment. Thanks, {player.firstname}.",
                "Fresh from the stockpile. Enjoy the {item}.",
                "Y'all come back now, ya hear?",
                "I'll load the {item} onto the truck. It's yours."
            },
            HighValue = {
                "Top-grade produce right here. {price} for the {item}.",
                "Best in the county, {player}. Worth every bit of {price}."
            },
            HighMarkup = {
                "Seed costs are up this season. {price} for the {item}.",
                "It's a tough year for {item}. {price} is the best I can do."
            },
            LowMarkup = {
                "Bumper crop! {price} for the {item}.",
                "Clearing out the barn. {item} for {price}."
            },
            LastStock = {
                "That's the last of the harvest. Better cherish it.",
                "Barn's empty. Only this {item} left."
            },
            NoCash = {
                "Y'all short on change, {player}. I need {price} for this.",
                "No credits, no crops. Get more cash."
            }
        }
    })
end
