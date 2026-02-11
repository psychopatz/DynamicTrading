require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Janitor", "Selling", {
    EN = {
        Generic = {
            "I can use this {item} for the cleaning. Here's {price}.",
            "Tidy find! {price} sent for the {item}. What else you got, {player.firstname}?",
            "I'll take the {item}. Might be someone's supply later.",
        },
        HighValue = {
            "Whoa! That's some serious gear! {price} for the {item}. You're a pro.",
            "Legendary find! This {item} is worth its weight in floor-wax. {price} incoming.",
            "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
        },
        Trash = {
            "This {item} is basically floor-waste. I'll give you {price}.",
            "Material's a bit dusty... but salvageable. {price} for the {item}."
        }
    }
})
