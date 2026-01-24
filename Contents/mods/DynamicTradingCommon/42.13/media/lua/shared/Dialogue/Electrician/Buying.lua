DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Electrician"] = DynamicTrading.Dialogue.Archetypes["Electrician"] or {}

DynamicTrading.Dialogue.Archetypes["Electrician"].Buying = {
    Generic = {
        "Circuit finalized. I'll send the {item} over. {price} received.",
        "Transaction complete. That {item} is fully charged and ready, {player.firstname}.",
        "I'll pull the {item} from the rack. Use it wisely.",
        "Solid components. The {item} is yours for {price}.",
    },
    HighValue = {
        "High-voltage gear right there. {price} for the {item}. Don't blow a fuse.",
        "Precision electronics, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Copper is scarce these days. {price} for the {item}. Take it or leave it.",
        "Technical labor isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these capacitors. {price} for the {item}.",
        "Clearing some shelf space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the shop. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next week.",
        "Inventory's zeroed out for {item}."
    },
    NoCash = {
        "You're in the red, {player}. Even electricians need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
