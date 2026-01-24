DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Pharmacist"] = DynamicTrading.Dialogue.Archetypes["Pharmacist"] or {}

DynamicTrading.Dialogue.Archetypes["Pharmacist"].Buying = {
    Generic = {
        "A clinical choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will serve you well in the clinic, {player.firstname}.",
        "I'll pull the {item} from the rack. Enjoy.",
        "Quality medicines. The {item} is yours for {price}.",
    },
    HighValue = {
        "Strategic health asset right there. {price} for the {item}. A real priority.",
        "Top-shelf quality medicines, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Vaccines are scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision pharmacology isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these aspirin. {price} for the {item}.",
        "Clearing some drug space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the clinic. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next semester.",
        "None left in the archives."
    },
    NoCash = {
        "You're in the red, {player}. Even pharmacists need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
