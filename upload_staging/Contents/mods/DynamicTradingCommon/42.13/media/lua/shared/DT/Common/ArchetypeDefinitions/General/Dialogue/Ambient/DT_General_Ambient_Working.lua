require "DT/Common/Config"

DynamicTrading.RegisterDialogue("General", "Ambient", {
    EN = {
        Working = {
            Default = {
                { dialogue = "Keeping watch and staying busy.", sentiment = "friendly" },
                { dialogue = "Working right now. Stay sharp out there.", sentiment = "friendly" },
                { dialogue = "I'm on task. Make it quick if you need something.", sentiment = "warning" },
            },
            Guard = {
                { dialogue = "Holding this spot. Don't bring trouble here.", sentiment = "warning" },
                { dialogue = "Watch the perimeter and mind the noise.", sentiment = "warning" },
            },
            Attack = {
                { dialogue = "Can't talk. I've got a job to finish.", sentiment = "angry" },
            }
        }
    }
})
