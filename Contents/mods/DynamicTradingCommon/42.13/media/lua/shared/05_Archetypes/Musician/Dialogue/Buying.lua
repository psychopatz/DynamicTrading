DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Musician"] = DynamicTrading.Dialogue.Archetypes["Musician"] or {}

DynamicTrading.Dialogue.Archetypes["Musician"].Buying = {
    Generic = {
        "A harmonious choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will add some soul to your day, {player.firstname}.",
        "I'll pull the {item} from the stage. Enjoy.",
        "Solid beat. The {item} is yours for {price}.",
    },
    HighValue = {
        "Symphonic asset right there. {price} for the {item}. A real encore.",
        "Top-shelf quality music, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Instruments are scarce these days. {price} for the {item}. Take it or leave it.",
        "Expert composing isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these picks. {price} for the {item}.",
        "Clearing some stage space. {item} for {price}."
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
        "You're in the red, {player}. Even musicians need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
