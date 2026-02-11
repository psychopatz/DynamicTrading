require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Brewer", "Greetings", {
    PH = {
        Default = {
            "Amoy mo ba 'yan, {player.firstname}? Galing 'yan sa hops. Ano'ng gusto mong ipatimpla sa'kin?",
            "Tinitingnan ko lang ang mga fermenter. Kailangan mo ba ng maiinom o gamit, {player}?",
            "Tuyong-tuyo na ang mundo, basain natin. Ano'ng maitutulong ko sa'yo, {player.firstname}?",
            "Tinitingnan ko lang ang mash. Bibili ka ba o tumitingin lang, {player}?",
            "May mga sariwang butil ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang paghahanda ng mash. Ano kailangan mo, {player.firstname}?",
            "Gising na ang lahat, busy na sa brewery. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, oras na para simulan ang pagpapakulo. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana puno ang iyong baso.",
        },
        Night = {
            "Nagluluto sa ilalim ng buwan... nakakaaliw. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na trabaho. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at brewery... magandang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Siguraduhin mong tuyo ang iyong yeast, {player}.",
        },
        Fog = {
            "Hindi ko makita ang airlock sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
