require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Doctor", "Greetings", {
    EN = {
        Default = {
            "Clinic is open. {player.firstname}, are you injured?",
            "Stay safe out there. Do you need meds, {player}?",
            "Hygiene is priority. Wash your hands, {player.firstname}.",
            "Triage center here. Is this an emergency?",
            "Pulse check. You still alive out there, {player.firstname}?"
        },
        NoBudget = {
            "Clinic's open, but my wallet's empty. Need medical supplies?",
            "No cash for buying, but I've got medicine and supplies to sell.",
            "Broke as can be, but check out my medical inventory!",
            "Can't afford purchases, but I'm here to treat your injuries."
        }
    }
})
