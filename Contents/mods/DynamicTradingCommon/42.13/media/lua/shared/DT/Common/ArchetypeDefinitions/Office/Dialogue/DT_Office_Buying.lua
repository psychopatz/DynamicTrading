DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Office"] = DynamicTrading.Dialogue.Archetypes["Office"] or {}

DynamicTrading.Dialogue.Archetypes["Office"].Buying = {
    Generic = {
        "A standard requisition! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} is fully requisitioned and ready, {player.firstname}.",
        "I'll pull the {item} from the warehouse. Enjoy.",
        "Quality supplies. The {item} is yours for {price}.",
    },
    HighValue = {
        "Strategic asset right there. {price} for the {item}. A real priority.",
        "Top-shelf quality supplies, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Resources are scarce this quarter. {price} for the {item}. Take it or leave it.",
        "Expert logistics isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these crates. {price} for the {item}.",
        "Clearing some warehouse space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the manifest. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next quarter.",
        "None left in the warehouse."
    },
    NoCash = {
        "You're in the red, {player}. Even office workers need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
