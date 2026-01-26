require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end
Register({
-- =============================================================================
-- 1. POWER GENERATION (High Value / End Game)
-- =============================================================================
-- Essential for long runs. Prices reflect efficiency and noise levels.
{ item="Base.Generator", basePrice=500, tags={"Electronics", "Generator", "Tool"}, stockRange={min=0, max=1} }, -- Standard Lectromax
{ item="Base.Generator_Yellow", basePrice=650, tags={"Electronics", "Generator", "Tool", "Premium"}, stockRange={min=0, max=1} }, -- Premium (Low degradation)
{ item="Base.Generator_Blue", basePrice=450, tags={"Electronics", "Generator", "Tool"}, stockRange={min=0, max=1} }, -- ValuTech (Lightweight but fragile)
{ item="Base.Generator_Old", basePrice=300, tags={"Electronics", "Generator", "Tool", "Junk"}, stockRange={min=0, max=1} }, -- Loud & unreliable

-- =============================================================================
-- 2. BATTERIES (Consumables)
-- =============================================================================
-- Constant demand.
{ item="Base.Battery",             basePrice=6,   tags={"Electronics", "Battery"}, stockRange={min=5, max=20} },
{ item="Base.BatteryBox",          basePrice=60,  tags={"Electronics", "Battery", "Stockpile"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 3. WALKIE TALKIES (Handheld Communication)
-- =============================================================================
-- Prices scaled by Transmission Range and Battery Efficiency.

-- Low Tier (Toys/Junk)
{ item="Base.WalkieTalkieMakeShift", basePrice=5, tags={"Electronics", "Communication", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.WalkieTalkie1",         basePrice=8, tags={"Electronics", "Communication", "Junk"}, stockRange={min=1, max=5} }, -- Toys-R-Mine (750m)

-- Mid Tier (Civilian)
{ item="Base.WalkieTalkie2",         basePrice=20, tags={"Electronics", "Communication"}, stockRange={min=1, max=5} }, -- ValuTech (2000m)
{ item="Base.WalkieTalkie3",         basePrice=35, tags={"Electronics", "Communication", "Premium"}, stockRange={min=1, max=5} }, -- Premium (4000m)

-- High Tier (Military/Tactical)
{ item="Base.WalkieTalkie4",         basePrice=60, tags={"Electronics", "Communication", "Military"}, stockRange={min=1, max=3} }, -- Tactical (8000m)
{ item="Base.WalkieTalkie5",         basePrice=120,tags={"Electronics", "Communication", "Military", "Legendary"}, stockRange={min=0, max=2} }, -- US Army (16000m)

-- =============================================================================
-- 4. HAM RADIOS (Stationary Communication)
-- =============================================================================
-- Heavy items, mostly for base decoration or listening to AEBS.
{ item="Base.RadioMakeShift",        basePrice=5,   tags={"Electronics", "Communication", "Junk"}, stockRange={min=1, max=3} }, -- Receiver only
{ item="Base.HamRadioMakeShift",     basePrice=25,  tags={"Electronics", "Communication", "Junk"}, stockRange={min=1, max=3} },

-- Civilian Transmitters
{ item="Base.HamRadio1",             basePrice=80,  tags={"Electronics", "Communication", "Premium"}, stockRange={min=1, max=2} }, -- Premium

-- Military Transmitters (Massive Range)
{ item="Base.HamRadio2",             basePrice=200, tags={"Electronics", "Communication", "Military"}, stockRange={min=0, max=1} }, -- US Army
{ item="Base.ManPackRadio",          basePrice=250, tags={"Electronics", "Communication", "Military", "Rare"}, stockRange={min=0, max=1} }, -- Backpack slot

-- Receivers (Music/News)
{ item="Base.RadioRed",              basePrice=25,  tags={"Electronics", "Communication", "Premium"}, stockRange={min=1, max=5} },
{ item="Base.RadioBlack",            basePrice=15,  tags={"Electronics", "Communication"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 5. TELEVISIONS (Entertainment / Skill Learning)
-- =============================================================================
-- Heavy, difficult to trade, mostly scrapped for parts.
{ item="Base.TvAntique",             basePrice=20,  tags={"Electronics", "Heavy", "Junk"}, stockRange={min=1, max=3} },
{ item="Base.TvBlack",               basePrice=30,  tags={"Electronics", "Heavy"}, stockRange={min=1, max=3} },
{ item="Base.TvWideScreen",          basePrice=50,  tags={"Electronics", "Heavy", "Premium"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 6. COMPONENTS & SCRAP (Engineering Materials)
-- =============================================================================
{ item="Base.ElectronicsScrap",      basePrice=1,   tags={"Electronics", "Component", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.ElectricWire",          basePrice=2,   tags={"Electronics", "Component"}, stockRange={min=5, max=20} },

-- Bomb/Trap Components (Higher value)
{ item="Base.MotionSensor",          basePrice=15,  tags={"Electronics", "Component", "Rare"}, stockRange={min=1, max=5} },
{ item="Base.Remote",                basePrice=10,  tags={"Electronics", "Component"}, stockRange={min=1, max=5} }, -- TV Remote (Trigger)
{ item="Base.Timer",                 basePrice=10,  tags={"Electronics", "Component"}, stockRange={min=1, max=5} }, -- (Not in list but inferred, added just in case)

-- Radio Parts
{ item="Base.Amplifier",             basePrice=5,   tags={"Electronics", "Component"}, stockRange={min=1, max=5} },
{ item="Base.RadioReceiver",         basePrice=5,   tags={"Electronics", "Component"}, stockRange={min=1, max=5} },
{ item="Base.RadioTransmitter",      basePrice=8,   tags={"Electronics", "Component"}, stockRange={min=1, max=5} },
{ item="Base.ScannerModule",         basePrice=5,   tags={"Electronics", "Component"}, stockRange={min=1, max=5} },
{ item="Base.Receiver",              basePrice=5,   tags={"Electronics", "Component"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 7. APPLIANCES & GADGETS
-- =============================================================================
-- Functional
{ item="Base.Earbuds",               basePrice=10,  tags={"Electronics", "Communication"}, stockRange={min=2, max=10} }, -- Useful for silent radio listening
{ item="Base.Headphones",            basePrice=8,   tags={"Electronics", "Communication"}, stockRange={min=2, max=10} },
{ item="Base.HomeAlarm",             basePrice=12,  tags={"Electronics", "Component"}, stockRange={min=1, max=3} }, -- Noise maker trap
{ item="Base.VideoGame",             basePrice=15,  tags={"Electronics", "Luxury"}, stockRange={min=1, max=5} }, -- Reduces boredom
{ item="Base.CDplayer",              basePrice=15,  tags={"Electronics", "Luxury"}, stockRange={min=1, max=5} },

-- Mostly Junk / Disassembly Fodder
{ item="Base.CordlessPhone",         basePrice=5,   tags={"Electronics", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.HairDryer",             basePrice=5,   tags={"Electronics", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.HairIron",              basePrice=5,   tags={"Electronics", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.Speaker",               basePrice=10,  tags={"Electronics", "Material"}, stockRange={min=1, max=5} },
{ item="Base.PowerBar",              basePrice=5,   tags={"Electronics", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.Microphone",            basePrice=5,   tags={"Electronics", "Component"}, stockRange={min=1, max=5} },
{ item="Base.Pager",                 basePrice=5,   tags={"Electronics", "Junk"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 8. LIGHT BULBS
-- =============================================================================
{ item="Base.LightBulb",             basePrice=2,   tags={"Electronics", "Light"}, stockRange={min=5, max=20} },
{ item="Base.LightBulbBox",          basePrice=10,  tags={"Electronics", "Light"}, stockRange={min=2, max=8} },

-- Colored Bulbs (Cosmetic Rarity Tax)
{ item="Base.LightBulbBlue",         basePrice=5,   tags={"Electronics", "Light", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbCyan",         basePrice=5,   tags={"Electronics", "Light", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbGreen",        basePrice=5,   tags={"Electronics", "Light", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbMagenta",      basePrice=5,   tags={"Electronics", "Light", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbOrange",       basePrice=5,   tags={"Electronics", "Light", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbPink",         basePrice=5,   tags={"Electronics", "Light", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbPurple",       basePrice=5,   tags={"Electronics", "Light", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbRed",          basePrice=5,   tags={"Electronics", "Light", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbYellow",       basePrice=5,   tags={"Electronics", "Light", "Luxury"}, stockRange={min=1, max=5} },

})

print("[DynamicTrading] Electronics Registry Complete.")
