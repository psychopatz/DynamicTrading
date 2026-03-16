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
    { item="Base.Mov_AntiqueStove", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_BlueComboWasherDryer", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_BlueFridge", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_ChestFreezer", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_FridgeMini", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_GreenFridge", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_GreenOven", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_GreyOven", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_IndustrialDishwasher", basePrice=1136, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla", "Theme.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_IndustrialFridge", basePrice=1136, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla", "Theme.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_IndustrialOven", basePrice=1136, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla", "Theme.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_Microwave", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_Microwave2", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_ModernOven", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_PlainFridge", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_PopsicleFreezer", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_RedFridge", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_RedOven", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_SnackVendingMachine", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_SodaMachine", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_SodaMachineLarge", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_SodaVendingMachine", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_SteelFridge", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_Toaster", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_TrailerFridge", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteFridge", basePrice=765, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteIndustrialFridge", basePrice=1136, tags={"Building.Fixture.Appliance", "Rarity.Common", "Origin.Vanilla", "Theme.Industrial"}, stockRange={min=1, max=11} },

    -- [Building.Fixture.Communication] [Rarity.Common] (7 items)
    { item="Base.Mov_BeigeRotaryPhone", basePrice=654, tags={"Building.Fixture.Communication", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_BlackModernPhone", basePrice=654, tags={"Building.Fixture.Communication", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_BlackRotaryPhone", basePrice=654, tags={"Building.Fixture.Communication", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_PayPhones", basePrice=654, tags={"Building.Fixture.Communication", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_RedRotaryPhone", basePrice=654, tags={"Building.Fixture.Communication", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteModernPhone", basePrice=654, tags={"Building.Fixture.Communication", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteRotaryPhone", basePrice=654, tags={"Building.Fixture.Communication", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },

    -- [Building.Fixture.General] [Rarity.Rare] (22 items)
    { item="Base.AlarmClock2", basePrice=1144, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.BathTowelWet", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Calculator", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Clipboard", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.DishClothWet", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Doily", basePrice=1128, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Eraser", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.MagnifyingGlass", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.MarkerBlack", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.MarkerBlue", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.MarkerGreen", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.MarkerRed", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.RippedSheets", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.RippedSheetsDirty", basePrice=340, tags={"Building.Fixture.General", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Quality.Waste"}, stockRange={min=0, max=14} },
    { item="Base.ScissorsBlunt", basePrice=1133, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Sponge", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.StraightRazor", basePrice=1132, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.UmbrellaBlack", basePrice=1133, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaBlue", basePrice=1133, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaRed", basePrice=1133, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaTINTED", basePrice=1133, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.UmbrellaWhite", basePrice=1133, tags={"Building.Fixture.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },

    -- [Building.Fixture.Hardware] [Rarity.Rare] (2 items)
    { item="Base.CombinationPadlock", basePrice=1139, tags={"Building.Fixture.Hardware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Padlock", basePrice=1139, tags={"Building.Fixture.Hardware", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },

    -- [Building.Fixture.Plumbing] [Rarity.Common] (13 items)
    { item="Base.Mov_ChemicalToilet", basePrice=778, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_ChromeSink", basePrice=778, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_DarkIndustrialSink", basePrice=1150, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla", "Theme.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_FancyHangingSink", basePrice=778, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_FancyToilet", basePrice=778, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_IndustrialSink", basePrice=1150, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla", "Theme.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_LargeIndustrialSink", basePrice=1150, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla", "Theme.Industrial"}, stockRange={min=1, max=11} },
    { item="Base.Mov_LowToilet", basePrice=778, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_Urinal", basePrice=778, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WallShower", basePrice=778, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WaterDispenser", basePrice=778, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteHangingSink", basePrice=778, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_WhiteSink", basePrice=778, tags={"Building.Fixture.Plumbing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },

    -- [Building.Fixture.Plumbing] [Rarity.Rare] (3 items)
    { item="Base.CanPipe", basePrice=1327, tags={"Building.Fixture.Plumbing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Pipe", basePrice=1326, tags={"Building.Fixture.Plumbing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.ToiletBrush", basePrice=1316, tags={"Building.Fixture.Plumbing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },

    -- [Building.Fixture.Storage] [Rarity.Common] (4 items)
    { item="Base.Mov_BlueWallLocker", basePrice=664, tags={"Building.Fixture.Storage", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_GreenWallLocker", basePrice=664, tags={"Building.Fixture.Storage", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_MetalLocker", basePrice=664, tags={"Building.Fixture.Storage", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_YellowWallLocker", basePrice=664, tags={"Building.Fixture.Storage", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },

    -- [Building.Fixture.Storage] [Rarity.Uncommon] (1 item)
    { item="Base.Mov_MilitaryLocker", basePrice=1536, tags={"Building.Fixture.Storage", "Rarity.Uncommon", "Origin.Vanilla", "Theme.Militia"}, stockRange={min=0, max=8} },

    -- [Building.Fixture.Utility] [Rarity.Common] (2 items)
    { item="Base.Mov_NapkinDispenser", basePrice=663, tags={"Building.Fixture.Utility", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
    { item="Base.Mov_TowelDispenser", basePrice=663, tags={"Building.Fixture.Utility", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=1, max=13} },
})

print("[DynamicTrading] Fixture Registry Complete")
