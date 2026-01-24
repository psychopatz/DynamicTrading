DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Gunrunner"] = DynamicTrading.Dialogue.Archetypes["Gunrunner"] or {}

DynamicTrading.Dialogue.Archetypes["Gunrunner"].Buying = {
    Generic = {
        "Click-clack. You're ready for war with this {item}.",
        "Good iron. Keep it clean.",
        "Sending the package. Point it away from me.",
        "Payment of {price} confirmed. Happy hunting, {player}."
    },
    NoCash = {
        "Bullets ain't free, {player}. You need {price}.",
        "No cash, no bang. Get lost."
    }
}
