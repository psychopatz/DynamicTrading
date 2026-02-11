require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Athlete", "Greetings", {
    PH = {
        Default = {
            "Tuloy-tuloy lang ang galaw, {player.firstname}. Ano'ng workout natin ngayon?",
            "Katatapos ko lang ng isang set. Kailangan mo ba ng gamit o pampalakas, {player}?",
            "Laging handa, laging buhay. Ano'ng maitutulong ko sa'yo, {player.firstname}?",
            "Tinitingnan ko lang ang training room. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong supplements ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang cardio. Ano kailangan mo, {player.firstname}?",
            "Gising na, tahimik pa sa gym. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, oras na para sa cool down. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana malakas pa rin ang mga muscle mo.",
        },
        Night = {
            "Nag-eensayo sa ilalim ng buwan... nakakaginhawa. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na paghahanda. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at workout... natural na kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Siguraduhin mong tuyo ang sapatos mo, {player}.",
        },
        Fog = {
            "Hindi ko makita ang mga lap sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
