DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Angler"] = DynamicTrading.Dialogue.Archetypes["Angler"] or {}

DynamicTrading.Dialogue.Archetypes["Angler"].Buying = {
    Generic = {
        "A great catch! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will serve you well on the water, {player.firstname}.",
        "I'll pull the {item} from the tackle box. Enjoy.",
        "Quality gear. The {item} is yours for {price}.",
    },
    HighValue = {
        "Prize-winning gear right there. {price} for the {item}. A real trophy.",
        "Top-shelf quality, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Lures are scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision engineering isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these sinkers. {price} for the {item}.",
        "Clearing some tackle space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the box. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next season.",
        "Inventory's zeroed out for {item}."
    },
    NoCash = {
        "You're in the red, {player}. Even anglers need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
