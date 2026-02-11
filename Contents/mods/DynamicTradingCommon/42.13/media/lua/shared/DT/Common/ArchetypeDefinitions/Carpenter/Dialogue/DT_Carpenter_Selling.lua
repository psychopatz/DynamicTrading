require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Carpenter", "Selling", {
        EN = {
            Generic = {
                "I can use this {item} for the project. Here's {price}.",
                "Crafty find! {price} sent for the {item}. What else you got, {player.firstname}?",
                "I'll take the {item}. Might be someone's joinery later.",
            },
            HighValue = {
                "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
                "Legendary find! This {item} is worth its weight in mahogany. {price} incoming."
            },
            Trash = {
                "This {item} is basically sawdust. I'll give you {price}.",
                "Material's a bit splintered... but salvageable. {price} for the {item}."
            },
            HighMarkup = {
                "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
            }
        }
    })
end
