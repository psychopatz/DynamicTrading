require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Librarian", "Greetings", {
    PH = {
        Default = {
            "Huwag maingay, {player.firstname}. Pinangangalagaan ang kaalaman. Ano'ng kailangan mo?",
            "Nagkakatalogo lang ng mga nakaligtas. Kailangan mo ba ng impormasyon o gamit, {player}?",
            "Ang mundong walang libro ay mundong walang kaluluwa. Ano'ng maitutulong ko sa'yo, {player.firstname}?",
            "Tinitingnan lang ang mga archive. Bibili ka ba o tumitingin lang, {player}?",
            "May bagong tinta ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang pag-aaral. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, bukas na ang mga archive. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para pag-isipan ang mga natutunan sa araw na ito. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana ay matalas ang iyong isip.",
        },
        Night = {
            "Nagbabasa sa liwanag ng kandila... nakapagbibigay-liwanag. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa malalim na pananaliksik. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at pergamino... huwag paghaluin. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Panatilihing tuyo ang iyong mga libro, {player}."
        },
        Fog = {
            "Hindi ko makita ang mga index sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
