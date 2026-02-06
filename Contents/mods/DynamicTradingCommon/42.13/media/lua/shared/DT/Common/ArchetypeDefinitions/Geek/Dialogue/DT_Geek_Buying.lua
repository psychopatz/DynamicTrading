DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Geek"] = DynamicTrading.Dialogue.Archetypes["Geek"] or {}

DynamicTrading.Dialogue.Archetypes["Geek"].Buying = {
    Generic = {
        "A techy choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} is fully optimized and ready, {player.firstname}.",
        "I'll pull the {item} from the server room. Enjoy.",
        "Quality hardware. The {item} is yours for {price}.",
    },
    HighValue = {
        "Strategic code asset right there. {price} for the {item}. A real priority.",
        "Top-shelf quality tech, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Chips are scarce these days. {price} for the {item}. Take it or leave it.",
        "Expert debugging isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these cables. {price} for the {item}.",
        "Clearing some server space. {item} for {price}."
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
        "You're in the red, {player}. Even geeks need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
