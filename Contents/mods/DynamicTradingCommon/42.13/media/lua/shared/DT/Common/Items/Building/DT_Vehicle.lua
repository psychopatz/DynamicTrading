-- ============================================================================
-- Building Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Building.Vehicle] [Rarity.Rare] (34 items)
    { item="Base.EngineDoor1", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.EngineDoor2", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.EngineDoor3", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.EngineParts", basePrice=7, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.FrontWindow1", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.FrontWindow2", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.FrontWindow3", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.HoodOrnament_Badger", basePrice=2, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.HoodOrnament_Beaver", basePrice=2, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.HoodOrnament_Spiffo", basePrice=2, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Jack", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.LugWrench", basePrice=34, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.ModernSuspension1", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.ModernSuspension2", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.ModernSuspension3", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.NormalSuspension1", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.NormalSuspension2", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.NormalSuspension3", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.RearCarDoorDouble1", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.RearCarDoorDouble2", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.RearCarDoorDouble3", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.RearWindow1", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.RearWindow2", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.RearWindow3", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.RearWindshield1", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.RearWindshield2", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.RearWindshield3", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.TirePump", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.TrunkDoor1", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.TrunkDoor2", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.TrunkDoor3", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.Windshield1", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.Windshield2", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.Windshield3", basePrice=1, tags={"Building.Vehicle", "Rarity.Rare"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Vehicle Registry Complete")
