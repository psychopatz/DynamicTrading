require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Tailor", "Greetings", {
    PH = {
        Default = {
            "Mag-ingat sa mga karayom, {player.firstname}. Ano'ng thread count natin?",
            "Mukhang medyo gulanit ka na, {player}. Kailangan mo ba ng patch o bagong damit?",
            "Magbihis nang maayos, kahit sa apocalypse. Ano'ng magagawa ko para sa'yo, {player.firstname}?",
            "Sinusukat ang stock. Bibili ka ba o tumitingin lang, {player}?",
            "May mga magagandang tela ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pananahi. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, nagsimula na ang tahi. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, mahirap nang makakita ng tahi. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana ay matibay ang iyong mga gamit.",
        },
        Night = {
            "Nanahi sa ilalim ng kandila... mahirap. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na trabaho. Magsalita ka lang, {player}."
        },
        Raining = {
            "Nabubulok ang cotton sa ulan. Grabe naman. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Sana ay kasing-tibay ng raincoat ang damit mo, {player}."
        },
        Fog = {
            "Hindi ko makita ang mga pattern sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
