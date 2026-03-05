-- =============================================================================
-- DYNAMIC TRADING: VEHICLE - BODY
-- =============================================================================
-- Root Category: Vehicle
-- Sub Category: Body
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.EngineDoor1",       tags={"Vehicle.Body.Hood", "Quality.Standard", "Rarity.Common"},          basePrice=70,  stockRange={min=0, max=2} },
    { item="Base.EngineDoor2",       tags={"Vehicle.Body.Hood", "Quality.Heavy", "Rarity.Uncommon"},            basePrice=95,  stockRange={min=0, max=2} },
    { item="Base.EngineDoor3",       tags={"Vehicle.Body.Hood", "Quality.Sport", "Rarity.Rare"},                basePrice=130, stockRange={min=0, max=1} },
    { item="Base.FrontCarDoor1",        tags={"Vehicle.Body.Door", "Quality.Standard", "Rarity.Common"},   basePrice=90,  stockRange={min=0, max=2} },
    { item="Base.FrontCarDoor2",        tags={"Vehicle.Body.Door", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=120, stockRange={min=0, max=2} },
    { item="Base.FrontCarDoor3",        tags={"Vehicle.Body.Door", "Quality.Sport", "Rarity.Rare"},     basePrice=160, stockRange={min=0, max=1} },
    { item="Base.FrontWindow1",      tags={"Vehicle.Body.Window", "Quality.Standard", "Rarity.Common"},        basePrice=25,  stockRange={min=1, max=4} },
    { item="Base.FrontWindow2",      tags={"Vehicle.Body.Window", "Quality.Heavy", "Rarity.Common"},           basePrice=35,  stockRange={min=1, max=3} },
    { item="Base.FrontWindow3",      tags={"Vehicle.Body.Window", "Quality.Sport", "Rarity.Uncommon"},         basePrice=50,  stockRange={min=0, max=2} },
    { item="Base.RearCarDoor1",         tags={"Vehicle.Body.Door", "Quality.Standard", "Rarity.Common"},   basePrice=90,  stockRange={min=0, max=2} },
    { item="Base.RearCarDoor2",         tags={"Vehicle.Body.Door", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=120, stockRange={min=0, max=2} },
    { item="Base.RearCarDoor3",         tags={"Vehicle.Body.Door", "Quality.Sport", "Rarity.Rare"},     basePrice=160, stockRange={min=0, max=1} },
    { item="Base.RearCarDoorDouble1",   tags={"Vehicle.Body.Door", "Quality.Standard", "Rarity.Common"},   basePrice=150, stockRange={min=0, max=2} },
    { item="Base.RearCarDoorDouble2",   tags={"Vehicle.Body.Door", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=200, stockRange={min=0, max=1} },
    { item="Base.RearCarDoorDouble3",   tags={"Vehicle.Body.Door", "Quality.Sport", "Rarity.Rare"},     basePrice=270, stockRange={min=0, max=1} },
    { item="Base.RearWindow1",       tags={"Vehicle.Body.Window", "Quality.Standard", "Rarity.Common"},        basePrice=25,  stockRange={min=1, max=4} },
    { item="Base.RearWindow2",       tags={"Vehicle.Body.Window", "Quality.Heavy", "Rarity.Common"},           basePrice=35,  stockRange={min=1, max=3} },
    { item="Base.RearWindow3",       tags={"Vehicle.Body.Window", "Quality.Sport", "Rarity.Uncommon"},         basePrice=50,  stockRange={min=0, max=2} },
    { item="Base.RearWindshield1",   tags={"Vehicle.Body.Windshield", "Quality.Standard", "Rarity.Common"},    basePrice=60,  stockRange={min=0, max=2} },
    { item="Base.RearWindshield2",   tags={"Vehicle.Body.Windshield", "Quality.Heavy", "Rarity.Uncommon"},  basePrice=80,  stockRange={min=0, max=2} },
    { item="Base.RearWindshield3",   tags={"Vehicle.Body.Windshield", "Quality.Sport", "Rarity.Rare"},      basePrice=110, stockRange={min=0, max=1} },
    { item="Base.TrunkDoor1",           tags={"Vehicle.Body.Trunk", "Quality.Standard", "Rarity.Common"},   basePrice=80,  stockRange={min=0, max=2} },
    { item="Base.TrunkDoor2",           tags={"Vehicle.Body.Trunk", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=110, stockRange={min=0, max=2} },
    { item="Base.TrunkDoor3",           tags={"Vehicle.Body.Trunk", "Quality.Sport", "Rarity.Rare"},     basePrice=150, stockRange={min=0, max=1} },
    { item="Base.Windshield1",       tags={"Vehicle.Body.Windshield", "Quality.Standard", "Rarity.Common"},    basePrice=70,  stockRange={min=0, max=2} },
    { item="Base.Windshield2",       tags={"Vehicle.Body.Windshield", "Quality.Heavy", "Rarity.Uncommon"},  basePrice=95,  stockRange={min=0, max=2} },
    { item="Base.Windshield3",       tags={"Vehicle.Body.Windshield", "Quality.Sport", "Rarity.Rare"},      basePrice=130, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Vehicle/Body Registry Loaded.")
