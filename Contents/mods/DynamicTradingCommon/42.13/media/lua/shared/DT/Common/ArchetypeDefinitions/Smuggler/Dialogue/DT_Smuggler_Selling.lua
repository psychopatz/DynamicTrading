require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Smuggler", "Selling", {
        EN = {
            Generic = {
                "Black market rate, but it's yours. {price} transferred.",
                "I'll take the {item}. No questions asked.",
                "Goods received. Here's your cut: {price}."
            },
            HighValue = {
                "Nice find. This {item} is worth its weight in cigarettes. {price} incoming.",
                "Rare stuff. I'll pay {price} for it."
            },
            HighMarkup = {
                "Man, {price} is highway robbery... I respect it. Deal.",
                "You learned from the best, {player.firstname}. {price} sent.",
                "Fine. Take the {price} and don't tell anyone."
            },
            Trash = {
                "This {item} is basically garbage. {price} in credits, take it or leave it.",
                "Hot garbage. I'll give you {price}."
            }
        }
    })
end
