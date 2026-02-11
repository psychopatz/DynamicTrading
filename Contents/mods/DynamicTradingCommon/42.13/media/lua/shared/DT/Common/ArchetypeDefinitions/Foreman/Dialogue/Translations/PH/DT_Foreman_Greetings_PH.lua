require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Foreman", "Greetings", {
    PH = {
        Default = {
            "Nasa oras tayo, {player.firstname}. Ano'ng status?",
            "Busy ang site. Ikaw ba ang may dala ng supplies, {player}?",
            "Bilisan mo, {player.firstname}. May deadline kami.",
            "Nagtatrabaho ang crew. Ano kailangan MO, {player}?",
            "Tinitingnan ko ang mga blueprint. Magsalita ka lang, {player.firstname}."
        },
        Morning = {
            "Morning muster. Magtrabaho na kayo, {player.firstname}.",
            "Gising na ang lahat, humahampas na ang mga martilyo. Ano'ng balita, {player}?",
        },
        Evening = {
            "Pagtapos na ang araw. Tapusin na 'yan, {player.firstname}.",
            "Magliligpit na kami sa site. Ano kailangan mo, {player}?",
        },
        Night = {
            "Late shift ah, {player.firstname}? Mag-ingat ka sa paglalakad.",
            "Naka-shift na ang night crew. Bilisan mo lang, {player}.",
        },
        Raining = {
            "Naantala ang pagbuhos dahil sa ulan. Buwisit. Ano'ng dala mo, {player.firstname}?",
            "Puno ng putik ang paligid. Panatilihing malinis ang iyong bota, {player}.",
        },
        Fog = {
            "Hindi makita ang crane. Safety first, {player.firstname}.",
            "Masyadong makapal ang hamog. Siguraduhing kita ka sa labas, {player}."
        }
    }
})
