require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Geek", "Greetings", {
    PH = {
        Default = {
            "Level up, {player.firstname}. Ano'ng quest natin ngayon?",
            "Dine-debug ko lang ang apocalypse. Kailangan mo ba ng tech o gamit, {player}?",
            "Ang mundo ay isang glitch, i-optimize natin 'to. Ano'ng maitutulong ko sa'yo, {player.firstname}?",
            "Tinitingnan ko ang codebase. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong hardware ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pag-compile. Ano kailangan mo, {player.firstname}?",
            "Gising na ang lahat, live na ang mundo. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, oras na para i-push ang mga change. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana stable ang connection mo.",
        },
        Night = {
            "Nagco-code sa ilalim ng buwan... nakakaaliw. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na trabaho. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at electronics... masamang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masama ang panahon. Siguraduhin mong tuyo ang iyong device, {player}.",
        },
        Fog = {
            "Hindi ko makita ang depth sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
