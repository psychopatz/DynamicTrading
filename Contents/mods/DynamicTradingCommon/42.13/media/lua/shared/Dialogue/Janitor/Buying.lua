DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Janitor"] = DynamicTrading.Dialogue.Archetypes["Janitor"] or {}

DynamicTrading.Dialogue.Archetypes["Janitor"].Buying = {
    Generic = {
        "A practical choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will help you keep things tidy, {player.firstname}.",
        "I'll pull the {item} from the supply closet. Enjoy.",
        "Quality detergents. The {item} is yours for {price}.",
    },
    HighValue = {
        "Industrial asset right there. {price} for the {item}. A real deep-cleaner.",
        "Top-shelf quality supplies, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Disinfectants are scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision mopping isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these sponges. {price} for the {item}.",
        "Clearing some closet space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the closet. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next shift.",
        "None left in the closet."
    },
    NoCash = {
        "You're in the red, {player}. Even janitors need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
