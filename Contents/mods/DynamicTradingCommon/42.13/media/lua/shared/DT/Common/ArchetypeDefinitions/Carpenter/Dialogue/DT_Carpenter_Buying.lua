DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Carpenter"] = DynamicTrading.Dialogue.Archetypes["Carpenter"] or {}

DynamicTrading.Dialogue.Archetypes["Carpenter"].Buying = {
    Generic = {
        "A sturdy choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will help you finish your project, {player.firstname}.",
        "I'll pull the {item} from the rack. Enjoy.",
        "Solid craftsmanship. The {item} is yours for {price}.",
    },
    HighValue = {
        "Fine-grain asset right there. {price} for the {item}. A real heirloom.",
        "Top-shelf quality woodwork, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Lumber is scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision joinery isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these dowels. {price} for the {item}.",
        "Clearing some shop space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the shop. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next season.",
        "None left in the shop."
    },
    NoCash = {
        "You're in the red, {player}. Even carpenters need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
