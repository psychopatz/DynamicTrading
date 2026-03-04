require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Pharmacist", {
    name = "Pharmacist",
    allocations = {
        { tags = {"Pill"}, count = 8 },
        { tags = {"Pharmacist"}, count = 5 },
        { tags = {"Medical"}, count = 4 },
        { tags = {"Clean"}, count = 3 }
    },
    wants = {
        ["Herb"] = 1.3,
        ["Paper"] = 1.2,
        ["Container"] = 1.2
    },
    forbid = { "Weapon", "Dirty", "Rotten" }
})

end
