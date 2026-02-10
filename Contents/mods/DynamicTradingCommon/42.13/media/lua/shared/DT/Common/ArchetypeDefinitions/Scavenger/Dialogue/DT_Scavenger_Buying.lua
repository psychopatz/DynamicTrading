DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Scavenger"] = DynamicTrading.Dialogue.Archetypes["Scavenger"] or {}

DynamicTrading.Dialogue.Archetypes["Scavenger"].Buying = {
    Generic = {
        "Found this in a locked chest! It's yours now. {price} received.",
        "Scored! The {item} is all yours, {player.firstname}. Enjoy.",
        "I'll trade the {item}. Better than keeping it in my pack.",
        "One man's trash, another man's treasure. {item} for {price}.",
    },
    HighValue = {
        "This is a legendary find! {price} for the {item}. Don't lose it.",
        "Top-tier loot right here, {player.firstname}. Worth every bit of {price}."
    },
    HighMarkup = {
        "Finding this wasn't easy. {price} for the {item}. Take it or leave it.",
        "Scavenging is hard work. {price} for the {item}."
    },
    LowMarkup = {
        "Got lucky and found two! Here, {price} for the {item}.",
        "Liquidating old finds. {item} for {price}."
    },
    LastStock = {
        "That's my last one. Better cherish it.",
        "Stock's dry. Only this {item} left."
    },
    SoldOut = {
        "Empty pockets here. No {item} available. Need to raid more buildings.",
        "None left in my stash."
    },
    NoCash = {
        "You're broke, {player}. Even scavengers need cash. Need more than {price}.",
        "Insufficient funds. Come back when you've got the cash for the {item}."
    }
}
