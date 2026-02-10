DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Pharmacist"] = DynamicTrading.Dialogue.Archetypes["Pharmacist"] or {}

DynamicTrading.Dialogue.Archetypes["Pharmacist"].Greetings = {
    Default = {
        "Careful with the dosages, {player.firstname}. What's the ailment?",
        "Just counting the pills. You need meds or advice, {player}?",
        "The world is sick, let's find a cure. What can I do for ya, {player.firstname}?",
        "Checking the prescription room. You buying or just browsing, {player}?",
        "Got some fresh antibiotics today. What do you need, {player.firstname}?"
    },
    Morning = {
        "Early morning dispensary. What do you need, {player.firstname}?",
        "Sun's up, the clinic is quiet. Ready for a trade, {player}?",
    },
    Evening = {
        "Sun's setting, time to finalize the labels. Quick trade, {player.firstname}?",
        "Evening, {player}. Hope your health is good.",
    },
    Night = {
        "Dispensing by moonlight... not ideal. What do you want, {player.firstname}?",
        "Night's for the quiet work. Speak up, {player}.",
    },
    Raining = {
        "Rain and meds... bad mix. What's up, {player.firstname}?",
        "Miserable weather. Keep your bandage dry, {player}.",
    },
    Fog = {
        "Can't see the labels in this fog. What's the word, {player.firstname}?",
        "Ghostly weather. You still there, {player}?"
    }
}
