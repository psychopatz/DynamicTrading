require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("LotteryAgent", {
    module = "DynamicTradingCommon",
    name = "Lottery Agent",
    preferredFactionID = "Independent",
    allowedFactions = { "Independent" },
    allocations = {
        { tags={"Resource.Material.Paper"}, count = 12 },
        { tags={"Misc.General"}, count = 6 },
        { tags={"Literature.Media"}, count = 4 },
        { module = "DynamicTradingCommon",  item = "Base.BluePen", count = 2 },
    },
    expertTags = { "Resource.Material.Paper", "Misc.General", "Literature.Media" },
    wants = {
        ["Food.NonPerishable.Sweets"] = 1.2,
        ["Quality.Luxury"] = 1.15,
        ["Misc.General"] = 1.1,
    },
    forbid = { "Quality.Waste", "Weapon.Explosive", "Resource.Fuel" },
    specialTradeProfile = "lottery",
    specialization = {
        role = "lottery",
        contactReputationRequired = 0,
        neverRecruitable = true,
        stockSourceArchetypeID = "LotteryAgent",
        inventoryStockKeywords = { "lottery", "lotto", "scratchticket" },
        fallbackStockKeywords = { "lottery", "lotto", "scratchticket" },
        rosterPool = {
            minCount = 1,
            priority = 15,
            allowedFactions = { "Independent" },
        },
    },
})

end
