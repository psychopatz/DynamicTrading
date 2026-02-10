DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Brewer"] = DynamicTrading.Dialogue.Archetypes["Brewer"] or {}

DynamicTrading.Dialogue.Archetypes["Brewer"].Buying = {
    Generic = {
        "A refreshing choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will quench your thirst, {player.firstname}.",
        "I'll pull the {item} from the fermenter. Enjoy.",
        "Quality brews. The {item} is yours for {price}.",
    },
    HighValue = {
        "Strategic brew asset right there. {price} for the {item}. A real priority.",
        "Top-shelf quality drinks, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Hops are scarce these days. {price} for the {item}. Take it or leave it.",
        "Expert brewing isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these bottles. {price} for the {item}.",
        "Clearing some brewery space. {item} for {price}."
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
        "You're in the red, {player}. Even brewers need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
