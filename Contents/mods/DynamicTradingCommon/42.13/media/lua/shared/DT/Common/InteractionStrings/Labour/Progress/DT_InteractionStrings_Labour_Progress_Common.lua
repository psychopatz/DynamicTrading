require "DT/Common/InteractionStrings/DT_InteractionStrings"

DynamicTrading.RegisterInteractionStrings("Labour", "Progress", {
    Common = {
        TravelToSite = {
            stateLabel = "Walking",
            activeText = "Walking to {place}",
            captionText = "Arrives in {eta}",
            color = { r = 0.55, g = 0.55, b = 0.55 }
        },
        TravelToHome = {
            stateLabel = "Walking",
            activeText = "Walking home",
            captionText = "Home in {eta}",
            color = { r = 0.55, g = 0.55, b = 0.55 }
        }
    }
})
