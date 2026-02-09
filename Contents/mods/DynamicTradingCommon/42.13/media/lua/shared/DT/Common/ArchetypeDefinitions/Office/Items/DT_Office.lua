require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Office", {
    name = "White Collar",
    allocations = {
        ["Office"] = 8,
        ["Paper"] = 6,
        ["Electronics"] = 4,
        ["Suit"] = 2
    },
    wants = {
        ["Coffee"] = 2.0,
        ["Sweets"] = 1.3,
        ["Tobacco"] = 1.2
    },
    forbid = { "Farm", "Heavy", "Dirty" }
})

end
