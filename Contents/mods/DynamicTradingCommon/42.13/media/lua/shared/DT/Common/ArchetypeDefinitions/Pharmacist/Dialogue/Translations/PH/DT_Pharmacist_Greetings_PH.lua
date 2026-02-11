require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Pharmacist", "Greetings", {
    PH = {
        Default = {
            "Mag-ingat sa mga dosage, {player.firstname}. Ano'ng iniinda mo?",
            "Nagbibilang lang ng mga gamot. Kailangan mo ba ng gamot o payo, {player}?",
            "May sakit ang mundo, maghanap tayo ng lunas. Ano'ng magagawa ko para sa'yo, {player.firstname}?",
            "Tinitingnan ang prescription room. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong antibiotic ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang dispensary. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, tahimik ang klinika. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para i-finalize ang mga label. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana ay mabuti ang iyong kalusugan.",
        },
        Night = {
            "Nagbibigay ng gamot sa ilalim ng buwan... hindi ideal. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na trabaho. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at gamot... masamang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Panatilihing tuyo ang iyong benda, {player}."
        },
        Fog = {
            "Hindi ko makita ang mga label sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
