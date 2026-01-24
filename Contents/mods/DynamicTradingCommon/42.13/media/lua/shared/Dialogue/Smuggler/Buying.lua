DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Smuggler"] = DynamicTrading.Dialogue.Archetypes["Smuggler"] or {}

DynamicTrading.Dialogue.Archetypes["Smuggler"].Buying = {
    Generic = {
        "Clean transfer of {price}. Pleasure.",
        "Don't ask where I got the {item}. It's yours now.",
        "Credits washed and received. Enjoy the {item}.",
        "Drop point established. Go get it.",
        "It fell off a truck. You want the {item} or not?"
    },
    NoCash = {
        "You trying to scam me, {player.firstname}? You don't have {price}.",
        "Empty pockets? Get off my channel."
    }
}
