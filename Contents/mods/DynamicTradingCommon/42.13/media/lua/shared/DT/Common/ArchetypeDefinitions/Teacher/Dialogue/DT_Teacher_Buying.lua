DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Teacher"] = DynamicTrading.Dialogue.Archetypes["Teacher"] or {}

DynamicTrading.Dialogue.Archetypes["Teacher"].Buying = {
    Generic = {
        "A scholarly choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will foster growth and learning, {player.firstname}.",
        "I'll pull the {item} from the curriculum. Enjoy.",
        "Precision in instruction. The {item} is yours for {price}.",
    },
    HighValue = {
        "Advanced textbook right there. {price} for the {item}. A cornerstone of the study.",
        "Top-shelf quality education, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Supplies are scarce this semester. {price} for the {item}. Take it or leave it.",
        "Expert tutoring isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these handouts. {price} for the {item}.",
        "Clearing some classroom space. {item} for {price}."
    },
    LastStock = {
        "That's the last copy in the library. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next semester.",
        "None left in the archives."
    },
    NoCash = {
        "You're in the red, {player}. even teachers need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
