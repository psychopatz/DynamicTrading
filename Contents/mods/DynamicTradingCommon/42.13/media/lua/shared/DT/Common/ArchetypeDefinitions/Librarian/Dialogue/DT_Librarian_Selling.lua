require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Librarian", "Selling", {
    EN = {
        Generic = {
            "I can use this {item} for research. Here's {price}.",
            "Intellectual find! {price} sent for the {item}. What else you got, {player.firstname}?",
            "I'll take the {item}. Might be someone's treasure later.",
        },
        HighValue = {
            "Whoa! That's some serious datum! {price} for the {item}. You're a pro.",
            "Legendary find! This {item} is worth its weight in first editions. {price} incoming.",
            "You're a tough negotiator, {player.firstname}. {price} for a {item}? Fine."
        },
        Trash = {
            "This {item} is basically pulp. I'll give you {price}.",
            "Material's a bit weathered... but salvageable. {price} for the {item}."
        }
    }
})
