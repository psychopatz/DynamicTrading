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

    -- [Building.Fixture] [Rarity.Common] (1 item)
    { item="Base.ScannerModule", basePrice=10, tags={"Building.Fixture", "Rarity.Common"}, stockRange={min=5, max=25} },

    -- [Building.Fixture] [Rarity.Rare] (60 items)
    { item="Base.AlarmClock2", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Amplifier", basePrice=10, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.BathTowelWet", basePrice=3, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Calculator", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.CanPipe", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Clipboard", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.CombinationPadlock", basePrice=14, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.CordlessPhone", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.DishClothWet", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Doily", basePrice=17, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Earbuds", basePrice=17, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.ElectricWire", basePrice=17, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Eraser", basePrice=17, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.HairDryer", basePrice=3, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.HairIron", basePrice=3, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Headphones", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.HomeAlarm", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.KeyPadlock", basePrice=26, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.LightBulb", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.LightBulbBlue", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.LightBulbBox", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.LightBulbCyan", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.LightBulbGreen", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.LightBulbMagenta", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.LightBulbOrange", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.LightBulbPink", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.LightBulbPurple", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.LightBulbRed", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.LightBulbYellow", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.MagnifyingGlass", basePrice=3, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.MarkerBlack", basePrice=8, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerBlue", basePrice=8, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerGreen", basePrice=8, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerRed", basePrice=8, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Microphone", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.MotionSensor", basePrice=10, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Padlock", basePrice=14, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Pager", basePrice=17, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Pipe", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.PowerBar", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.Receiver", basePrice=29, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Remote", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.RemoteCraftedV1", basePrice=11, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.RemoteCraftedV2", basePrice=11, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.RemoteCraftedV3", basePrice=11, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.RippedSheets", basePrice=64, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.RippedSheetsDirty", basePrice=64, tags={"Building.Fixture", "Rarity.Rare", "Quality.Waste", "Quality.Waste"}, stockRange={min=0, max=10} },
    { item="Base.ScissorsBlunt", basePrice=12, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Speaker", basePrice=3, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Sponge", basePrice=17, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.StraightRazor", basePrice=4, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.TimerCrafted", basePrice=7, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.ToiletBrush", basePrice=3, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.TriggerCrafted", basePrice=14, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.UmbrellaBlack", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaBlue", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaRed", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaTINTED", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaWhite", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.VideoGame", basePrice=4, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Fixture Registry Complete")
