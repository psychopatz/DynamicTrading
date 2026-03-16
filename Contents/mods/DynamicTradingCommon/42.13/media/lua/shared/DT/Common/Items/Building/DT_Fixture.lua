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

    -- [Building.Fixture.Appliance] [Rarity.Common] (27 items)
    { item="Base.Mov_AntiqueStove", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_BlueComboWasherDryer", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_BlueFridge", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_ChestFreezer", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_FridgeMini", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_GreenFridge", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_GreenOven", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_GreyOven", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_IndustrialDishwasher", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_IndustrialFridge", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_IndustrialOven", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_Microwave", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_Microwave2", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_ModernOven", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_PlainFridge", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_PopsicleFreezer", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_RedFridge", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_RedOven", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_SnackVendingMachine", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_SodaMachine", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_SodaMachineLarge", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_SodaVendingMachine", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_SteelFridge", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_Toaster", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_TrailerFridge", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteFridge", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteIndustrialFridge", basePrice=2, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },

    -- [Building.Fixture.Communication] [Rarity.Common] (7 items)
    { item="Base.Mov_BeigeRotaryPhone", basePrice=2, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_BlackModernPhone", basePrice=2, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_BlackRotaryPhone", basePrice=2, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_PayPhones", basePrice=2, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_RedRotaryPhone", basePrice=2, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteModernPhone", basePrice=2, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteRotaryPhone", basePrice=2, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },

    -- [Building.Fixture.General] [Rarity.Rare] (22 items)
    { item="Base.AlarmClock2", basePrice=6, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.BathTowelWet", basePrice=3, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Calculator", basePrice=6, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Clipboard", basePrice=2, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.DishClothWet", basePrice=6, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Doily", basePrice=17, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Eraser", basePrice=17, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MagnifyingGlass", basePrice=3, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.MarkerBlack", basePrice=8, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerBlue", basePrice=8, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerGreen", basePrice=8, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerRed", basePrice=8, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.RippedSheets", basePrice=64, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.RippedSheetsDirty", basePrice=64, tags={"Building.Fixture.General", "Rarity.Rare", "Quality.Waste", "Quality.Waste"}, stockRange={min=0, max=10} },
    { item="Base.ScissorsBlunt", basePrice=12, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Sponge", basePrice=17, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.StraightRazor", basePrice=4, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.UmbrellaBlack", basePrice=2, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaBlue", basePrice=2, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaRed", basePrice=2, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaTINTED", basePrice=2, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaWhite", basePrice=2, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },

    -- [Building.Fixture.Hardware] [Rarity.Rare] (2 items)
    { item="Base.CombinationPadlock", basePrice=14, tags={"Building.Fixture.Hardware", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Padlock", basePrice=14, tags={"Building.Fixture.Hardware", "Rarity.Rare"}, stockRange={min=0, max=6} },

    -- [Building.Fixture.Plumbing] [Rarity.Common] (13 items)
    { item="Base.Mov_ChemicalToilet", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_ChromeSink", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_DarkIndustrialSink", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_FancyHangingSink", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_FancyToilet", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_IndustrialSink", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_LargeIndustrialSink", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_LowToilet", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_Urinal", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WallShower", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WaterDispenser", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteHangingSink", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteSink", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },

    -- [Building.Fixture.Plumbing] [Rarity.Rare] (3 items)
    { item="Base.CanPipe", basePrice=6, tags={"Building.Fixture.Plumbing", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Pipe", basePrice=2, tags={"Building.Fixture.Plumbing", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.ToiletBrush", basePrice=3, tags={"Building.Fixture.Plumbing", "Rarity.Rare"}, stockRange={min=0, max=4} },

    -- [Building.Fixture.Storage] [Rarity.Common] (4 items)
    { item="Base.Mov_BlueWallLocker", basePrice=2, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_GreenWallLocker", basePrice=2, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_MetalLocker", basePrice=2, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_YellowWallLocker", basePrice=2, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=3, max=15} },

    -- [Building.Fixture.Storage] [Rarity.Uncommon] (1 item)
    { item="Base.Mov_MilitaryLocker", basePrice=3, tags={"Building.Fixture.Storage", "Rarity.Uncommon", "Origin.Militia"}, stockRange={min=3, max=15} },

    -- [Building.Fixture.Utility] [Rarity.Common] (2 items)
    { item="Base.Mov_NapkinDispenser", basePrice=2, tags={"Building.Fixture.Utility", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_TowelDispenser", basePrice=2, tags={"Building.Fixture.Utility", "Rarity.Common"}, stockRange={min=3, max=15} },
})

print("[DynamicTrading] Fixture Registry Complete")
