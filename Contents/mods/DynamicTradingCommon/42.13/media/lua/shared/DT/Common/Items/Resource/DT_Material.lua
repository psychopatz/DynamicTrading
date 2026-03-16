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

    -- [Resource.Material.General] [Rarity.Common] (1 item)
    { item="Base.LargeBellows", basePrice=3, tags={"Resource.Material.General", "Rarity.Common", "Resource.Craftable"}, stockRange={min=0, max=2} },

    -- [Resource.Material.General] [Rarity.Rare] (20 items)
    { item="Base.BarricadeCube_Folded", basePrice=5, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BlowerFan", basePrice=9, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.BoneBead_Large", basePrice=10, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.Coke", basePrice=65, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.Dogbane", basePrice=10, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=14} },
    { item="Base.Drawer", basePrice=9, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.HempBroken", basePrice=3, tags={"Resource.Material.General", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=16} },
    { item="Base.HempScutched", basePrice=10, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=14} },
    { item="Base.Pillow", basePrice=30, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.Pillow_Crafted", basePrice=30, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.Quicklime", basePrice=10, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.RailroadTrack", basePrice=4, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.RailroadTrackPiece", basePrice=6, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.RakeHead", basePrice=16, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.Sheet", basePrice=30, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.Sparklers", basePrice=10, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.Tarp", basePrice=24, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.TarpPiece", basePrice=25, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.TirePiece", basePrice=26, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.WeldingRods", basePrice=53, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Material Registry Complete")
