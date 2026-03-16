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
    { item="Base.LargeBellows", basePrice=530, tags={"Resource.Material.General", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },

    -- [Resource.Material.General] [Rarity.Rare] (20 items)
    { item="Base.BarricadeCube_Folded", basePrice=958, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BlowerFan", basePrice=961, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.BoneBead_Large", basePrice=963, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.Coke", basePrice=1018, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.Dogbane", basePrice=963, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=14} },
    { item="Base.Drawer", basePrice=962, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.HempBroken", basePrice=289, tags={"Resource.Material.General", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=16} },
    { item="Base.HempScutched", basePrice=963, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=14} },
    { item="Base.Pillow", basePrice=982, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.Pillow_Crafted", basePrice=982, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.Quicklime", basePrice=963, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.RailroadTrack", basePrice=957, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.RailroadTrackPiece", basePrice=959, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.RakeHead", basePrice=968, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.Sheet", basePrice=982, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.Sparklers", basePrice=963, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.Tarp", basePrice=977, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.TarpPiece", basePrice=977, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.TirePiece", basePrice=979, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.WeldingRods", basePrice=1006, tags={"Resource.Material.General", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Material Registry Complete")
