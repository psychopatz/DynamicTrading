require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Welder", "Greetings", {
    PH = {
        Default = {
            "Hawakan mo ang mask, {player.firstname}. Nanonood ka ba sa spark?",
            "Tinatapos ko lang 'tong isang dugtong. Kailangan mo ba ng metal o baluti, {player}?",
            "Mainit sa shop ngayon. Ano'ng magagawa ko para sa'yo, {player.firstname}?",
            "Tinitingnan ang mga dugtong. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong bakal ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang mga spark. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, nakasindi na ang mga torch. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para palamigin ang talyer. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana'y matibay ang iyong mga pader.",
        },
        Night = {
            "Nagwe-welding sa dilim... hindi maganda 'to. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na trabaho. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at torch... masamang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Panatilihing tuyo ang mga bakal mo, {player}."
        },
        Fog = {
            "Hindi ko makita ang mga spark sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
