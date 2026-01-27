DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Demo"] = DynamicTrading.Dialogue.Archetypes["Demo"] or {}

DynamicTrading.Dialogue.Archetypes["Demo"].Buying = {
    Generic = {
        "A destructive choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} is ready to boom and ready, {player.firstname}.",
        "I'll pull the {item} from the crate. Enjoy.",
        "Quality explosives. The {item} is yours for {price}.",
    },
    HighValue = {
        "High-explosive asset right there. {price} for the {item}. A real blast.",
        "Top-shelf quality detonators, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Gunpowder is scarce these days. {price} for the {item}. Take it or leave it.",
        "Expert demolition isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these fuses. {price} for the {item}.",
        "Clearing some demolition space. {item} for {price}."
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
        "You're in the red, {player}. Even demo experts need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
