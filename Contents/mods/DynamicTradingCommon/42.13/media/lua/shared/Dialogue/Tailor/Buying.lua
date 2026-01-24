DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Tailor"] = DynamicTrading.Dialogue.Archetypes["Tailor"] or {}

DynamicTrading.Dialogue.Archetypes["Tailor"].Buying = {
    Generic = {
        "A fine Choice! I'll package the {item} with care. {price} received.",
        "Transaction complete. That {item} will look great on you, {player.firstname}.",
        "I'll pull the {item} from the display. Enjoy.",
        "Quality craftsmanship. The {item} is yours for {price}.",
    },
    HighValue = {
        "Exquisite piece! {price} for the {item}. This is high-fashion for a low-life world.",
        "A true masterpiece, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Fine materials are scarce. {price} for the {item}. Best I can do.",
        "Precision work takes time. {price} for the {item}."
    },
    LowMarkup = {
        "Found a bolt of this on sale. {price} for the {item}.",
        "Last season's stock. {item} for {price}."
    },
    LastStock = {
        "That's the last of the line. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Out of stock for {item}. Check back next season.",
        "None left in the atelier."
    },
    NoCash = {
        "You're broke, {player}. Even tailors need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
