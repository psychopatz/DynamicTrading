require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Scavenger", "Greetings", {
    PH = {
        Default = {
            "May nahanap akong magandang loot! Gusto mo bang makita? Oh, ikaw pala {player.firstname}.",
            "Nagkakalkal lang sa mga tambak... Ano'ng kailangan mo, {player}?",
            "Ang basura ng isa, kayamanan ng iba, di ba? Ano'ng balita, {player.firstname}?",
            "Naghahanap sa mga guhong gusali. Nandito ka ba para sa mga nahanap ko, {player}?",
            "Tingnan mo 'to... oh, sandali, bibili ka ba? Hey {player}!"
        },
        Morning = {
            "Nagbubunga ang maagang paghahanap. Ano'ng kailangan mo, {player.firstname}?",
            "Magandang umaga, {player}. Kagagaling lang sa raid. Gusto mo bang makipag-trade?",
        },
        Evening = {
            "Palubog na ang araw, oras na para magtago. Mabilisang trade lang ba, {player.firstname}?",
            "Magandang gabi, {player}. Maraming nahanap na loot ngayon. Tingnan mo.",
        },
        Night = {
            "Ang gabi ay para sa mga matatapang. Ano'ng gusto mo, {player.firstname}?",
            "Mahirap magkalkal sa dilim. Magsalita ka lang, {player}."
        },
        Raining = {
            "Nabubulok ang mga basura sa ulan. Nakakainis. Ano'ng balita, {player.firstname}?",
            "Masamang panahon para mag-scavenge. Ano'ng kailangan mo, {player}?",
        },
        Fog = {
            "Hindi ko makita ang mga loot sa sobrang hamog. Ano'ng balita, {player.firstname}?",
            "Parang ghost town sa labas. Nandiyan ka pa ba, {player}?"
        }
    }
})
