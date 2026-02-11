require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Foreman", "Selling", {
        EN = {
            Generic = {
                "We can use this {item} on the site. Here's {price}.",
                "Good haul. {price} sent for the {item}. Get back out there, {player.firstname}.",
                "I'll take the {item}. Might come in handy for repairs.",
            },
            HighValue = {
                "Excellent equipment! {price} for the {item}. This is high-grade.",
                "Top-tier find! This {item} is exactly what the site needs. {price} incoming."
            },
            Trash = {
                "This {item} is substandard. I'll give you {price}.",
                "Construction waste... but salvageable. {price} for the {item}."
            },
            HighMarkup = {
                "You're charging premium prices, {player.firstname}! {price} for a {item}? Fine."
            }
        }
    })
end
