require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({

    -- =============================================================================
    -- 1. GENERAL MAINTENANCE & FUEL
    -- =============================================================================
    -- Logic: Engine parts are universal currency for mechanics.
    -- Fuel containers are "Liquid Gold" during the Winter Event.

    { item="Base.EngineParts",       tags={"CarPart", "Mechanic", "Common"}, basePrice=35,  stockRange={min=5, max=20} },
    
    -- FUEL CONTAINERS
    { item="Base.PetrolCan",         tags={"Tool", "Fuel", "Mechanic", "Common"}, basePrice=100, stockRange={min=1, max=4} },
    { item="Base.EmptyPetrolCan",    tags={"Tool", "Fuel", "Mechanic", "Common"}, basePrice=40,  stockRange={min=1, max=3} },
    
    -- IMPROVISED FUEL (Bottles)
    { item="Base.PetrolBleachBottle",tags={"Fuel", "Improvised", "Common"},  basePrice=18,  stockRange={min=0, max=5} },
    { item="Base.WhiskeyPetrol",     tags={"Fuel", "Improvised", "Common"},  basePrice=20,  stockRange={min=0, max=5} },
    { item="Base.PetrolPopBottle",   tags={"Fuel", "Improvised", "Common"},  basePrice=15,  stockRange={min=0, max=5} },
    { item="Base.WinePetrol",        tags={"Fuel", "Improvised", "Common"},  basePrice=18,  stockRange={min=0, max=5} },
    { item="Base.WaterBottlePetrol", tags={"Fuel", "Improvised", "Common"},  basePrice=15,  stockRange={min=0, max=5} },

    -- =============================================================================
    -- 2. BRAKING SYSTEMS
    -- =============================================================================
    -- Logic: Old = Cheap. Normal = Standard. Modern = Expensive.
    -- 1=Standard, 2=Heavy Duty, 3=Sport.

    -- OLD (Budget)
    { item="Base.OldBrake1",         tags={"CarPart", "Mechanic", "Common"},          basePrice=25, stockRange={min=1, max=4} },
    { item="Base.OldBrake2",         tags={"CarPart", "Mechanic", "Heavy", "Common"}, basePrice=35, stockRange={min=1, max=3} },
    { item="Base.OldBrake3",         tags={"CarPart", "Mechanic", "Sport", "Common"}, basePrice=45, stockRange={min=0, max=2} },
    
    -- NORMAL (Standard)
    { item="Base.NormalBrake1",      tags={"CarPart", "Mechanic", "Uncommon"},        basePrice=55, stockRange={min=1, max=4} },
    { item="Base.NormalBrake2",      tags={"CarPart", "Mechanic", "Heavy", "Uncommon"},basePrice=75, stockRange={min=1, max=3} },
    { item="Base.NormalBrake3",      tags={"CarPart", "Mechanic", "Sport", "Uncommon"},basePrice=95, stockRange={min=0, max=2} },
    
    -- MODERN (High Performance)
    { item="Base.ModernBrake1",      tags={"CarPart", "Mechanic", "Rare"},            basePrice=110, stockRange={min=0, max=2} },
    { item="Base.ModernBrake2",      tags={"CarPart", "Mechanic", "Heavy", "Rare"},   basePrice=150, stockRange={min=0, max=1} },
    { item="Base.ModernBrake3",      tags={"CarPart", "Mechanic", "Sport", "Rare"},   basePrice=170, stockRange={min=0, max=1} },

    -- =============================================================================
    -- 3. BATTERIES & HOODS
    -- =============================================================================
    -- Logic: Batteries are heavy. Sport batteries (Type 3) are lighter but rarer.
    
    -- BATTERIES
    { item="Base.CarBattery1",       tags={"CarPart", "Mechanic", "Heavy", "Common"},   basePrice=80,  stockRange={min=1, max=3} },
    { item="Base.CarBattery2",       tags={"CarPart", "Mechanic", "Heavy", "Uncommon"}, basePrice=110, stockRange={min=1, max=2} },
    { item="Base.CarBattery3",       tags={"CarPart", "Mechanic", "Sport", "Rare"},     basePrice=160, stockRange={min=0, max=1} },
    
    -- HOODS
    { item="Base.EngineDoor1",       tags={"CarPart", "Heavy", "Common"},             basePrice=70,  stockRange={min=0, max=2} },
    { item="Base.EngineDoor2",       tags={"CarPart", "Heavy", "Uncommon"},           basePrice=95,  stockRange={min=0, max=2} },
    { item="Base.EngineDoor3",       tags={"CarPart", "Sport", "Rare"},               basePrice=130, stockRange={min=0, max=1} },

    -- =============================================================================
    -- 4. BODYWORK (DOORS & TRUNKS)
    -- =============================================================================
    -- Logic: Extremely heavy items. Hard to transport, so stock is low.
    
    -- FRONT DOORS
    { item="Base.FrontCarDoor1",        tags={"CarPart", "Heavy", "Common"},   basePrice=90,  stockRange={min=0, max=2} },
    { item="Base.FrontCarDoor2",        tags={"CarPart", "Heavy", "Uncommon"}, basePrice=120, stockRange={min=0, max=2} },
    { item="Base.FrontCarDoor3",        tags={"CarPart", "Sport", "Rare"},     basePrice=160, stockRange={min=0, max=1} },
    
    -- REAR DOORS
    { item="Base.RearCarDoor1",         tags={"CarPart", "Heavy", "Common"},   basePrice=90,  stockRange={min=0, max=2} },
    { item="Base.RearCarDoor2",         tags={"CarPart", "Heavy", "Uncommon"}, basePrice=120, stockRange={min=0, max=2} },
    { item="Base.RearCarDoor3",         tags={"CarPart", "Sport", "Rare"},     basePrice=160, stockRange={min=0, max=1} },
    
    -- DOUBLE DOORS (Vans/Ambulances)
    { item="Base.RearCarDoorDouble1",   tags={"CarPart", "Heavy", "Common"},   basePrice=150, stockRange={min=0, max=2} },
    { item="Base.RearCarDoorDouble2",   tags={"CarPart", "Heavy", "Uncommon"}, basePrice=200, stockRange={min=0, max=1} },
    { item="Base.RearCarDoorDouble3",   tags={"CarPart", "Heavy", "Rare"},     basePrice=270, stockRange={min=0, max=1} },
    
    -- TRUNK LIDS
    { item="Base.TrunkDoor1",           tags={"CarPart", "Heavy", "Common"},   basePrice=80,  stockRange={min=0, max=2} },
    { item="Base.TrunkDoor2",           tags={"CarPart", "Heavy", "Uncommon"}, basePrice=110, stockRange={min=0, max=2} },
    { item="Base.TrunkDoor3",           tags={"CarPart", "Sport", "Rare"},     basePrice=150, stockRange={min=0, max=1} },

    -- =============================================================================
    -- 5. GAS TANKS
    -- =============================================================================
    -- Logic: Capacity is king. Big tanks are highly sought after.
    
    -- SMALL
    { item="Base.SmallGasTank1",     tags={"CarPart", "Mechanic", "Common"},          basePrice=60,  stockRange={min=0, max=2} },
    { item="Base.SmallGasTank2",     tags={"CarPart", "Mechanic", "Heavy", "Common"}, basePrice=85,  stockRange={min=0, max=2} },
    { item="Base.SmallGasTank3",     tags={"CarPart", "Mechanic", "Sport", "Rare"},   basePrice=110, stockRange={min=0, max=1} },
    
    -- STANDARD
    { item="Base.NormalGasTank1",    tags={"CarPart", "Mechanic", "Common"},          basePrice=100, stockRange={min=0, max=2} },
    { item="Base.NormalGasTank2",    tags={"CarPart", "Mechanic", "Heavy", "Uncommon"},basePrice=135, stockRange={min=0, max=2} },
    { item="Base.NormalGasTank3",    tags={"CarPart", "Mechanic", "Sport", "Rare"},   basePrice=180, stockRange={min=0, max=1} },
    
    -- BIG (High Capacity)
    { item="Base.BigGasTank1",       tags={"CarPart", "Mechanic", "Uncommon"},        basePrice=160, stockRange={min=0, max=1} },
    { item="Base.BigGasTank2",       tags={"CarPart", "Mechanic", "Heavy", "Rare"},   basePrice=250, stockRange={min=0, max=1} },
    { item="Base.BigGasTank3",       tags={"CarPart", "Mechanic", "Sport", "Rare"},   basePrice=300, stockRange={min=0, max=1} },

    -- =============================================================================
    -- 6. EXHAUST & SUSPENSION
    -- =============================================================================
    
    -- MUFFLERS (Quietness = Survival)
    { item="Base.OldCarMuffler1",    tags={"CarPart", "Mechanic", "Common"},          basePrice=30,  stockRange={min=1, max=3} },
    { item="Base.OldCarMuffler2",    tags={"CarPart", "Mechanic", "Heavy", "Common"}, basePrice=40,  stockRange={min=1, max=2} },
    { item="Base.OldCarMuffler3",    tags={"CarPart", "Mechanic", "Sport", "Uncommon"},basePrice=55,  stockRange={min=0, max=2} },
    { item="Base.NormalCarMuffler1", tags={"CarPart", "Mechanic", "Uncommon"},        basePrice=60,  stockRange={min=1, max=3} },
    { item="Base.NormalCarMuffler2", tags={"CarPart", "Mechanic", "Heavy", "Uncommon"},basePrice=80,  stockRange={min=1, max=2} },
    { item="Base.NormalCarMuffler3", tags={"CarPart", "Mechanic", "Sport", "Rare"},   basePrice=110, stockRange={min=0, max=2} },
    { item="Base.ModernCarMuffler1", tags={"CarPart", "Mechanic", "Rare"},            basePrice=120, stockRange={min=0, max=2} },
    { item="Base.ModernCarMuffler2", tags={"CarPart", "Mechanic", "Heavy", "Rare"},   basePrice=165, stockRange={min=0, max=1} },
    { item="Base.ModernCarMuffler3", tags={"CarPart", "Mechanic", "Sport", "Rare"},   basePrice=230, stockRange={min=0, max=1} },

    -- SUSPENSION
    { item="Base.NormalSuspension1", tags={"CarPart", "Mechanic", "Common"},          basePrice=40,  stockRange={min=1, max=4} },
    { item="Base.NormalSuspension2", tags={"CarPart", "Mechanic", "Heavy", "Uncommon"},basePrice=55,  stockRange={min=1, max=3} },
    { item="Base.NormalSuspension3", tags={"CarPart", "Mechanic", "Sport", "Rare"},   basePrice=75,  stockRange={min=0, max=2} },
    { item="Base.ModernSuspension1", tags={"CarPart", "Mechanic", "Rare"},            basePrice=90,  stockRange={min=0, max=2} },
    { item="Base.ModernSuspension2", tags={"CarPart", "Mechanic", "Heavy", "Rare"},   basePrice=125, stockRange={min=0, max=1} },
    { item="Base.ModernSuspension3", tags={"CarPart", "Mechanic", "Sport", "Rare"},   basePrice=170, stockRange={min=0, max=1} },

    -- TIRES
    { item="Base.OldTire1",          tags={"CarPart", "Mechanic", "Common"},          basePrice=30,  stockRange={min=2, max=6} },
    { item="Base.OldTire2",          tags={"CarPart", "Mechanic", "Heavy", "Common"}, basePrice=40,  stockRange={min=2, max=4} },
    { item="Base.OldTire3",          tags={"CarPart", "Mechanic", "Sport", "Uncommon"},basePrice=55,  stockRange={min=0, max=3} },
    { item="Base.NormalTire1",       tags={"CarPart", "Mechanic", "Uncommon"},        basePrice=60,  stockRange={min=2, max=5} },
    { item="Base.NormalTire2",       tags={"CarPart", "Mechanic", "Heavy", "Uncommon"},basePrice=80,  stockRange={min=2, max=4} },
    { item="Base.NormalTire3",       tags={"CarPart", "Mechanic", "Sport", "Rare"},   basePrice=110, stockRange={min=0, max=3} },
    { item="Base.ModernTire1",       tags={"CarPart", "Mechanic", "Rare"},            basePrice=120, stockRange={min=0, max=3} },
    { item="Base.ModernTire2",       tags={"CarPart", "Mechanic", "Heavy", "Rare"},   basePrice=165, stockRange={min=0, max=2} },
    { item="Base.ModernTire3",       tags={"CarPart", "Mechanic", "Sport", "Rare"},   basePrice=230, stockRange={min=0, max=2} },

    -- =============================================================================
    -- 7. GLASS & WINDOWS
    -- =============================================================================
    
    -- WINDSHIELDS
    { item="Base.Windshield1",       tags={"CarPart", "Heavy", "Common"},    basePrice=70,  stockRange={min=0, max=2} },
    { item="Base.Windshield2",       tags={"CarPart", "Heavy", "Uncommon"},  basePrice=95,  stockRange={min=0, max=2} },
    { item="Base.Windshield3",       tags={"CarPart", "Sport", "Rare"},      basePrice=130, stockRange={min=0, max=1} },
    { item="Base.RearWindshield1",   tags={"CarPart", "Heavy", "Common"},    basePrice=60,  stockRange={min=0, max=2} },
    { item="Base.RearWindshield2",   tags={"CarPart", "Heavy", "Uncommon"},  basePrice=80,  stockRange={min=0, max=2} },
    { item="Base.RearWindshield3",   tags={"CarPart", "Sport", "Rare"},      basePrice=110, stockRange={min=0, max=1} },

    -- WINDOWS
    { item="Base.FrontWindow1",      tags={"CarPart", "Common"},             basePrice=25,  stockRange={min=1, max=4} },
    { item="Base.FrontWindow2",      tags={"CarPart", "Heavy", "Common"},    basePrice=35,  stockRange={min=1, max=3} },
    { item="Base.FrontWindow3",      tags={"CarPart", "Sport", "Uncommon"},  basePrice=50,  stockRange={min=0, max=2} },
    { item="Base.RearWindow1",       tags={"CarPart", "Common"},             basePrice=25,  stockRange={min=1, max=4} },
    { item="Base.RearWindow2",       tags={"CarPart", "Heavy", "Common"},    basePrice=35,  stockRange={min=1, max=3} },
    { item="Base.RearWindow3",       tags={"CarPart", "Sport", "Uncommon"},  basePrice=50,  stockRange={min=0, max=2} },
})