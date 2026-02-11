require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Janitor", "Greetings", {
    PH = {
        Default = {
            "Ingat sa basang sahig, {player.firstname}. Ano ang dumi ngayon?",
            "Pinapanatili ko lang na maayos ang lahat. Kailangan mo ba ng sabon o gamit, {player}?",
            "Kailangang may maglinis ng apocalypse na 'to. Ano'ng magagawa ko para sa'yo, {player.firstname}?",
            "Tinitingnan ko lang ang gamit sa panlinis. Bibili ka ba o tumitingin lang, {player}?",
            "May bagong bleach ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pagwawalis. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, tahimik ang mga pasilyo. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para itapon ang mga basura. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana malinis ang iyong mga dingding.",
        },
        Night = {
            "Naglalampaso sa dilim... hindi gaanong maganda. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na pagkuskos. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at putik... dagdag na trabaho. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Punasan mo ang mga paa mo, {player}."
        },
        Fog = {
            "Hindi ko makita ang mga batik sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
