require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Carpenter", "Greetings", {
    PH = {
        Default = {
            "Masukat nang dalawang beses, pumutol nang isa, {player.firstname}. Ano'ng proyekto natin?",
            "Tinatalian ko lang ang frame. Kailangan mo ba ng kahoy o gamit, {player}?",
            "Giba-giba na ang mundo, pero kaya nating itayong muli. Ano'ng maitutulong ko sa'yo, {player.firstname}?",
            "Tinitingnan ko lang ang mga tabla. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong cedar ako ngayon. Ano kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang paglalagare. Ano kailangan mo, {player.firstname}?",
            "Gising na ang lahat, busy na sa shop. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Lulubog na ang araw, oras na para ligpitin ang pait. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana matibay ang iyong mga istruktura.",
        },
        Night = {
            "Paglalagare sa dilim... hindi maganda. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na pagkakarpintero. Magsalita ka lang, {player}.",
        },
        Raining = {
            "Ulan at kahoy... masamang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Siguraduhin mong tuyo ang iyong mga tabla, {player}.",
        },
        Fog = {
            "Hindi ko makita ang level sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
