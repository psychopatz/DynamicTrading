require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Butcher", "Greetings", {
    PH = {
        Default = {
            "O? Busy ako sa pagkatay. Ano'ng kailangan mo, {player.firstname}?",
            "Mag-ingat ka sa daliri mo. Nandito ka ba para sa magagandang hiwa, {player}?",
            "Puno ang katayan ko ngayon. Bilisan mo lang.",
            "May mga sariwang karne ako... o kahit paano, karne. Ano'ng balita, {player.firstname}?",
            "Matatalim na talim, matitibay na kamay. Ano'ng maitutulong ko sa'yo, {player}?"
        },
        Morning = {
            "Sikat na ang araw, matatalim na ang mga kutsilyo ko. Ang maaga ay nakakakuha ng magagandang hiwa, {player.firstname}.",
            "Magandang umaga, {player}. Katatapos ko lang sa unang paghahanda. Bibili ka ba?",
        },
        Evening = {
            "Lulubog na ang araw, naglilinis na ako ng dugo. Magsalita ka na, {player.firstname}.",
            "Gabi na para sa trade, {player}. Magliligpit na sana ako ng mga gamit.",
        },
        Night = {
            "Madilim sa labas. Sana hindi ikaw ang susunod na kakatayin, {player.firstname}.",
            "Delikadong magtrabaho sa dilim. Sana importante 'to, {player}.",
        },
        Raining = {
            "Hinuhugasan ng ulan ang mga kanal. Mahirap panatilihing tuyo ang sahig. Ano'ng balita, {player}?",
            "Masama ang panahon. Sana hindi basa ang mga gamit mo, {player.firstname}.",
        },
        Fog = {
            "Hindi ko makita ang dulo ng sarili kong kutsilyo sa sobrang hamog. Mag-ingat ka, {player}.",
            "Tahimik na parang katayan dito ngayon. Nandiyan ka ba, {player}?"
        }
    }
})
