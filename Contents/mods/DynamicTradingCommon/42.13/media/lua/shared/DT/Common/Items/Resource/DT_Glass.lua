-- ============================================================================
-- Resource Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Resource.Material.Glass] [Rarity.Rare] (6 items)
    { item="Base.CrudeSword_Shard", basePrice=16, tags={"Resource.Material.Glass", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.GlassPanel", basePrice=10, tags={"Resource.Material.Glass", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=14} },
    { item="Base.Katana_Shard", basePrice=30, tags={"Resource.Material.Glass", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.LanternGlass", basePrice=10, tags={"Resource.Material.Glass", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.Sword_Scrap_Shard", basePrice=5, tags={"Resource.Material.Glass", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=9} },
    { item="Base.Sword_Shard", basePrice=30, tags={"Resource.Material.Glass", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Glass Registry Complete")
