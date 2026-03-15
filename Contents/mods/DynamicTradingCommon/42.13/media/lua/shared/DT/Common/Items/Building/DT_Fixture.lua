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

    -- [Building.Fixture] [Rarity.Rare] (28 items)
    { item="Base.AlarmClock2", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.BathTowelWet", basePrice=3, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Calculator", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.CanPipe", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Clipboard", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.CombinationPadlock", basePrice=14, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.DishClothWet", basePrice=6, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Doily", basePrice=17, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Eraser", basePrice=17, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.KeyPadlock", basePrice=26, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.MagnifyingGlass", basePrice=3, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.MarkerBlack", basePrice=8, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerBlue", basePrice=8, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerGreen", basePrice=8, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerRed", basePrice=8, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Padlock", basePrice=14, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Pipe", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.RippedSheets", basePrice=64, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.RippedSheetsDirty", basePrice=64, tags={"Building.Fixture", "Rarity.Rare", "Quality.Waste", "Quality.Waste"}, stockRange={min=0, max=10} },
    { item="Base.ScissorsBlunt", basePrice=12, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Sponge", basePrice=17, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.StraightRazor", basePrice=4, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.ToiletBrush", basePrice=3, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaBlack", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaBlue", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaRed", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaTINTED", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaWhite", basePrice=2, tags={"Building.Fixture", "Rarity.Rare"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Fixture Registry Complete")
