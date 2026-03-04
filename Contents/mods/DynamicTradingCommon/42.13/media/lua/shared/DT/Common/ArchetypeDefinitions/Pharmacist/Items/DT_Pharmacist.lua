require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Pharmacist", {
    name = "Pharmacist",
    allocations = {
        { tags={"Medical.General.Pills"}, count = 8 },
        { tags={"Medical.Tool"}, count = 5 },
        { tags={"Medical.General"}, count = 4 },
        { tags={"Tool.Cleaning.General"}, count = 3 }
    },
    wants = {
        ["Medical.Healthcare.Botanical"] = 1.3,
        ["Resource.Material.Paper"] = 1.2,
        ["Container.General"] = 1.2
    },
    forbid = { "Weapon.General", "Quality.Dirty", "Quality.Rotten" }
})

end
