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

    -- [Tool.General] [Rarity.Rare] (4 items)
    { item="Base.Fleshing_Tool", basePrice=76, tags={"Tool.General", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.Fleshing_Tool_Bone", basePrice=57, tags={"Tool.General", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.KnappingTool", basePrice=97, tags={"Tool.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.SheepElectricShears", basePrice=216, tags={"Tool.General", "Rarity.Rare", "Origin.Vanilla", "Tool.HighUse"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] General Registry Complete")
