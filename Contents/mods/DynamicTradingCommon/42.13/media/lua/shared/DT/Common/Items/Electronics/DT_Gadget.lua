-- ============================================================================
-- Electronics Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Electronics.Gadget.General] [Rarity.Rare] (4 items)
    { item="Base.ElectricWire", basePrice=85, tags={"Electronics.Gadget.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.ElectronicsScrap", basePrice=85, tags={"Electronics.Gadget.General", "Rarity.Rare", "Quality.Waste"}, stockRange={min=0, max=10} },
    { item="Base.HairDryer", basePrice=8, tags={"Electronics.Gadget.General", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.HairIron", basePrice=8, tags={"Electronics.Gadget.General", "Rarity.Rare"}, stockRange={min=0, max=4} },

    -- [Electronics.Gadget.Light.Flashlight] [Rarity.Rare] (4 items)
    { item="Base.CandleBox", basePrice=8, tags={"Electronics.Gadget.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=4} },
    { item="Base.HandTorch", basePrice=2271, tags={"Electronics.Gadget.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=6} },
    { item="Base.PenLight", basePrice=34000, tags={"Electronics.Gadget.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=10} },
    { item="Base.Torch", basePrice=972, tags={"Electronics.Gadget.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=4} },

    -- [Electronics.Gadget.Light.Lantern] [Rarity.Rare] (12 items)
    { item="Base.Lantern_CraftedElectric", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.Lantern_Hurricane", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.Lantern_Hurricane_Copper", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Origin.Police", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.Lantern_Hurricane_CopperLit", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Origin.Police", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.Lantern_Hurricane_Forged", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.Lantern_Hurricane_ForgedLit", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.Lantern_Hurricane_Gold", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Quality.Luxury", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.Lantern_Hurricane_GoldLit", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Quality.Luxury", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.Lantern_Hurricane_Silver", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.Lantern_Hurricane_SilverLit", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.Lantern_HurricaneLit", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.Lantern_Propane", basePrice=486, tags={"Electronics.Gadget.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=2} },

    -- [Electronics.Gadget.Radio.TwoWay.Ham] [Rarity.Common] (1 item)
    { item="Base.HamRadioMakeShift", basePrice=27, tags={"Electronics.Gadget.Radio.TwoWay.Ham", "Rarity.Common", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Transmitter"}, stockRange={min=0, max=2} },

    -- [Electronics.Gadget.Radio.TwoWay.Walkie] [Rarity.Rare] (6 items)
    { item="Base.WalkieTalkie1", basePrice=972, tags={"Electronics.Gadget.Radio.TwoWay.Walkie", "Rarity.Rare", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=4} },
    { item="Base.WalkieTalkie2", basePrice=850, tags={"Electronics.Gadget.Radio.TwoWay.Walkie", "Rarity.Rare", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=4} },
    { item="Base.WalkieTalkie3", basePrice=755, tags={"Electronics.Gadget.Radio.TwoWay.Walkie", "Rarity.Rare", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=4} },
    { item="Base.WalkieTalkie4", basePrice=544, tags={"Electronics.Gadget.Radio.TwoWay.Walkie", "Rarity.Rare", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=4} },
    { item="Base.WalkieTalkie5", basePrice=322, tags={"Electronics.Gadget.Radio.TwoWay.Walkie", "Rarity.Rare", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=4} },
    { item="Base.WalkieTalkieMakeShift", basePrice=972, tags={"Electronics.Gadget.Radio.TwoWay.Walkie", "Rarity.Rare", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=4} },

    -- [Electronics.Gadget.Television] [Rarity.Common] (3 items)
    { item="Base.TvAntique", basePrice=28, tags={"Electronics.Gadget.Television", "Rarity.Common", "Electronics.Communicator"}, stockRange={min=0, max=2} },
    { item="Base.TvBlack", basePrice=44, tags={"Electronics.Gadget.Television", "Rarity.Common", "Electronics.Communicator"}, stockRange={min=0, max=2} },
    { item="Base.TvWideScreen", basePrice=57, tags={"Electronics.Gadget.Television", "Rarity.Common", "Electronics.Communicator"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Gadget Registry Complete")
