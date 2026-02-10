DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Burglar"] = DynamicTrading.Dialogue.Archetypes["Burglar"] or {}

DynamicTrading.Dialogue.Archetypes["Burglar"].Buying = {
    Generic = {
        "A stealthy choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} is a real steal, {player.firstname}.",
        "I'll pull the {item} from the stash. Enjoy.",
        "Quality loot. The {item} is yours for {price}.",
    },
    HighValue = {
        "Strategic asset right there. {price} for the {item}. A real priority.",
        "Top-shelf quality loot, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Lockpicks are scarce these days. {price} for the {item}. Take it or leave it.",
        "Expert thievery isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these pins. {price} for the {item}.",
        "Clearing some cache space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the stash. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next shift.",
        "None left in the stash."
    },
    NoCash = {
        "You're in the red, {player}. Even burglars need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
