DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Hunter"] = DynamicTrading.Dialogue.Archetypes["Hunter"] or {}

DynamicTrading.Dialogue.Archetypes["Hunter"].Buying = {
    Generic = {
        "A stealthy choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will help you track your prey, {player.firstname}.",
        "I'll pull the {item} from the hideout. Enjoy.",
        "Quality hunting gear. The {item} is yours for {price}.",
    },
    HighValue = {
        "Prize-winning hide right there. {price} for the {item}. A real trophy.",
        "Top-shelf quality, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Pelts are scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision tracking isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these traps. {price} for the {item}.",
        "Clearing some cache space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the hideout. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next season.",
        "Inventory's zeroed out for {item}."
    },
    NoCash = {
        "You're in the red, {player}. Even hunters need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
