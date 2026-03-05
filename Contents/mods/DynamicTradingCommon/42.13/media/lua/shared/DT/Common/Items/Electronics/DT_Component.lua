-- =============================================================================
-- DYNAMIC TRADING: ELECTRONICS - COMPONENT
-- =============================================================================
-- Root Category: Electronics
-- Sub Category: Component
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Amplifier",             basePrice=25, tags={"Electronics.Component.Audio", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
    { item="Base.Camera",               basePrice=120, tags={"Electronics.Component.Digital", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.CameraDisposable",     basePrice=35,  tags={"Electronics.Component.Digital", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
    { item="Base.HomeAlarm",             basePrice=75, tags={"Electronics.Component.Security", "Rarity.Uncommon"}, stockRange={min=1, max=3} }, -- Noise maker trap,
    { item="Base.LightBulb",             basePrice=5,   tags={"Electronics.Component.Light", "Rarity.Common"}, stockRange={min=5, max=20} },
    { item="Base.LightBulbBlue",         basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
    { item="Base.LightBulbBox",          basePrice=25,  tags={"Electronics.Component.Light", "Rarity.Uncommon"}, stockRange={min=2, max=8} },
    { item="Base.LightBulbCyan",         basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
    { item="Base.LightBulbGreen",        basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
    { item="Base.LightBulbMagenta",      basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
    { item="Base.LightBulbOrange",       basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
    { item="Base.LightBulbPink",         basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
    { item="Base.LightBulbPurple",       basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
    { item="Base.LightBulbRed",          basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
    { item="Base.LightBulbYellow",       basePrice=15,  tags={"Electronics.Component.Light", "Quality.Luxury"}, stockRange={min=1, max=5} },
    { item="Base.Microphone",            basePrice=45, tags={"Electronics.Component.Audio", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
    { item="Base.MotionSensor",          basePrice=85, tags={"Electronics.Component.Sensor", "Rarity.Rare"}, stockRange={min=1, max=5} },
    { item="Base.PowerBar",              basePrice=25, tags={"Electronics.Component.Power", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.RadioReceiver",         basePrice=25, tags={"Electronics.Component.Communication", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
    { item="Base.RadioTransmitter",      basePrice=35, tags={"Electronics.Component.Communication", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
    { item="Base.Receiver",              basePrice=15, tags={"Electronics.Component.Communication", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Remote",                basePrice=45, tags={"Electronics.Component.Trigger", "Rarity.Common"}, stockRange={min=1, max=5} }, -- TV Remote (Trigger),
    { item="Base.ScannerModule",         basePrice=45, tags={"Electronics.Component.Communication", "Rarity.Rare"}, stockRange={min=1, max=5} },
    { item="Base.Speaker",               basePrice=35, tags={"Electronics.Component.Audio", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Timer",                 basePrice=45, tags={"Electronics.Component.Trigger", "Rarity.Common"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Electronics/Component Registry Loaded.")
