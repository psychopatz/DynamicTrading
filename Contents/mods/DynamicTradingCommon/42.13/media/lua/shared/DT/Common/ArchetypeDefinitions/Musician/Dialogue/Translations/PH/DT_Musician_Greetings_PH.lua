require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Musician", "Greetings", {
    PH = {
        Default = {
            "Sabayan mo ang ritmo, {player.firstname}. Ano'ng melodiya natin ngayon?",
            "Inaayos lang ang kaluluwa. Kailangan mo ba ng harmony o gamit, {player}?",
            "Tahimik ang mundo, pero hindi tumitigil ang musika. Ano'ng magagawa ko para sa'yo, {player.firstname}?",
            "Tinitingnan lang ang mga scale. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong vinyl ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang overture. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, nasa tono ang mundo. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para sa sonata sa gabi. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana ay maganda ang iyong kanta.",
        },
        Night = {
            "Nagsusulat ng kanta sa ilalim ng buwan... nakaka-inspire. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa mga tahimik na ballad. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at ritmo... natural na kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Panatilihing tuyo ang iyong mga instrumento, {player}."
        },
        Fog = {
            "Hindi ko makita ang mga nota sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
