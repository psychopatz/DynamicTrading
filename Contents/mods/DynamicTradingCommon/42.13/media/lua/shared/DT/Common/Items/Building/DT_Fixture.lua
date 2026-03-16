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
    { item="Base.Mov_AntiqueStove", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_BlueComboWasherDryer", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_BlueFridge", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_ChestFreezer", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_FridgeMini", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_GreenFridge", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_GreenOven", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_GreyOven", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_IndustrialDishwasher", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_IndustrialFridge", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_IndustrialOven", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_Microwave", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_Microwave2", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_ModernOven", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_PlainFridge", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_PopsicleFreezer", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_RedFridge", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_RedOven", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_SnackVendingMachine", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_SodaMachine", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_SodaMachineLarge", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_SodaVendingMachine", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_SteelFridge", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_Toaster", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_TrailerFridge", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteFridge", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteIndustrialFridge", basePrice=7, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },

    -- [Building.Fixture.Communication] [Rarity.Common] (7 items)
    { item="Base.Mov_BeigeRotaryPhone", basePrice=7, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_BlackModernPhone", basePrice=7, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_BlackRotaryPhone", basePrice=7, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_PayPhones", basePrice=7, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_RedRotaryPhone", basePrice=7, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteModernPhone", basePrice=7, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteRotaryPhone", basePrice=7, tags={"Building.Fixture.Communication", "Rarity.Common"}, stockRange={min=3, max=15} },

    -- [Building.Fixture.General] [Rarity.Rare] (22 items)
    { item="Base.AlarmClock2", basePrice=9, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.BathTowelWet", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Calculator", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Clipboard", basePrice=9, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.DishClothWet", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Doily", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Eraser", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MagnifyingGlass", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.MarkerBlack", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerBlue", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerGreen", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MarkerRed", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.RippedSheets", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.RippedSheetsDirty", basePrice=3, tags={"Building.Fixture.General", "Rarity.Rare", "Quality.Waste", "Quality.Waste"}, stockRange={min=0, max=10} },
    { item="Base.ScissorsBlunt", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Sponge", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.StraightRazor", basePrice=10, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.UmbrellaBlack", basePrice=9, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaBlue", basePrice=9, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaRed", basePrice=9, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaTINTED", basePrice=9, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaWhite", basePrice=9, tags={"Building.Fixture.General", "Rarity.Rare"}, stockRange={min=0, max=4} },

    -- [Building.Fixture.Hardware] [Rarity.Rare] (2 items)
    { item="Base.CombinationPadlock", basePrice=10, tags={"Building.Fixture.Hardware", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Padlock", basePrice=10, tags={"Building.Fixture.Hardware", "Rarity.Rare"}, stockRange={min=0, max=6} },

    -- [Building.Fixture.Plumbing] [Rarity.Common] (13 items)
    { item="Base.Mov_ChemicalToilet", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_ChromeSink", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_DarkIndustrialSink", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_FancyHangingSink", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_FancyToilet", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_IndustrialSink", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_LargeIndustrialSink", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Industrial"}, stockRange={min=3, max=15} },
    { item="Base.Mov_LowToilet", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_Urinal", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WallShower", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WaterDispenser", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteHangingSink", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_WhiteSink", basePrice=7, tags={"Building.Fixture.Plumbing", "Rarity.Common"}, stockRange={min=3, max=15} },

    -- [Building.Fixture.Plumbing] [Rarity.Rare] (3 items)
    { item="Base.CanPipe", basePrice=10, tags={"Building.Fixture.Plumbing", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Pipe", basePrice=9, tags={"Building.Fixture.Plumbing", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.ToiletBrush", basePrice=10, tags={"Building.Fixture.Plumbing", "Rarity.Rare"}, stockRange={min=0, max=4} },

    -- [Building.Fixture.Storage] [Rarity.Common] (4 items)
    { item="Base.Mov_BlueWallLocker", basePrice=7, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_GreenWallLocker", basePrice=7, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_MetalLocker", basePrice=7, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_YellowWallLocker", basePrice=7, tags={"Building.Fixture.Storage", "Rarity.Common"}, stockRange={min=3, max=15} },

    -- [Building.Fixture.Storage] [Rarity.Uncommon] (1 item)
    { item="Base.Mov_MilitaryLocker", basePrice=9, tags={"Building.Fixture.Storage", "Rarity.Uncommon", "Origin.Militia"}, stockRange={min=3, max=15} },

    -- [Building.Fixture.Utility] [Rarity.Common] (2 items)
    { item="Base.Mov_NapkinDispenser", basePrice=7, tags={"Building.Fixture.Utility", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Mov_TowelDispenser", basePrice=7, tags={"Building.Fixture.Utility", "Rarity.Common"}, stockRange={min=3, max=15} },
})

print("[DynamicTrading] Fixture Registry Complete")
