require "DT/Common/Config"

DynamicTrading.RegisterAmbientDialogue("General", {
    EN = {
        Away = {
            Default = {
                { dialogue = "Just passing through. Don't expect me to stay long.", sentiment = "warning" },
                { dialogue = "I'm on the move. Catch me later.", sentiment = "warning" },
                { dialogue = "Can't stop here. I've got somewhere to be.", sentiment = "warning" },
            },
            Flee = {
                { dialogue = "No time. Move.", sentiment = "warning" },
            }
        }
    }
})
