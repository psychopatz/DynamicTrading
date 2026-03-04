require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="DTQuest.PackageSmallQuest",   tags={"Quest.Courier.Small"},   basePrice=0, stockRange={min=0, max=0} },
    { item="DTQuest.PackageMediumQuest",  tags={"Quest.Courier.Medium"},  basePrice=0, stockRange={min=0, max=0} },
    { item="DTQuest.PackageLargeQuest",   tags={"Quest.Courier.Large"},   basePrice=0, stockRange={min=0, max=0} },
    { item="DTQuest.PackageFragileQuest", tags={"Quest.Courier.Fragile"}, basePrice=0, stockRange={min=0, max=0} },
    { item="DTQuest.PackageMedicalQuest", tags={"Quest.Courier.Medical"}, basePrice=0, stockRange={min=0, max=0} },
    { item="DTQuest.PackageMilitaryQuest",tags={"Quest.Courier.Military"},basePrice=0, stockRange={min=0, max=0} },
    { item="DTQuest.PackageGiftQuest",    tags={"Quest.NPC.Gift"},        basePrice=0, stockRange={min=0, max=0} },
})

print("[DynamicTrading] Quest Items Registry Complete.")
