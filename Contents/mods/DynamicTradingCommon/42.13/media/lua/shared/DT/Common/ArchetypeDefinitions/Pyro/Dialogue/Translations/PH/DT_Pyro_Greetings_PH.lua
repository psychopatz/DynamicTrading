require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Pyro", "Greetings", {
    PH = {
        Default = {
            "May apoy ka ba, {player.firstname}? Mas maganda ang lahat kapag nasusunog.",
            "Naglalaro lang ng posporo. Kailangan mo ba ng gasolina o pampasabog, {player}?",
            "Malamig ang mundo, painitin natin 'to. Ano'ng magagawa ko para sa'yo, {player.firstname}?",
            "Pinapanood ang mga baga. Bibili ka ba o tumitingin lang, {player}?",
            "May bagong accelerant ako ngayon. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Maagang campfire. Ano'ng kailangan mo, {player.firstname}?",
            "Sikat na ang araw, patay na ang apoy. Handa ka na bang mag-trade, {player}?",
        },
        Evening = {
            "Palubog na ang araw, oras na para liwanagan ang gabi. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Sana'y maliwanag ang iyong mga apoy.",
        },
        Night = {
            "Pagsunog sa ilalim ng buwan... nakakahumaling. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa tahimik na pagsunog. Magsalita ka lang, {player}."
        },
        Raining = {
            "Ulan at apoy... masamang kombinasyon. Ano'ng balita, {player.firstname}?",
            "Masamang panahon. Panatilihing tuyo ang iyong tinder, {player}."
        },
        Fog = {
            "Hindi ko makita ang liwanag sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang may multo sa panahon na 'to. Nandiyan ka pa ba, {player}?"
        }
    }
})
