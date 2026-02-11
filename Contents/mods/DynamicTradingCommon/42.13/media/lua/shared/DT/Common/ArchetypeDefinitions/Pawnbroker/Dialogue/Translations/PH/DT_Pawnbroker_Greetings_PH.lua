require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Pawnbroker", "Greetings", {
    PH = {
        Default = {
            "Patingin nga ng dala mo, {player.firstname}. Huwag sana basura.",
            "Ina-appraise lang ang mga labi. Kailangan mo ba ng pera o kasunduan, {player}?",
            "Lahat ay may presyo, pati ikaw. Ano'ng magagawa ko para sa'yo, {player.firstname}?",
            "Tinitingnan ang vault. Bibili ka ba o tumitingin lang, {player}?",
            "May mga bagong collectible ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang appraisal. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, tahimik ang tindahan. Handa ka na ba makipag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para i-lock ang safe. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana ay authentic ang iyong mga gamit.",
        },
        Night = {
            "Nag-a-appraise sa ilalim ng kandila... delikado. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa mga tahimik na valuation. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at ginto... masamang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Panatilihing tuyo ang iyong mga mamahaling gamit, {player}."
        },
        Fog = {
            "Hindi ko makita ang hallmark sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
