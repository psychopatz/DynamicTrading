require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Bartender", "Greetings", {
    PH = {
        Default = {
            "Ano'ng sa'yo, {player.firstname}? Ang dati pa rin ba?",
            "Bukas na ang bar, libre ang chismis. Kailangan mo ba ng maiinom o balita, {player}?",
            "Upu ka muna, {player.firstname}. Ano'ng balita sa labas?",
            "Tinitingnan ko lang ang mga tap. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong de-bote ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pampagising. Ano kailangan mo, {player.firstname}?",
            "Gising na ang lahat, tahimik pa ang bar. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, magsisimula na ang happy hour. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana maging maayos ang gabi mo.",
        },
        Night = {
            "Last call na ba? Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa mahinahong usapan. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at mainit na bar... magandang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Pasok ka muna at magpatuyo, {player}.",
        },
        Fog = {
            "Hindi ko makita ang salamin sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
