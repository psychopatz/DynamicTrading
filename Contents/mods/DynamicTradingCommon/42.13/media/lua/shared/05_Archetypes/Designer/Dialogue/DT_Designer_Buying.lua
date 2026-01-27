DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Designer"] = DynamicTrading.Dialogue.Archetypes["Designer"] or {}

DynamicTrading.Dialogue.Archetypes["Designer"].Buying = {
    Generic = {
        "A stylish choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will add some soul to your day, {player.firstname}.",
        "I'll pull the {item} from the display. Enjoy.",
        "Quality aesthetics. The {item} is yours for {price}.",
    },
    HighValue = {
        "Strategic design asset right there. {price} for the {item}. A real priority.",
        "Top-shelf quality aesthetics, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Fabrics are scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision design isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these swatches. {price} for the {item}.",
        "Clearing some display space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the house. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next show.",
        "None left in the dressing room."
    },
    NoCash = {
        "You're in the red, {player}. Even designers need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
