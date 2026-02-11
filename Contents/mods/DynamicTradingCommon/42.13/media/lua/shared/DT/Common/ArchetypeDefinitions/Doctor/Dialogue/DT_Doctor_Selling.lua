require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then
    DynamicTrading.RegisterDialogue("Doctor", "Selling", {
        EN = {
            Generic = {
                "This {item} will help the patients. Thank you. {price} sent.",
                "I can sterilize this {item}. Credits sent.",
                "Medical supplies are always needed. Good find, {player.firstname}."
            },
            HighValue = {
                "Incredible find! This {item} could save dozens of lives. {price} transferred.",
                "Rare medical equipment! I'll pay top dollar: {price}."
            },
            Trash = {
                "This {item} is practically bio-hazard waste. {price}, take it or leave it.",
                "Not sure it's sterile enough, but I'll give {price}."
            },
            HighMarkup = {
                "That's a lot of money ({price}) for a {item}... but lives are at stake. Deal.",
                "I'll pay {price}, just make sure it's clean."
            }
        }
    })
end
