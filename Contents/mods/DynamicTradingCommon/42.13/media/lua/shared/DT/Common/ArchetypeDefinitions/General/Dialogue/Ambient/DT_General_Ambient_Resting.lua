require "DT/Common/Config"

DynamicTrading.RegisterDialogue("General", "Ambient", {
    EN = {
        Resting = {
            Default = {
                { dialogue = "I'm resting right now. Come back when I'm back on shift.", sentiment = "resting" },
                { dialogue = "Taking a breather. The road's been rough today.", sentiment = "resting" },
                { dialogue = "Not trading yet. Just trying to stay on my feet.", sentiment = "resting" },
                { dialogue = "Give me a minute. I'm off the clock for now.", sentiment = "resting" },
                { dialogue = "Quiet day. I'm keeping my head down and getting some rest.", sentiment = "resting" },
            },
            Attack = {
                { dialogue = "I said I'm resting. Don't push it.", sentiment = "angry" },
                { dialogue = "You picked the wrong moment to crowd me.", sentiment = "angry" },
            },
            Flee = {
                { dialogue = "Rest can wait. Time to move.", sentiment = "warning" },
            }
        }
    }
})
