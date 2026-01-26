DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Athlete"] = DynamicTrading.Dialogue.Archetypes["Athlete"] or {}

DynamicTrading.Dialogue.Archetypes["Athlete"].Buying = {
    Generic = {
        "A strong choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will boost your performance, {player.firstname}.",
        "I'll pull the {item} from the training room. Enjoy.",
        "Quality gear. The {item} is yours for {price}.",
    },
    HighValue = {
        "Elite training asset right there. {price} for the {item}. A real champion's choice.",
        "Top-shelf quality supplements, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Supplements are scarce these days. {price} for the {item}. Take it or leave it.",
        "Expert coaching isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these bars. {price} for the {item}.",
        "Clearing some training space. {item} for {price}."
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
        "You're in the red, {player}. Even athletes need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
