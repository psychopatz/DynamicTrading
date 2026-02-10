DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Mechanic"] = DynamicTrading.Dialogue.Archetypes["Mechanic"] or {}

DynamicTrading.Dialogue.Archetypes["Mechanic"].Buying = {
    Generic = {
        "Parts are checked and ready. {price} received. That {item} will serve you well.",
        "Transaction green-lit. You got the {item}, {player.firstname}.",
        "I'll pull the {item} from storage for ya. Enjoy.",
        "Solid choice. {item} is yours for {price}.",
    },
    HighValue = {
        "High-performance stuff right here. {price} for the {item}.",
        "That's some heavy-duty hardware, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Scarcity's a killer. {price} for the {item}. It's the best I can do.",
        "Labor and parts aren't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these. {price} for the {item}.",
        "Clearing some shelf space. Grab the {item} for {price}."
    },
    LastStock = {
        "That's the last one in the shop. Take care of that {item}.",
        "Inventory's dry after this. Last {item} is yours."
    },
    SoldOut = {
        "Sorry {player}, my stock of {item} is empty. Check back tomorrow.",
        "No more {item} on the shelves."
    },
    NoCash = {
        "You're red-lining your wallet, {player}. Need more than {price} for that {item}.",
        "Can't trade if you're broke. Come back when you've got the cash."
    }
}
