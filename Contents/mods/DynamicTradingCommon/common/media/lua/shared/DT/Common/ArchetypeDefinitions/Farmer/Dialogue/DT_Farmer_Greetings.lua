require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Farmer", "Greetings", {
    EN = {
        Default = {
            "Howdy, {player.firstname}. Crops are looking good.",
            "Hard work pays off. You buyin' or sellin'?",
            "Ain't much, but it's honest work.",
            "Barn's open. What do you need, partner?",
            "Just finished the harvest. Got plenty of stock."
        },
        NoBudget = {
            "Crops are ready, but my wallet's empty. Buy something?",
            "No cash for buying, but check out my fresh produce!",
            "Broke as a joke, but I've got vegetables and grains to sell.",
            "Can't afford purchases, but my harvest is looking great."
        }
    }
})
