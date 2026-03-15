-- ============================================================================
-- Tool Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Tool.General] [Rarity.Common] (2 items)
    { item="Base.HamRadio1", basePrice=1067, tags={"Tool.General", "Rarity.Common", "Tool.Durable", "Tool.MediumUse"}, stockRange={min=0, max=2} },
    { item="Base.HamRadio2", basePrice=757, tags={"Tool.General", "Rarity.Common", "Tool.Durable", "Tool.MediumUse"}, stockRange={min=0, max=2} },

    -- [Tool.General] [Rarity.Rare] (9 items)
    { item="Base.CarBattery1", basePrice=5440000, tags={"Tool.General", "Rarity.Rare", "Tool.Durable", "Tool.HighUse"}, stockRange={min=0, max=2} },
    { item="Base.CarBattery2", basePrice=5440000, tags={"Tool.General", "Rarity.Rare", "Tool.Durable", "Tool.HighUse"}, stockRange={min=0, max=2} },
    { item="Base.CarBattery3", basePrice=5440000, tags={"Tool.General", "Rarity.Rare", "Tool.Durable", "Tool.HighUse"}, stockRange={min=0, max=2} },
    { item="Base.CDplayer", basePrice=37740, tags={"Tool.General", "Rarity.Rare", "Tool.Durable", "Tool.HighUse"}, stockRange={min=0, max=4} },
    { item="Base.Fleshing_Tool", basePrice=34, tags={"Tool.General", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.Fleshing_Tool_Bone", basePrice=17, tags={"Tool.General", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.KnappingTool", basePrice=227, tags={"Tool.General", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.ManPackRadio", basePrice=1287, tags={"Tool.General", "Rarity.Rare", "Tool.Durable", "Tool.MediumUse"}, stockRange={min=0, max=1} },
    { item="Base.SheepElectricShears", basePrice=90667, tags={"Tool.General", "Rarity.Rare", "Tool.HighUse"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] General Registry Complete")
