DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Painter"] = DynamicTrading.Dialogue.Archetypes["Painter"] or {}

DynamicTrading.Dialogue.Archetypes["Painter"].Buying = {
    Generic = {
        "A colorful choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will add some life to your day, {player.firstname}.",
        "I'll pull the {item} from the palette. Enjoy.",
        "Quality pigments. The {item} is yours for {price}.",
    },
    HighValue = {
        "Masterpiece asset right there. {price} for the {item}. A real encore.",
        "Top-shelf quality art, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Brushes are scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision washing isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these tubes. {price} for the {item}.",
        "Clearing some palette space. {item} for {price}."
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
        "You're in the red, {player}. Even painters need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
