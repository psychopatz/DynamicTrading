require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. POWER GENERATION (High Value / End Game)
-- =============================================================================
-- Essential for long runs. Prices reflect efficiency and noise levels.
{ item="Base.Generator", basePrice=1200, tags={"Electronics.Generator", "Rarity.Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.Generator_Yellow", basePrice=1800, tags={"Electronics.Generator", "Quality.Premium", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.Generator_Blue", basePrice=1000, tags={"Electronics.Generator", "Rarity.Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.Generator_Old", basePrice=600, tags={"Electronics.Generator", "Quality.Junk", "Rarity.Common"}, stockRange={min=0, max=1} },

-- =============================================================================
-- 2. BATTERIES (Consumables)
-- =============================================================================
-- Constant demand.
{ item="Base.Battery",             basePrice=12,  tags={"Electronics.Battery", "Rarity.Common"}, stockRange={min=5, max=15} },
{ item="Base.BatteryBox",          basePrice=120, tags={"Electronics.Battery", "Origin.Industrial", "Rarity.Uncommon"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 3. WALKIE TALKIES (Handheld Communication)
-- =============================================================================
-- Prices scaled by Transmission Range and Battery Efficiency.

-- Low Tier (Toys/Junk)
{ item="Base.WalkieTalkieMakeShift", basePrice=15, tags={"Electronics.Communication.Handheld", "Quality.Primitive", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.WalkieTalkie1",         basePrice=25, tags={"Electronics.Communication.Handheld", "Quality.Junk", "Rarity.Common"}, stockRange={min=1, max=5} },

-- Mid Tier (Civilian)
{ item="Base.WalkieTalkie2",         basePrice=60, tags={"Electronics.Communication.Handheld", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.WalkieTalkie3",         basePrice=120,tags={"Electronics.Communication.Handheld", "Quality.Premium", "Rarity.Uncommon"}, stockRange={min=1, max=2} },

-- High Tier (Military/Tactical)
{ item="Base.WalkieTalkie4",         basePrice=250,tags={"Electronics.Communication.Handheld", "Origin.Military", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.WalkieTalkie5",         basePrice=600,tags={"Electronics.Communication.Handheld", "Origin.Military", "Rarity.Legendary"}, stockRange={min=0, max=1} },

-- =============================================================================
-- 4. HAM RADIOS (Stationary Communication)
-- =============================================================================
-- Heavy items, mostly for base decoration or listening to AEBS.
{ item="Base.RadioMakeShift",        basePrice=5,   tags={"Tool.Electronics", "Electronics.Communication", "Quality.Junk"}, stockRange={min=1, max=3} }, -- Receiver only
{ item="Base.HamRadioMakeShift",     basePrice=80,  tags={"Electronics.Communication.Stationary", "Quality.Primitive", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.HamRadio1",             basePrice=250, tags={"Electronics.Communication.Stationary", "Quality.Premium", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.HamRadio2",             basePrice=600, tags={"Electronics.Communication.Stationary", "Origin.Military", "Rarity.Legendary"}, stockRange={min=0, max=1} },
{ item="Base.ManPackRadio",          basePrice=800, tags={"Electronics.Communication.Handheld", "Origin.Military", "Rarity.Legendary"}, stockRange={min=0, max=1} },

-- Receivers (Music/News)
{ item="Base.RadioRed",              basePrice=45,  tags={"Electronics.Communication.Receiver", "Quality.Premium", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
{ item="Base.RadioBlack",            basePrice=25,  tags={"Electronics.Communication.Receiver", "Rarity.Common"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 5. TELEVISIONS (Entertainment / Skill Learning)
-- =============================================================================
-- Heavy, difficult to trade, mostly scrapped for parts.
{ item="Base.TvAntique",             basePrice=35, tags={"Electronics.Entertainment.TV", "Quality.Junk", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.TvBlack",               basePrice=65, tags={"Electronics.Entertainment.TV", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.TvWideScreen",          basePrice=150,tags={"Electronics.Entertainment.TV", "Quality.Premium", "Rarity.Uncommon"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 6. COMPONENTS & SCRAP (Engineering Materials)
-- =============================================================================
{ item="Base.ElectronicsScrap",      basePrice=5,   tags={"Electronics.Component", "Quality.Junk", "Rarity.Common"}, stockRange={min=10, max=30} },
{ item="Base.ElectricWire",          basePrice=10,  tags={"Electronics.Component", "Rarity.Common"}, stockRange={min=5, max=15} },

-- Bomb/Trap Components (Higher value)
{ item="Base.MotionSensor",          basePrice=85, tags={"Electronics.Component.Sensor", "Rarity.Rare"}, stockRange={min=1, max=5} },
{ item="Base.Remote",                basePrice=45, tags={"Electronics.Component.Trigger", "Rarity.Common"}, stockRange={min=1, max=5} }, -- TV Remote (Trigger)
{ item="Base.Timer",                 basePrice=45, tags={"Electronics.Component.Trigger", "Rarity.Common"}, stockRange={min=1, max=5} }, 

-- Radio Parts
{ item="Base.Amplifier",             basePrice=25, tags={"Electronics.Component.Audio", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
{ item="Base.RadioReceiver",         basePrice=25, tags={"Electronics.Component.Communication", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
{ item="Base.RadioTransmitter",      basePrice=35, tags={"Electronics.Component.Communication", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
{ item="Base.ScannerModule",         basePrice=45, tags={"Electronics.Component.Communication", "Rarity.Rare"}, stockRange={min=1, max=5} },
{ item="Base.Receiver",              basePrice=15, tags={"Electronics.Component.Communication", "Rarity.Common"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 7. APPLIANCES & GADGETS
-- =============================================================================
-- Functional
{ item="Base.Earbuds",               basePrice=35, tags={"Electronics.Gadget.Audio", "Rarity.Common"}, stockRange={min=2, max=10} }, -- Useful for silent radio listening
{ item="Base.Headphones",            basePrice=45, tags={"Electronics.Gadget.Audio", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.HomeAlarm",             basePrice=75, tags={"Electronics.Component.Security", "Rarity.Uncommon"}, stockRange={min=1, max=3} }, -- Noise maker trap
{ item="Base.VideoGame",             basePrice=120,tags={"Electronics.Entertainment.Gaming", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Reduces boredom
{ item="Base.CDplayer",              basePrice=85, tags={"Electronics.Entertainment.Audio", "Quality.Premium", "Rarity.Uncommon"}, stockRange={min=1, max=5} },

-- Mostly Junk / Disassembly Fodder
{ item="Base.CordlessPhone",         basePrice=15, tags={"Electronics.Gadget.Phone", "Quality.Junk"}, stockRange={min=1, max=5} },
{ item="Base.HairDryer",             basePrice=15, tags={"Electronics.Gadget.Household", "Quality.Junk"}, stockRange={min=1, max=5} },
{ item="Base.HairIron",              basePrice=15, tags={"Electronics.Gadget.Household", "Quality.Junk"}, stockRange={min=1, max=5} },
{ item="Base.Speaker",               basePrice=35, tags={"Electronics.Component.Audio", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.PowerBar",              basePrice=25, tags={"Electronics.Component.Power", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Microphone",            basePrice=45, tags={"Electronics.Component.Audio", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
{ item="Base.Pager",                 basePrice=15, tags={"Electronics.Gadget.Phone", "Quality.Junk"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 8. LIGHT BULBS
-- =============================================================================
{ item="Base.LightBulb",             basePrice=5,   tags={"Electronics.Component.Light", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.LightBulbBox",          basePrice=25,  tags={"Electronics.Component.Light", "Rarity.Uncommon"}, stockRange={min=2, max=8} },

-- Colored Bulbs (Cosmetic Rarity Tax)
{ item="Base.LightBulbBlue",         basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbCyan",         basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbGreen",        basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbMagenta",      basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbOrange",       basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbPink",         basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbPurple",       basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbRed",          basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
{ item="Base.LightBulbYellow",       basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },

})

print("[DynamicTrading] Electronics Registry Complete \n.")
