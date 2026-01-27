DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Survivalist"] = DynamicTrading.Dialogue.Archetypes["Survivalist"] or {}

DynamicTrading.Dialogue.Archetypes["Survivalist"].Buying = {
    Generic = {
        "It's yours. Use the {item} wisely. {price} received.",
        "Trade confirmed. The {item} is in the cache. Good luck, {player.firstname}.",
        "I'll pass the {item} over. Keep it clean.",
        "Found this in the woods. {item} for {price}. Deal.",
    },
    HighValue = {
        "This {item} is rare. Treat it with respect. {price} is a fair price.",
        "Quality gear like this {item} saves lives. {price} received."
    },
    HighMarkup = {
        "Supply and demand, {player}. {price} for the {item}. Take it or leave it.",
        "Hard to find these lately. {price} for the {item}."
    },
    LowMarkup = {
        "Got extra. Here, take the {item} for {price}.",
        "Priced to move. Enjoy the {item} for {price}."
    },
    LastStock = {
        "That's the last one I'm willing to part with. Take care of the {item}.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Come back in a few days.",
        "None left. Scavenged the last {item} already."
    },
    NoCash = {
        "You're broke, {player}. In the woods, that's a death sentence. Need more than {price}.",
        "No money, no gear. Get more cash for the {item}."
    }
}
