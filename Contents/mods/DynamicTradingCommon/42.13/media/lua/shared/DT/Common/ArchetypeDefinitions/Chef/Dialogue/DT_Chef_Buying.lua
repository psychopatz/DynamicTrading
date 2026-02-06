DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Chef"] = DynamicTrading.Dialogue.Archetypes["Chef"] or {}

DynamicTrading.Dialogue.Archetypes["Chef"].Buying = {
    Generic = {
        "A gourmet choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} is fresh and ready, {player.firstname}.",
        "I'll pull the {item} from the pantry. Enjoy.",
        "Quality ingredients. The {item} is yours for {price}.",
    },
    HighValue = {
        "Exquisite stuff right there. {price} for the {item}. A rare delicacy.",
        "Top-shelf quality, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Spices are scarce these days. {price} for the {item}. Take it or leave it.",
        "Gourmet prep isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these seasonings. {price} for the {item}.",
        "Clearing some pantry space. {item} for {price}."
    },
    LastStock = {
        "That's the last portion in the kitchen. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next week.",
        "Inventory's zeroed out for {item}."
    },
    NoCash = {
        "You're in the red, {player}. Even chefs need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
