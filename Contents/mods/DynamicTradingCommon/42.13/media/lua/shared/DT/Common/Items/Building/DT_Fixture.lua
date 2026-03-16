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
    { item="Base.Mov_AntiqueStove", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_BlueComboWasherDryer", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_BlueFridge", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_ChestFreezer", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_FridgeMini", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_GreenFridge", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_GreenOven", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_GreyOven", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_IndustrialDishwasher", basePrice=24, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_IndustrialFridge", basePrice=24, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_IndustrialOven", basePrice=24, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_Microwave", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_Microwave2", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_ModernOven", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_PlainFridge", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_PopsicleFreezer", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_RedFridge", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_RedOven", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_SnackVendingMachine", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_SodaMachine", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_SodaMachineLarge", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_SodaVendingMachine", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_SteelFridge", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_Toaster", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_TrailerFridge", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteFridge", basePrice=23, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteIndustrialFridge", basePrice=24, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=1, max=11} },

    -- [Building.Fixture.Communication] [Rarity.Common] (7 items)
    { item="Base.Mov_BeigeRotaryPhone", basePrice=12, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_BlackModernPhone", basePrice=12, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_BlackRotaryPhone", basePrice=12, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_PayPhones", basePrice=12, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_RedRotaryPhone", basePrice=12, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteModernPhone", basePrice=12, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteRotaryPhone", basePrice=12, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=1, max=13} },

    -- [Building.Fixture.General] [Rarity.Rare] (22 items)
    { item="Base.AlarmClock2", basePrice=24, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.BathTowelWet", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=7} },
    { item="Base.Calculator", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=7} },
    { item="Base.Clipboard", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.DishClothWet", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=7} },
    { item="Base.Doily", basePrice=9, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Eraser", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.MagnifyingGlass", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=7} },
    { item="Base.MarkerBlack", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.MarkerBlue", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.MarkerGreen", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.MarkerRed", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.RippedSheets", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.RippedSheetsDirty", basePrice=4, tags={"Building.Fixture.General", "Rarity.Rare", "Quality.Waste", "Quality.Waste"}, stockRange={min=0, max=14} },
    { item="Base.ScissorsBlunt", basePrice=14, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.Sponge", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=12} },
    { item="Base.StraightRazor", basePrice=13, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=7} },
    { item="Base.UmbrellaBlack", basePrice=14, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaBlue", basePrice=14, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaRed", basePrice=14, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaTINTED", basePrice=14, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaWhite", basePrice=14, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },

    -- [Building.Fixture.Hardware] [Rarity.Rare] (2 items)
    { item="Base.CombinationPadlock", basePrice=20, tags={"Building.Fixture.Hardware", "Rarity.Rare"}, stockRange={min=0, max=7} },
    { item="Base.Padlock", basePrice=20, tags={"Building.Fixture.Hardware", "Rarity.Rare"}, stockRange={min=0, max=7} },

    -- [Building.Fixture.Plumbing] [Rarity.Common] (13 items)
    { item="Base.Mov_ChemicalToilet", basePrice=19, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_ChromeSink", basePrice=19, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_DarkIndustrialSink", basePrice=20, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_FancyHangingSink", basePrice=19, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_FancyToilet", basePrice=19, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_IndustrialSink", basePrice=20, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_LargeIndustrialSink", basePrice=20, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_LowToilet", basePrice=19, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_Urinal", basePrice=19, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WallShower", basePrice=19, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WaterDispenser", basePrice=19, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteHangingSink", basePrice=19, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteSink", basePrice=19, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=1, max=13} },

    -- [Building.Fixture.Plumbing] [Rarity.Rare] (3 items)
    { item="Base.CanPipe", basePrice=38, tags={"Building.Fixture.Plumbing", "Rarity.Rare"}, stockRange={min=0, max=7} },
    { item="Base.Pipe", basePrice=37, tags={"Building.Fixture.Plumbing", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.ToiletBrush", basePrice=27, tags={"Building.Fixture.Plumbing", "Rarity.Rare"}, stockRange={min=0, max=4} },

    -- [Building.Fixture.Storage] [Rarity.Common] (4 items)
    { item="Base.Mov_BlueWallLocker", basePrice=22, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_GreenWallLocker", basePrice=22, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_MetalLocker", basePrice=22, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_YellowWallLocker", basePrice=22, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=1, max=13} },

    -- [Building.Fixture.Storage] [Rarity.Uncommon] (1 item)
    { item="Base.Mov_MilitaryLocker", basePrice=30, tags={"Building.Fixture.Storage", "Rarity.Uncommon", "Origin.Militia"}, stockRange={min=0, max=8} },

    -- [Building.Fixture.Utility] [Rarity.Common] (2 items)
    { item="Base.Mov_NapkinDispenser", basePrice=21, tags={"Building.Fixture.Utility", "Rarity.Common"}, stockRange={min=1, max=13} },
    { item="Base.Mov_TowelDispenser", basePrice=21, tags={"Building.Fixture.Utility", "Rarity.Common"}, stockRange={min=1, max=13} },
})

print("[DynamicTrading] Fixture Registry Complete")
