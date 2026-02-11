require "DT/Common/Config"

DynamicTrading.RegisterDialogue("RoadWarrior", "Greetings", {
    PH = {
        Default = {
            "Huwag mong patayin ang makina, {player.firstname}. Tumatawag na ang kalsada. Ano kailangan mo?",
            "Tinitingnan lang ang exhaust. Kailangan mo ba ng gasolina o gamit, {player}?",
            "Ang mundo ay isang highway, at puno ito ng dead end. Ano magagawa ko para sa'yo, {player.firstname}?",
            "Tinitingnan ang mga gulong. Bibili ka ba o tumitingin lang, {player}?",
            "May bagong gasolina ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pagpapatakbo. Ano kailangan mo, {player.firstname}?",
            "Sikat na ang araw, mainit na ang aspalto. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para maghanap ng ligtas na lugar. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana puno ang tanke mo.",
        },
        Night = {
            "Nagmamaneho sa ilalim ng buwan... nakakahumaling. Ano gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na patrol. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at highway... masamang kombinasyon. Ano balita, {player.firstname}?",
            "Masamang panahon. Panatilihing tuyo ang iyong goggles, {player}."
        },
        Fog = {
            "Hindi ko makita ang mga marker sa sobrang hamog. Ano balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
