require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================
-- POWER & GENERATION
-- ==========================================

-- Generator: The most important late-game electronic item.
DynamicTrading.AddItem("BuyGenerator", {
    item = "Base.Generator",
    category = "Electronics",
    tags = {"Electric", "Heavy", "Rare", "Fuel"},
    basePrice = 500,
    stockRange = { min=0, max=1 }
})

-- How to Use Generators: The manual required to actually operate the generator.
DynamicTrading.AddItem("BuyGeneratorManual", {
    item = "Base.ElectronicsMag4",
    category = "Literature",
    tags = {"Electric", "Rare", "Literature"},
    basePrice = 250, -- High value due to being a survival necessity
    stockRange = { min=0, max=1 }
})

-- Battery: Essential for flashlights and radios.
DynamicTrading.AddItem("BuyBattery", {
    item = "Base.Battery",
    category = "Electronics",
    tags = {"Electric", "Fuel"},
    basePrice = 12,
    stockRange = { min=5, max=15 }
})

-- ==========================================
-- TOOLS & COMPONENTS
-- ==========================================

-- Screwdriver: The primary tool for all electrical work.
DynamicTrading.AddItem("BuyScrewdriver", {
    item = "Base.Screwdriver",
    category = "Electronics",
    tags = {"Electric", "Tool", "Mechanic"},
    basePrice = 35,
    stockRange = { min=1, max=3 }
})

-- Electronic Scrap: The bread and butter for leveling Electrical.
DynamicTrading.AddItem("BuyElectronicScrap", {
    item = "Base.ElectronicsScrap",
    category = "Electronics",
    tags = {"Electric", "Junk", "SpareParts"},
    basePrice = 8,
    stockRange = { min=10, max=30 }
})

-- Electric Wire: Used for crafting and repairs.
DynamicTrading.AddItem("BuyElectricWire", {
    item = "Base.ElectricWire",
    category = "Electronics",
    tags = {"Electric", "SpareParts"},
    basePrice = 15,
    stockRange = { min=5, max=15 }
})

-- Amplifier, Receiver, & Transmitter: Rare components for advanced electronics.
DynamicTrading.AddItem("BuyAmplifier", {
    item = "Base.Amplifier",
    category = "Electronics",
    tags = {"Electric", "Rare"},
    basePrice = 45,
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyReceiver", {
    item = "Base.Receiver",
    category = "Electronics",
    tags = {"Electric"},
    basePrice = 25,
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyTransmitter", {
    item = "Base.Transmitter",
    category = "Electronics",
    tags = {"Electric"},
    basePrice = 25,
    stockRange = { min=2, max=6 }
})

-- ==========================================
-- COMMUNICATION DEVICES
-- ==========================================

-- Handheld Radio: Basic communication and weather alerts.
DynamicTrading.AddItem("BuyRadio", {
    item = "Radio.RadioRed",
    category = "Electronics",
    tags = {"Electric"},
    basePrice = 40,
    stockRange = { min=1, max=3 }
})

-- Military Walkie-Talkie: Longest range handheld communication.
DynamicTrading.AddItem("BuyWalkieTalkie", {
    item = "Radio.WalkieTalkie4",
    category = "Electronics",
    tags = {"Electric", "Military", "Rare"},
    basePrice = 120,
    stockRange = { min=0, max=2 }
})

-- HAM Radio: Base-station grade communication.
DynamicTrading.AddItem("BuyHamRadio", {
    item = "Radio.HamRadio1",
    category = "Electronics",
    tags = {"Electric", "Heavy"},
    basePrice = 200,
    stockRange = { min=0, max=1 }
})

-- ==========================================
-- SENSORS & TRIGGERS (For Traps/Bombs)
-- ==========================================

DynamicTrading.AddItem("BuyMotionSensor", {
    item = "Base.MotionSensor",
    category = "Electronics",
    tags = {"Electric", "Rare"},
    basePrice = 60,
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyRemoteController", {
    item = "Base.RemoteControlV1",
    category = "Electronics",
    tags = {"Electric"},
    basePrice = 35,
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyTimer", {
    item = "Base.Timer",
    category = "Electronics",
    tags = {"Electric"},
    basePrice = 20,
    stockRange = { min=2, max=5 }
})

-- ==========================================
-- UTILITY & LIGHTING
-- ==========================================

-- Digital Watch: Vital for keeping time and setting alarms.
DynamicTrading.AddItem("BuyDigitalWatch", {
    item = "Base.Watch_DigitalBlack",
    category = "Electronics",
    tags = {"Electric"},
    basePrice = 15,
    stockRange = { min=2, max=5 }
})

-- Flashlight: Crucial for night exploration.
DynamicTrading.AddItem("BuyFlashlight", {
    item = "Base.Flashlight_FiveBat",
    category = "Electronics",
    tags = {"Electric", "Survival"},
    basePrice = 45,
    stockRange = { min=1, max=4 }
})

-- Light Bulb: Used for home lighting.
DynamicTrading.AddItem("BuyLightBulb", {
    item = "Base.LightBulb",
    category = "Electronics",
    tags = {"Electric"},
    basePrice = 5,
    stockRange = { min=4, max=10 }
})



-- ==========================================
-- WALKIE-TALKIES (Portable Transmitters)
-- ==========================================

