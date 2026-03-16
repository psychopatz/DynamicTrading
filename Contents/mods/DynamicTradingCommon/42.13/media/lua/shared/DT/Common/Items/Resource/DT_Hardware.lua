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
    { item="Base.BarbedWire", basePrice=5, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.BarbedWireStack", basePrice=4, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.Buckle", basePrice=17, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Button", basePrice=17, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.CircularSawblade", basePrice=17, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.CircularSawblade_Half", basePrice=17, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.ClayPipeSegment", basePrice=6, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayPipeSegmentUnfired", basePrice=6, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Doorknob", basePrice=3, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.GlassBlowingPipe", basePrice=6, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.GlassBlowingPipeUnfired", basePrice=6, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.HacksawBlade", basePrice=68, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.HeavyChain", basePrice=1, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.HeavyChain_Hook", basePrice=1, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.HeavyChainLink", basePrice=3, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Hinge", basePrice=7, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Katana_Handle", basePrice=3, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Latch", basePrice=3, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Nails", basePrice=19, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=100} },
    { item="Base.NailsBox", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.NailsCarton", basePrice=10, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.NutsBolts", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Screws", basePrice=19, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=100} },
    { item="Base.ScrewsBox", basePrice=9, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.ScrewsCarton", basePrice=10, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.SmallHandle", basePrice=3, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.SmallSawblade", basePrice=68, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.SmokingPipe", basePrice=6, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.SmokingPipeUnfired", basePrice=6, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Wire", basePrice=14, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.WireStack", basePrice=4, tags={"Resource.Material.Hardware", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Hardware Registry Complete")
