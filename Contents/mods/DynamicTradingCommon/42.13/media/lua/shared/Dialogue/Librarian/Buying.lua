DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Librarian"] = DynamicTrading.Dialogue.Archetypes["Librarian"] or {}

DynamicTrading.Dialogue.Archetypes["Librarian"].Buying = {
    Generic = {
        "A wise acquisition! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} is a treasure of information, {player.firstname}.",
        "I'll pull the {item} from the archives. Enjoy.",
        "Knowledge is power. The {item} is yours for {price}.",
    },
    HighValue = {
        "Rare manuscript right there. {price} for the {item}. A relic of the old world.",
        "Top-shelf quality, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Ink and paper are scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision preservation isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these folios. {price} for the {item}.",
        "Clearing some archive space. {item} for {price}."
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
        "You're in the red, {player}. Even librarians need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
