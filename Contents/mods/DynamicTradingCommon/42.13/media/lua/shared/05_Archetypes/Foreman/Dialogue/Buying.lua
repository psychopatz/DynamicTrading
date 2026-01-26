DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Foreman"] = DynamicTrading.Dialogue.Archetypes["Foreman"] or {}

DynamicTrading.Dialogue.Archetypes["Foreman"].Buying = {
    Generic = {
        "Solid choice. I'll get that {item} delivered to your sector. {price} received.",
        "Transaction logged. Use that {item} for something productive, {player.firstname}.",
        "I'll authorize the release of the {item}. It's yours.",
        "That's standard equipment. {item} for {price}. Move it.",
    },
    HighValue = {
        "High-end gear right there. {price} for the {item}. Don't break it.",
        "Heavy-duty stuff, {player.firstname}. It's worth every bit of {price}."
    },
    HighMarkup = {
        "Overhead is killing us. {price} for the {item}. Take it or leave it.",
        "Resource shortages, {player}. {price} for the {item}."
    },
    LowMarkup = {
        "Surplus on the site. Here, {price} for the {item}.",
        "Liquidating old stock. {item} for {price}."
    },
    LastStock = {
        "Last of the inventory. Use that {item} wisely.",
        "Stock's zeroed out after this one. {item} is yours."
    },
    SoldOut = {
        "Supply line's cut. No {item} available. Check back next week.",
        "Inventory's empty for {item}."
    },
    NoCash = {
        "You're in the red, {player}. We don't do handouts. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
