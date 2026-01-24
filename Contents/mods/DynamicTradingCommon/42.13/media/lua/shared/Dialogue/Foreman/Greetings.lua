DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Archetypes["Foreman"] = DynamicTrading.Dialogue.Archetypes["Foreman"] or {}

DynamicTrading.Dialogue.Archetypes["Foreman"].Greetings = {
    Default = {
        "On the clock, {player.firstname}. What's the status?",
        "Site's busy. You here with the supplies, {player}?",
        "Move it along, {player.firstname}. We're on a deadline.",
        "Got the crew working. What do YOU need, {player}?",
        "Checking the blueprints. Speak up, {player.firstname}."
    },
    Morning = {
        "Morning muster. Get to work, {player.firstname}.",
        "Sun's up, hammers are swinging. What's the word, {player}?",
    },
    Evening = {
        "Day's almost done. Wrap it up, {player.firstname}.",
        "Packing up the site soon. What do you need, {player}?",
    },
    Night = {
        "Late shift, huh {player.firstname}? Watch your step.",
        "Night crew's on. Make it quick, {player}.",
    },
    Raining = {
        "Rain's delaying the pour. Dammit. What you got, {player.firstname}?",
        "Mud everywhere. Keep your boots clean, {player}.",
    },
    Fog = {
        "Can't see the crane. Safety first, {player.firstname}.",
        "Fog's thick. Stay visible out there, {player}."
    }
}
