DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Blacksmith"] = DynamicTrading.Dialogue.Archetypes["Blacksmith"] or {}

DynamicTrading.Dialogue.Archetypes["Blacksmith"].Buying = {
    Generic = {
        "A forged choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will serve you well in the forge, {player.firstname}.",
        "I'll pull the {item} from the anvil. Enjoy.",
        "Quality steel. The {item} is yours for {price}.",
    },
    HighValue = {
        "Strategic steel asset right there. {price} for the {item}. A real priority.",
        "Top-shelf quality armor, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Coal is scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision forging isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these bars. {price} for the {item}.",
        "Clearing some forge space. {item} for {price}."
    },
    LastStock = {
        "That's the last one in the shop. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next semester.",
        "None left in the archives."
    },
    NoCash = {
        "You're in the red, {player}. Even blacksmiths need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
