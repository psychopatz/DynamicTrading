require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Angler", "Greetings", {
    PH = {
        Default = {
            "Tahimik lang tayo, {player.firstname}. Kumakagat na ang mga isda. Ano kailangan mo?",
            "Tinitingnan ko lang ang mga pain. Kailangan mo ba ng gamit o gusto mo makinig ng kwento, {player}?",
            "Kalmado ang tubig ngayon. Ano'ng maitutulong ko sa'yo, {player.firstname}?",
            "Pinapanood ko lang ang alon. Bibili ka ba o tumitingin lang, {player}?",
            "May mga sariwang pain ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pamingwit. Ano kailangan mo, {player.firstname}?",
            "Gising na ang lawa, sikat na ang araw. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, oras na para ligpitin ang mga gamit. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana marami kang nahuli.",
        },
        Night = {
            "Pangingisda sa gabi... napakatahimik. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na paghihintay. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at mga alon... maganda para sa pangingisda. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Siguraduhin mong tuyo ang mga gamit mo, {player}.",
        },
        Fog = {
            "Hindi ko makita ang float sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
