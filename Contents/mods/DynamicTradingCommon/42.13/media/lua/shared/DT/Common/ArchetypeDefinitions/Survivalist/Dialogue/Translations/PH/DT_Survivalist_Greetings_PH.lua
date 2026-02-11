require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Survivalist", "Greetings", {
    PH = {
        Default = {
            "Masyado kang maingay, {player.firstname}. Ano'ng kailangan mo?",
            "Binabantayan ang treeline... oh, ikaw pala. Magsalita ka na, {player}.",
            "Manatiling nakayuko kung gusto mong mabuhay. Kailangan mo ba ng supplies, {player.firstname}?",
            "Nagugunaw na ang mundo, pero ang trade ay tuloy pa rin. Ano'ng balita?",
            "Tinitingnan ang perimeter. Ligtas ka ba diyan sa labas, {player.firstname}?"
        },
        Morning = {
            "Delikado ang liwanag ng umaga. Bilisan mo lang, {player.firstname}.",
            "Sikat na ang araw, may mga tracker na sa labas. Ano'ng kailangan mo, {player}?",
        },
        Evening = {
            "Palubog na ang araw, bantayan ang mga anino. Ano'ng balita, {player.firstname}?",
            "Magandang gabi, {player}. Sana ay may ligtas kang matutuluyan ngayong gabi.",
        },
        Night = {
            "Bulong lang. May mga bagay-bagay dito sa labas. Ano'ng gusto mo, {player.firstname}?",
            "Ang gabi ay para sa mga patay. Bilisan mo ang pagsasalita, {player}."
        },
        Raining = {
            "Tinatakpan ng ulan ang mga tunog. Masarap lumakad, pero mahirap makarinig. Ano'ng balita, {player}?",
            "Masamang panahon. Panatilihing tuyo ang gunpowder mo, {player.firstname}."
        },
        Fog = {
            "Ang hamog ang matalik na kaibigan ng mamamatay-tao. Bantayan ang likuran mo, {player.firstname}.",
            "Limang talampakan lang ang nakikita ko. Nandiyan ka pa ba, {player}?"
        }
    }
})
