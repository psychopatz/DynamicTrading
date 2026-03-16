require "DT/Common/Config"

DynamicTrading.RegisterDialogue("General", "Ambient", {
    EN = {
        Default = {
            Default = {
                { dialogue = "Still breathing. That's something.", sentiment = "neutral" },
                { dialogue = "You need something?", sentiment = "neutral" },
                { dialogue = "Another day in Knox Country.", sentiment = "neutral" },
                { dialogue = "Stay sharp out there.", sentiment = "friendly" },
            },
            Attack = {
                { dialogue = "If you're not helping, move.", sentiment = "angry" },
                { dialogue = "This is a bad time to get close.", sentiment = "angry" },
            },
            AttackRange = {
                { dialogue = "Keep your head down.", sentiment = "warning" },
                { dialogue = "Too exposed. Back up a little.", sentiment = "warning" },
            },
            Flee = {
                { dialogue = "Move now, talk later.", sentiment = "warning" },
            },
            Incapacitated = {
                { dialogue = "Please... don't finish me off...", sentiment = "warning" },
                { dialogue = "I can't keep moving... just let me go...", sentiment = "warning" },
                { dialogue = "Help me... please, I don't want to die here...", sentiment = "warning" },
                { dialogue = "Enough... please... I surrender...", sentiment = "warning" },
                { dialogue = "Don't kill me... I'm done fighting...", sentiment = "warning" },
            }
        }
    }
})
