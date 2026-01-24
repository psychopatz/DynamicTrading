DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Butcher"] = DynamicTrading.Dialogue.Archetypes["Butcher"] or {}

DynamicTrading.Dialogue.Archetypes["Butcher"].Buying = {
    Generic = {
        "Sold. I'll wrap the {item} in some butcher paper for ya. {price} received.",
        "Transaction complete. Enjoy the {item}, {player.firstname}.",
        "The {item} is yours. Keep it away from the flies.",
        "Good choice. {price} for the {item}. Pleasure doing business.",
    },
    HighValue = {
        "Whoa, {price} for a {item}? You must be living large, {player.firstname}.",
        "Prime choice! This {item} is worth every cent of that {price}."
    },
    HighMarkup = {
        "Inflation's a bitch, ain't it? {price} for the {item}. Take it or leave it.",
        "Pricey, I know. But supply is thin. {price} for the {item}."
    },
    LowMarkup = {
        "Giving you the 'friend of the shop' discount. {price} for the {item}.",
        "Priced to move. Take the {item} for {price}."
    },
    LastStock = {
        "That's the last of the {item}. Don't expect more soon.",
        "Scraped the bottom for ya. Last {item} is yours."
    },
    SoldOut = {
        "Out of luck, {player}. {item} is off the hooks.",
        "Fresh out. Check back later for {item}."
    },
    NoCash = {
        "You're short, {player}. No money, no meat. Come back with more than {price}.",
        "I don't do credit. You need more than that to get the {item}."
    }
}
