DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Bartender"] = DynamicTrading.Dialogue.Archetypes["Bartender"] or {}

DynamicTrading.Dialogue.Archetypes["Bartender"].Buying = {
    Generic = {
        "A premium choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will serve you well on the street, {player.firstname}.",
        "I'll pull the {item} from the back room. Enjoy.",
        "Quality stock. The {item} is yours for {price}.",
    },
    HighValue = {
        "Top-shelf gear right there. {price} for the {item}. A real trophy.",
        "Top-shelf quality, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Liquor is scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision distilling isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these coasters. {price} for the {item}.",
        "Clearing some bar space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the house. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next season.",
        "Inventory's zeroed out for {item}."
    },
    NoCash = {
        "You're in the red, {player}. Even bartenders need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
