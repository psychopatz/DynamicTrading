require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Blacksmith", "Greetings", {
    PH = {
        Default = {
            "Mainit na pandayan, {player.firstname}. Pinapanood mo ba ang mga spark?",
            "Pinupukpok ko lang ang bakal. Kailangan mo ba ng mga talim o baluti, {player}?",
            "Malamig ang mundo, painitin natin 'to. Ano'ng maitutulong ko sa'yo, {player.firstname}?",
            "Tinitingnan ko lang ang anvil. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong bakal ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pagpukpok. Ano kailangan mo, {player.firstname}?",
            "Gising na, mainit na ang pandayan. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, oras na para palamigin ang bakal. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana matibay ang mga pader mo.",
        },
        Night = {
            "Nagtatrabaho sa ilalim ng buwan... nakakaaliw. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na pagtatrabaho. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at pandayan... magandang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Siguraduhin mong tuyo ang iyong bakal, {player}.",
        },
        Fog = {
            "Hindi ko makita ang hugis sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
