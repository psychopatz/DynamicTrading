DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["RoadWarrior"] = DynamicTrading.Dialogue.Archetypes["RoadWarrior"] or {}

DynamicTrading.Dialogue.Archetypes["RoadWarrior"].Buying = {
    Generic = {
        "A fast choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will serve you well on the highway, {player.firstname}.",
        "I'll pull the {item} from the saddlebag. Enjoy.",
        "Quality gases. The {item} is yours for {price}.",
    },
    HighValue = {
        "Strategic fuel asset right there. {price} for the {item}. A real priority.",
        "Top-shelf quality gas, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Gasoline is scarce these days. {price} for the {item}. Take it or leave it.",
        "Precision tuning isn't cheap. {price} for the {item}."
    },
    LowMarkup = {
        "Found a surplus of these cans. {price} for the {item}.",
        "Clearing some cargo space. {item} for {price}."
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
        "You're in the red, {player}. Even road warriors need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
