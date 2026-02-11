require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Chef", "Greetings", {
    PH = {
        Default = {
            "Amoy mo ba 'yan, {player.firstname}? Ang bango 'di ba? Ano'ng gusto mong iluto ko sa'yo?",
            "Mainit sa kusina, daming orders. Kailangan mo ba ng pagkain o supplies, {player}?",
            "Maigsi lang ang buhay, kumain nang masarap. Ano kailangan mo, {player.firstname}?",
            "Tinitingnan ko lang ang pantry. Bibili ka ba o tumitingin lang, {player}?",
            "May mga sariwang sangkap ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang paghahanda ng almusal. Ano kailangan mo, {player.firstname}?",
            "Gising na ang lahat, nagpapakulo na ako ng kape. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, magsisimula na ang hapunan. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana may dala kang pwedeng ilagay sa palayok.",
        },
        Night = {
            "Midnight snack ba? Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na paghahanda. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at mga oven... magandang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Tuloy ka at magpatuyo, {player}.",
        },
        Fog = {
            "Hindi ko makita ang kalan sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
