require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Quartermaster", "Greetings", {
    PH = {
        Default = {
            "Ang mga supply ay ang buhay ng misyon, {player.firstname}. Ano'ng requisition natin?",
            "Tinitingnan lang ang manifest. Kailangan mo ba ng gamit o supply, {player}?",
            "Logistics ang susi sa survival. Ano'ng magagawa ko para sa'yo, {player.firstname}?",
            "Tinitingnan ang imbentaryo. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong kargamento ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang roll call. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, abala na ang warehouse. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para i-finalize ang manifest. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana ay puno ang iyong imbakan.",
        },
        Night = {
            "Logistics sa pang-gabing shift? Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na pag-iimbentaryo. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at kargamento... masamang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Panatilihing tuyo ang iyong mga kahon, {player}."
        },
        Fog = {
            "Hindi ko makita ang mga pallet sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
