require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Mechanic", "Greetings", {
    PH = {
        Default = {
            "Sandali lang, pinupunasan ko lang ang kamay ko. Ano'ng problema sa makina, {player.firstname}?",
            "Tinitingnan lang ang mga balbula. Kailangan mo ba ng tune-up o piyesa lang, {player}?",
            "Parang may kumakatok sa piston... ay, ikaw lang pala. Uy, {player.firstname}.",
            "Bukas ang garahe. Ano'ng status ng project mo, {player}?",
            "Grasa, langis, at marami pang langis. Ano'ng kailangan mo, {player.firstname}?"
        },
        Morning = {
            "Sikat na ang araw, umaandar na ang mga compressor. Ano'ng gagawin natin ngayon, {player.firstname}?",
            "Magandang umaga, {player}. Handa ka na bang madumihan ang mga kamay mo?"
        },
        Evening = {
            "Magliligpit na ako ng mga gamit mamaya. Bilisan mo, {player.firstname}.",
            "Palubog na ang araw, pero hindi natatapos ang trabaho. Ano'ng balita, {player}?"
        },
        Night = {
            "Nagkukumpuni sa dilim... hindi maganda. May kailangan ka ba, {player.firstname}?",
            "Malapit nang maubos ang baterya ng flashlight. Sabihin mo na ang kailangan mo, {player}."
        },
        Raining = {
            "Kinalawang ang lahat dahil sa ulan. Inis na panahon 'to. Ano'ng dala mo, {player.firstname}?",
            "Masama ang mahalumigmig na hangin sa mga filter. Panatilihing mong tuyo, {player}."
        },
        Fog = {
            "Hindi ko makita ang bumper sa harap ko. Ingat sa mga kanto, {player.firstname}.",
            "Zero visibility. Ingat sa pagmamaneho, {player}. Ano'ng maitutulong ko sa'yo?"
        }
    }
})
