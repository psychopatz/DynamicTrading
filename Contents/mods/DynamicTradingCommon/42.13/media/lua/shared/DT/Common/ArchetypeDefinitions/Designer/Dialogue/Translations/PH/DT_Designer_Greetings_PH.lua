require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Designer", "Greetings", {
    PH = {
        Default = {
            "Ang istilo ay walang hanggan, {player.firstname}. Ano'ng look natin ngayon?",
            "Tinatalian ko lang ang isang sketch. Kailangan mo ba ng aesthetics o gamit, {player}?",
            "Pangit ang mundo, gawin nating maganda. Ano'ng maitutulong ko sa'yo, {player.firstname}?",
            "Tinitingnan ko lang ang mga blueprint. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong swatch ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pag-layout. Ano kailangan mo, {player.firstname}?",
            "Gising na ang lahat, tahimik ang studio. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, tinatapos ko na ang design. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana elegante ang iyong lugar.",
        },
        Night = {
            "Pagde-design sa ilalim ng buwan... nakakaaliw. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na trabaho. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at studio... magandang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masama ang panahon. Siguraduhin mong tuyo ang iyong mga sketch, {player}.",
        },
        Fog = {
            "Hindi ko makita ang depth sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
