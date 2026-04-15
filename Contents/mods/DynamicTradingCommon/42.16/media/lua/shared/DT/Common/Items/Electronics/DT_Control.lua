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

    -- [Electronics.Gadget.Control] [Rarity.Common] (1 item)
    { item="Base.ScannerModule", basePrice=25, tags={"Electronics.Gadget.Control", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=13} },

    -- [Electronics.Gadget.Control] [Rarity.Rare] (9 items)
    { item="Base.HomeAlarm", basePrice=44, tags={"Electronics.Gadget.Control", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=2} },
    { item="Base.MotionSensor", basePrice=126, tags={"Electronics.Gadget.Control", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.PowerBar", basePrice=136, tags={"Electronics.Gadget.Control", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Remote", basePrice=137, tags={"Electronics.Gadget.Control", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.RemoteCraftedV1", basePrice=219, tags={"Electronics.Gadget.Control", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.RemoteCraftedV2", basePrice=219, tags={"Electronics.Gadget.Control", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.RemoteCraftedV3", basePrice=219, tags={"Electronics.Gadget.Control", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.TimerCrafted", basePrice=161, tags={"Electronics.Gadget.Control", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.TriggerCrafted", basePrice=126, tags={"Electronics.Gadget.Control", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
})

print("[DynamicTrading] Control Registry Complete")
