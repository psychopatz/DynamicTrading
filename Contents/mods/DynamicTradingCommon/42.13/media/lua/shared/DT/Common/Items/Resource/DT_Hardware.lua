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

    -- [Resource.Material.Hardware] [Rarity.Rare] (31 items)
    { item="Base.BarbedWire", basePrice=32, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.BarbedWireStack", basePrice=237, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.Buckle", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Button", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.CircularSawblade", basePrice=8, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.CircularSawblade_Half", basePrice=8, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.ClayPipeSegment", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayPipeSegmentUnfired", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Doorknob", basePrice=20, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.GlassBlowingPipe", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.GlassBlowingPipeUnfired", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.HacksawBlade", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.HeavyChain", basePrice=5, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.HeavyChain_Hook", basePrice=4, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.HeavyChainLink", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Hinge", basePrice=20, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Katana_Handle", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Latch", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Nails", basePrice=10, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=100} },
    { item="Base.NailsBox", basePrice=124, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.NailsCarton", basePrice=419, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.NutsBolts", basePrice=10, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Screws", basePrice=10, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=100} },
    { item="Base.ScrewsBox", basePrice=124, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.ScrewsCarton", basePrice=419, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.SmallHandle", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.SmallSawblade", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.SmokingPipe", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.SmokingPipeUnfired", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Wire", basePrice=43, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.WireStack", basePrice=237, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Hardware Registry Complete")
