require "DT/Common/Config"

DynamicTrading.RegisterDialogue("General", "Ambient", {
    EN = {
        Trading = {
            Default = {
                { dialogue = "Fresh stock today. Take a look while it lasts.", sentiment = "trading" },
                { dialogue = "If you're buying, now's a good time.", sentiment = "trading" },
                { dialogue = "I've got goods moving. Don't wait too long.", sentiment = "trading" },
                { dialogue = "Looking to trade? I've got a few things worth seeing.", sentiment = "trading" },
                { dialogue = "Business is open. Let's keep it quick and clean.", sentiment = "trading" },
            },
            Attack = {
                { dialogue = "Back off. I'm busy surviving, not bargaining.", sentiment = "angry" },
                { dialogue = "Bad timing. Handle the dead first, trade later.", sentiment = "angry" },
            },
            AttackRange = {
                { dialogue = "Keep low. I'm covering this spot.", sentiment = "warning" },
                { dialogue = "No shopping while rounds are flying.", sentiment = "angry" },
            },
            Flee = {
                { dialogue = "Shop's closed. I'm moving.", sentiment = "warning" },
            }
        }
    }
})
