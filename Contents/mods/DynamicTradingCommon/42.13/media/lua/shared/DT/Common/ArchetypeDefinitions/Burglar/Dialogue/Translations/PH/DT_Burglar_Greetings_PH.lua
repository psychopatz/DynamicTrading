require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Burglar", "Greetings", {
    PH = {
        Default = {
            "Tumahimik ka, {player.firstname}. Nagtatrabaho ako. Ano'ng gusto mo?",
            "Tinitingnan ko lang ang mga kandado. Kailangan mo ba ng gamit o nakuha naming loot, {player}?",
            "Naka-lock ang mundo, buksan natin 'to. Ano'ng maitutulong ko sa'yo, {player.firstname}?",
            "Tinitingnan ko lang ang mga vault. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong lockpick ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang panloloob. Ano kailangan mo, {player.firstname}?",
            "Gising na ang lahat, tahimik pa ang mundo. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, magsisimula na ang shift. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana matibay ang mga kandado mo.",
        },
        Night = {
            "Panloloob sa ilalim ng buwan... nakakaaliw. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na trabaho. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at panloloob... masamang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Siguraduhin mong tuyo ang iyong mga gamit, {player}.",
        },
        Fog = {
            "Hindi ko makita ang mga pin sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
