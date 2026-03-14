require "DT/Common/Config"

DynamicTrading.RegisterAmbientDialogue("General", {
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
            }
        }
    }
})
