DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Hiker"] = DynamicTrading.Dialogue.Archetypes["Hiker"] or {}

DynamicTrading.Dialogue.Archetypes["Hiker"].Buying = {
    Generic = {
        "A wanderer's choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will serve you well on the trail, {player.firstname}.",
        "I'll pull the {item} from the pack. Enjoy.",
        "Quality gear. The {item} is yours for {price}.",
    },
    HighValue = {
        "Summit-grade asset right there. {price} for the {item}. A real explorer's choice.",
        "Top-shelf quality gear, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Jerky is scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision navigation isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these trail bars. {price} for the {item}.",
        "Clearing some pack space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the house. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next semester.",
        "None left in the archives."
    },
    NoCash = {
        "You're in the red, {player}. Even hikers need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
