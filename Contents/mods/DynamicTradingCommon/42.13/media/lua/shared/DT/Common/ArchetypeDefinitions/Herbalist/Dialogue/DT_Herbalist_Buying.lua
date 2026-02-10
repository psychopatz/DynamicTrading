DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Herbalist"] = DynamicTrading.Dialogue.Archetypes["Herbalist"] or {}

DynamicTrading.Dialogue.Archetypes["Herbalist"].Buying = {
    Generic = {
        "A natural choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} is pure and ready, {player.firstname}.",
        "I'll pull the {item} from the garden. Enjoy.",
        "Quality herbs. The {item} is yours for {price}.",
    },
    HighValue = {
        "Rare bloom right there. {price} for the {item}. A gift from the earth.",
        "Top-shelf quality, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Seeds are scarce these days. {price} for the {item}. Take it or leave it.",
        "Natural cultivation isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these perennials. {price} for the {item}.",
        "Clearing some garden space. {item} for {price}."
    },
    LastStock = {
        "That's the last cutting in the garden. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next season.",
        "Inventory's zeroed out for {item}."
    },
    NoCash = {
        "You're in the red, {player}. Even herbalists need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
