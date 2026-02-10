DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Doctor"] = DynamicTrading.Dialogue.Archetypes["Doctor"] or {}

DynamicTrading.Dialogue.Archetypes["Doctor"].Buying = {
    Generic = {
        "Here's the prescription: {item}. Use it wisely.",
        "Payment of {price} received. Hope this helps.",
        "Dispatching supplies now. Stay healthy, {player.firstname}.",
        "Sterilize the {item} before use. Confirmed.",
        "Take two of these and call me in the morning."
    },
    NoCash = {
        "I can't give out {item} without payment, I need to buy supplies too. You need {price}.",
        "Sorry, {player.firstname}, your card declined."
    }
}
