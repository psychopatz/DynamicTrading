require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Electrician", "Greetings", {
    PH = {
        Default = {
            "Mag-ingat sa mga terminal, {player.firstname}. Ano'ng voltage natin?",
            "Inaayos ko lang ang short circuit. Kailangan mo ba ng piyesa o kuryente, {player}?",
            "Walang kuryente sa grid, pero ang trade ay tuloy pa rin. Ano'ng maitutulong ko sa'yo, {player.firstname}?",
            "Sinusukat ko lang ang kuryente. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong baterya ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pag-recharge. Ano kailangan mo, {player.firstname}?",
            "Gising na ang lahat, nagtsa-charge na ang solar. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, oras na para magtipid ng kuryente. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana manatiling bukas ang iyong mga ilaw.",
        },
        Night = {
            "Pagtatrabaho sa dilim... hindi maganda. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na trabaho. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at kuryente... masamang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masama ang panahon. Siguraduhin mong tuyo ang iyong device, {player}.",
        },
        Fog = {
            "Hindi ko makita ang mga wire sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
