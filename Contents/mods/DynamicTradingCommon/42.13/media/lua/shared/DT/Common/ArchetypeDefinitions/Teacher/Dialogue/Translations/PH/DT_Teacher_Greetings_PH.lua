require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Teacher", "Greetings", {
    PH = {
        Default = {
            "Tingin sa board, {player.firstname}. Ano'ng lesson natin ngayon?",
            "Gina-grade-an lang ang survival skills niyo. Kailangan mo ba ng kaalaman o supplies, {player}?",
            "Ang pag-aaral ay panghabambuhay, kahit ngayon. Ano'ng magagawa ko para sa'yo, {player.firstname}?",
            "Tinitingnan ang curriculum. Bibili ka ba o tumitingin lang, {player}?",
            "May bagong yeso ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang lecture. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, tahimik ang silid-aralan. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para mag-reflect sa mga natutunan ngayong araw. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana ay matalas ang iyong isip.",
        },
        Night = {
            "Late night study? Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na trabaho. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at silid-aralan... masarap sa pakiramdam. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Pumasok ka at magpatuyo, {player}."
        },
        Fog = {
            "Hindi ko makita ang mga index sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