-- Toy Walkie Talkie: Very short range, essentially a novelty or for scrap.
DynamicTrading.AddItem("BuyWalkieTalkieToy", {
    item = "radio.WalkieTalkie1",
    category = "Communication",
    tags = {"Electric", "Junk"},
    basePrice = 15,
    stockRange = { min=1, max=3 }
})

-- Civilian Walkie Talkie: Standard range, common in retail stores.
DynamicTrading.AddItem("BuyWalkieTalkieCivilian", {
    item = "radio.WalkieTalkie2",
    category = "Communication",
    tags = {"Electric"},
    basePrice = 45,
    stockRange = { min=1, max=4 }
})

-- Professional Walkie Talkie: Good range, used by emergency services.
DynamicTrading.AddItem("BuyWalkieTalkiePro", {
    item = "radio.WalkieTalkie3",
    category = "Communication",
    tags = {"Electric", "Police"},
    basePrice = 80,
    stockRange = { min=1, max=2 }
})

-- Military Walkie Talkie: The best handheld range in the game.
DynamicTrading.AddItem("BuyWalkieTalkieMilitary", {
    item = "radio.WalkieTalkie4",
    category = "Communication",
    tags = {"Electric", "Military", "Rare"},
    basePrice = 150,
    stockRange = { min=0, max=1 }
})

-- ==========================================
-- RADIOS (Receivers & Base Stations)
-- ==========================================

-- Standard Tabletop Radio: Used for checking the Automated Emergency Broadcast.
DynamicTrading.AddItem("BuyRadio", {
    item = "radio.RadioRed",
    category = "Communication",
    tags = {"Electric"},
    basePrice = 30,
    stockRange = { min=1, max=3 }
})

-- High-End Radio: Better presets and looks.
DynamicTrading.AddItem("BuyRadioBlack", {
    item = "radio.RadioBlack",
    category = "Communication",
    tags = {"Electric"},
    basePrice = 40,
    stockRange = { min=1, max=2 }
})

-- HAM Radio: Massive range, stationary/heavy. Essential for long-distance RP or lore.
DynamicTrading.AddItem("BuyHamRadio", {
    item = "radio.HamRadio1",
    category = "Communication",
    tags = {"Electric", "Heavy", "Rare"},
    basePrice = 250,
    stockRange = { min=0, max=1 }
})

-- ==========================================
-- AUDIO ACCESSORIES (Stealth Gear)
-- ==========================================

-- Earbuds: Lightest way to listen to radio without noise.
DynamicTrading.AddItem("BuyEarbuds", {
    item = "Base.Earbuds",
    category = "Communication",
    tags = {"Electric", "Survival"},
    basePrice = 25,
    stockRange = { min=1, max=5 }
})

-- Headphones: More durable than earbuds, prevents any sound from escaping.
DynamicTrading.AddItem("BuyHeadphones", {
    item = "Base.Headphones",
    category = "Communication",
    tags = {"Electric", "Survival"},
    basePrice = 40,
    stockRange = { min=1, max=3 }
})

-- ==========================================
-- WATCHES (Timekeeping & Alarms)
-- ==========================================

-- Classic Analog Watch: Tells time, but lacks temperature display and alarms.
DynamicTrading.AddItem("BuyAnalogWatchClassic", {
    item = "Base.Watch_ClassicBlack",
    category = "Electronics",
    tags = {"Electric", "Civilian"},
    basePrice = 10,
    stockRange = { min=2, max=5 }
})

-- Gold Analog Watch: Functionally identical to the classic, but rare and high trade value.
DynamicTrading.AddItem("BuyAnalogWatchGold", {
    item = "Base.Watch_ClassicGold",
    category = "Electronics",
    tags = {"Electric", "Rare", "Luxury"},
    basePrice = 60,
    stockRange = { min=0, max=1 }
})

-- Digital Watch (Black): The survivor's best friend. Shows time, date, temperature, and has an alarm.
DynamicTrading.AddItem("BuyDigitalWatchBlack", {
    item = "Base.Watch_DigitalBlack",
    category = "Electronics",
    tags = {"Electric", "Civilian", "Survival"},
    basePrice = 20,
    stockRange = { min=2, max=5 }
})

-- Digital Watch (Blue): A cosmetic variant of the standard digital watch.
DynamicTrading.AddItem("BuyDigitalWatchBlue", {
    item = "Base.Watch_DigitalLeftBlue",
    category = "Electronics",
    tags = {"Electric", "Civilian"},
    basePrice = 20,
    stockRange = { min=1, max=3 }
})

-- Gold Digital Watch: High-tier rare variant. Combines best utility with highest rarity.
DynamicTrading.AddItem("BuyDigitalWatchGold", {
    item = "Base.Watch_DigitalGold",
    category = "Electronics",
    tags = {"Electric", "Rare", "Luxury", "Survival"},
    basePrice = 85,
    stockRange = { min=0, max=1 }
})

-- ==========================================
-- POWER & SPARES
-- ==========================================

DynamicTrading.AddItem("BuyBattery", {
    item = "Base.Battery",
    category = "Electronics",
    tags = {"Electric", "Fuel"},
    basePrice = 12,
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyGenerator", {
    item = "Base.Generator",
    category = "Electronics",
    tags = {"Electric", "Heavy", "Rare", "Fuel"},
    basePrice = 500,
    stockRange = { min=0, max=1 }
})