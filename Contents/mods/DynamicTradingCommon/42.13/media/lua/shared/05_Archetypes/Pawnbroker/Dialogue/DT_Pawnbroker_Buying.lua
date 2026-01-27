DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Pawnbroker"] = DynamicTrading.Dialogue.Archetypes["Pawnbroker"] or {}

DynamicTrading.Dialogue.Archetypes["Pawnbroker"].Buying = {
    Generic = {
        "A profitable choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} is a real steal, {player.firstname}.",
        "I'll pull the {item} from the vault. Enjoy.",
        "Quality collectibles. The {item} is yours for {price}.",
    },
    HighValue = {
        "Rare heirloom right there. {price} for the {item}. A real curiosity.",
        "Top-shelf quality collectibles, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Antiques are scarce these days. {price} for the {item}. Take it or leave it.",
        "Expert appraisal isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these knick-knacks. {price} for the {item}.",
        "Clearing some vault space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the shop. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next season.",
        "None left in the vault."
    },
    NoCash = {
        "You're in the red, {player}. Even pawnbrokers need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
