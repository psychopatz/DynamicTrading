require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Tribal", "Greetings", {
    PH = {
        Default = {
            "Ginabayan ka ng mga espiritu rito, {player.firstname}. Ano'ng hinahanap mo?",
            "Igalang mo lang ang mga ninuno. Kailangan mo ba ng mga sibat o espiritu, {player}?",
            "Ang lupa ang nagbibigay, kahit ngayon. Ano'ng magagawa ko para sa'yo, {player.firstname}?",
            "Tinitingnan ang mga totem. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong pangontra ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang dasal. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, gising na ang mundo. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para ibalik ang apoy. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana'y payapa ang iyong espiritu.",
        },
        Night = {
            "Nagdarasal sa ilalim ng buwan... nakakahumaling. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na trabaho. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at apoy... masarap sa pakiramdam. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Panatilihing tuyo ang iyong espiritu, {player}."
        },
        Fog = {
            "Hindi ko makita ang mga espiritu sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
