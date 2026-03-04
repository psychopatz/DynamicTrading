require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Pharmacist", {
    name = "Pharmacist",
    allocations = {
        { tags={"Medical.Utility.Pill"}, count = 8 },
        { tags={"Medical.Tool"}, count = 5 },
        { tags={"Medical"}, count = 4 },
        { tags={"Tool.Cleaning"}, count = 3 }
    },
    wants = {
        ["Medical.Herb"] = 1.3,
        ["Junk.Paper"] = 1.2,
        ["Container"] = 1.2
    },
    forbid = { "Weapon", "Dirty", "Rotten" }
})

end
