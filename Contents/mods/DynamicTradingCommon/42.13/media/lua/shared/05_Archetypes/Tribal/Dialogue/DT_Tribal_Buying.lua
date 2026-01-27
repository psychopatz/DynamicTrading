DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Tribal"] = DynamicTrading.Dialogue.Archetypes["Tribal"] or {}

DynamicTrading.Dialogue.Archetypes["Tribal"].Buying = {
    Generic = {
        "A spiritual choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will protect your spirit, {player.firstname}.",
        "I'll pull the {item} from the totem. Enjoy.",
        "Quality wards. The {item} is yours for {price}.",
    },
    HighValue = {
        "Strategic spirit asset right there. {price} for the {item}. A real priority.",
        "Top-shelf quality wards, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Feathers are scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision warding isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these bones. {price} for the {item}.",
        "Clearing some spirit space. {item} for {price}."
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
        "You're in the red, {player}. Even tribals need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
