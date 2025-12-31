require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================================
-- HELPER FUNCTION
-- ==========================================================
local function RegisterElectronics(items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        local uniqueID = config.id or ("Buy" .. itemName)

        local finalTags = {"Electric"}
        if config.tags then for _, t in ipairs(config.tags) do table.insert(finalTags, t) end end

        DynamicTrading.AddItem(uniqueID, {
            item = config.item,
            category = config.category or "Electronics",
            tags = finalTags,
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 4 }
        })
    end
end

-- ==========================================================
-- ITEM DEFINITIONS (Compressed)
-- ==========================================================

-- 1. POWER & GENERATION
RegisterElectronics({
    { item="Base.Generator",        price=500, min=0, max=1,  tags={"Heavy", "Rare", "Fuel"} },
    { item="Base.ElectronicsMag4",  price=250, min=0, max=1,  tags={"Rare", "Literature"}, category="Literature", id="BuyGeneratorManual" },
    { item="Base.Battery",          price=12,  min=5, max=15, tags={"Fuel"} },
})

-- 2. TOOLS & COMPONENTS
RegisterElectronics({
    { item="Base.Screwdriver",      price=35,  min=1, max=3,  tags={"Tool", "Mechanic"} },
    { item="Base.ElectronicsScrap", price=8,   min=10, max=30, tags={"Junk", "SpareParts"} },
    { item="Base.ElectricWire",     price=15,  min=5, max=15, tags={"SpareParts"} },
    { item="Base.Amplifier",        price=45,  min=1, max=4,  tags={"Rare"} },
    { item="Base.Receiver",         price=25,  min=2, max=6 },
    { item="Base.Transmitter",      price=25,  min=2, max=6 },
})

-- 3. COMMUNICATION (Radios & Walkies)
RegisterElectronics({
    { item="radio.WalkieTalkie1",   price=15,  min=1, max=3,  tags={"Junk"}, category="Communication", id="BuyWalkieTalkieToy" },
    { item="radio.WalkieTalkie2",   price=45,  min=1, max=4,  category="Communication", id="BuyWalkieTalkieCivilian" },
    { item="radio.WalkieTalkie3",   price=80,  min=1, max=2,  tags={"Police"}, category="Communication", id="BuyWalkieTalkiePro" },
    { item="radio.WalkieTalkie4",   price=150, min=0, max=1,  tags={"Military", "Rare"}, category="Communication", id="BuyWalkieTalkieMilitary" },
    { item="radio.RadioRed",        price=30,  min=1, max=3,  category="Communication", id="BuyRadio" },
    { item="radio.RadioBlack",      price=40,  min=1, max=2,  category="Communication", id="BuyRadioBlack" },
    { item="radio.HamRadio1",       price=250, min=0, max=1,  tags={"Heavy", "Rare"}, category="Communication", id="BuyHamRadio" },
    { item="Base.Earbuds",          price=25,  min=1, max=5,  tags={"Survival"}, category="Communication" },
    { item="Base.Headphones",       price=40,  min=1, max=3,  tags={"Survival"}, category="Communication" },
})

-- 4. SENSORS, TRIGGERS & LIGHTING
RegisterElectronics({
    { item="Base.MotionSensor",     price=60,  min=1, max=3,  tags={"Rare"} },
    { item="Base.RemoteControlV1",  price=35,  min=1, max=4,  id="BuyRemoteController" },
    { item="Base.Timer",            price=20,  min=2, max=5 },
    { item="Base.Flashlight_FiveBat", price=45, min=1, max=4, tags={"Survival"}, id="BuyFlashlight" },
    { item="Base.LightBulb",        price=5,   min=4, max=10 },
})

-- 5. WATCHES
RegisterElectronics({
    { item="Base.Watch_ClassicBlack",   price=10, min=2, max=5, tags={"Civilian"}, id="BuyAnalogWatchClassic" },
    { item="Base.Watch_ClassicGold",    price=60, min=0, max=1, tags={"Rare", "Luxury"}, id="BuyAnalogWatchGold" },
    { item="Base.Watch_DigitalBlack",   price=20, min=2, max=5, tags={"Civilian", "Survival"}, id="BuyDigitalWatchBlack" },
    { item="Base.Watch_DigitalLeftBlue", price=20, min=1, max=3, tags={"Civilian"}, id="BuyDigitalWatchBlue" },
    { item="Base.Watch_DigitalGold",    price=85, min=0, max=1, tags={"Rare", "Luxury", "Survival"}, id="BuyDigitalWatchGold" },
})