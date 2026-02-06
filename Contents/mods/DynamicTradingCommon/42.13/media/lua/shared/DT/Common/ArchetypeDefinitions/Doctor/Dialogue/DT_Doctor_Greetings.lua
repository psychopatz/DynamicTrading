DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Doctor"] = DynamicTrading.Dialogue.Archetypes["Doctor"] or {}

DynamicTrading.Dialogue.Archetypes["Doctor"].Greetings = {
    Default = {
        "Clinic is open. {player.firstname}, are you injured?",
        "Stay safe out there. Do you need meds, {player}?",
        "Hygiene is priority. Wash your hands, {player.firstname}.",
        "Triage center here. Is this an emergency?",
        "Pulse check. You still alive out there, {player.firstname}?"
    }
}
