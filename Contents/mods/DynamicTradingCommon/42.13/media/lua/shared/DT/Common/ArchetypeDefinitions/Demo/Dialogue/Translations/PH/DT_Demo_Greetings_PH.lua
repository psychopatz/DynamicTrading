require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Demo", "Greetings", {
    PH = {
        Default = {
            "Mag-ingat ka sa fuse, {player.firstname}. Ano'ng target natin?",
            "Inihahanda ko lang ang mga charge. Kailangan mo ba ng pampasabog o gamit, {player}?",
            "Ang mundo ay isang istruktura, itumba natin 'to. Ano'ng maitutulong ko sa'yo, {player.firstname}?",
            "Tinitingnan ko lang ang detonation. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong pulbura ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pasabog. Ano kailangan mo, {player.firstname}?",
            "Gising na ang lahat, tahimik ang mundo. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, tinatapos ko na ang pasabog. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana matibay ang iyong mga pader.",
        },
        Night = {
            "Pagpapasabog sa ilalim ng buwan... nakakaaliw. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na paghahanda. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at pampasabog... masamang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Siguraduhin mong tuyo ang iyong pulbura, {player}.",
        },
        Fog = {
            "Hindi ko makita ang mga marker sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
