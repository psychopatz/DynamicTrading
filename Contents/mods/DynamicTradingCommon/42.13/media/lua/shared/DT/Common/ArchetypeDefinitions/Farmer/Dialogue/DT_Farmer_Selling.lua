require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Farmer", "Selling", {
        EN = {
            Generic = {
                "I'll take that {item}. Might be useful for the farm. Here's {price}.",
                "Looks like good feed material. {price} for the {item}.",
                "Always need more gear. {price} sent for the {item}."
            },
            HighValue = {
                "Whew, {price} is a pretty penny for a {item}. I reckon I need it though.",
                "That's city prices, {player.firstname}! But alright, {price} sent.",
                "That's some fine machinery. I'll pay {price} for the {item}."
            },
            Trash = {
                "This {item} is basically manure. I'll give you {price}.",
                "Scraps... but everything has a use. {price} for the {item}."
            },
            HighMarkup = {
                "You're driving a hard bargain, {player.firstname}. {price} for a {item}? Alright."
            }
        }
    })
end
