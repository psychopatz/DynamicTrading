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
    { item="Base.LargeBellows", basePrice=1, tags={"Resource.Material.General", "Rarity.Common", "Resource.Craftable"}, stockRange={min=1, max=4} },

    -- [Resource.Material.General] [Rarity.Rare] (20 items)
    { item="Base.BarricadeCube_Folded", basePrice=1, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.BlowerFan", basePrice=1, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.BoneBead_Large", basePrice=6, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Coke", basePrice=102, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Dogbane", basePrice=8, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Drawer", basePrice=1, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.HempBroken", basePrice=8, tags={"Resource.Material.General", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.HempScutched", basePrice=8, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Pillow", basePrice=6, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Pillow_Crafted", basePrice=6, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Quicklime", basePrice=6, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.RailroadTrack", basePrice=1, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.RailroadTrackPiece", basePrice=1, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.RakeHead", basePrice=2, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Sheet", basePrice=6, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Sparklers", basePrice=6, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Tarp", basePrice=1, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.TarpPiece", basePrice=3, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.TirePiece", basePrice=2, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.WeldingRods", basePrice=9, tags={"Resource.Material.General", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
})

print("[DynamicTrading] Material Registry Complete")
