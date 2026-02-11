require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Painter", "Greetings", {
    PH = {
        Default = {
            "Abangan ang liwanag, {player.firstname}. Ano'ng obra maestra natin ngayon?",
            "Naghahalo lang ng mga kulay. Kailangan mo ba ng palette o gamit, {player}?",
            "Masyadong gray ang mundo, bigyan natin ng buhay. Ano'ng magagawa ko para sa'yo, {player.firstname}?",
            "Tinitingnan ang sketch. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong pigment ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pag-sketch. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, perpekto ang liwanag. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para sa paglilinis sa gabi. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana ay matingkad ang iyong mga kulay.",
        },
        Night = {
            "Nagpipinta sa ilalim ng buwan... nakakalula. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na trabaho. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at studio... magandang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Panatilihing tuyo ang iyong canvas, {player}."
        },
        Fog = {
            "Hindi ko makita ang lalim sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
