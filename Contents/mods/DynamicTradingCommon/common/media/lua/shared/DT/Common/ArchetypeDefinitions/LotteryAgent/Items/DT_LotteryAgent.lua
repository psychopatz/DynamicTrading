require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("LotteryAgent", {
    name = "Lottery Agent",
    allocations = {
        { tags={"Resource.Material.Paper"}, count = 12 },
        { tags={"Misc.General"}, count = 6 },
        { tags={"Literature.Media"}, count = 4 },
        { item = "Base.BluePen", count = 2 },
    },
    expertTags = { "Resource.Material.Paper", "Misc.General", "Literature.Media" },
    wants = {
        ["Food.NonPerishable.Sweets"] = 1.2,
        ["Quality.Luxury"] = 1.15,
        ["Misc.General"] = 1.1,
    },
    forbid = { "Quality.Waste", "Weapon.Explosive", "Resource.Fuel" },
    contactReputationRequired = 0,
    neverRecruitable = true,
    specialTradeProfile = "lottery",
})

end
