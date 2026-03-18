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
    { item="Base.BarbedWire", basePrice=84, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.BarbedWireStack", basePrice=302, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Buckle", basePrice=61, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Button", basePrice=61, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.CircularSawblade", basePrice=81, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.CircularSawblade_Half", basePrice=81, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.ClayPipeSegment", basePrice=61, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.ClayPipeSegmentUnfired", basePrice=61, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Doorknob", basePrice=72, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.GlassBlowingPipe", basePrice=61, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.GlassBlowingPipeUnfired", basePrice=61, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.HacksawBlade", basePrice=81, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.HeavyChain", basePrice=58, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.HeavyChain_Hook", basePrice=58, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.HeavyChainLink", basePrice=67, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Hinge", basePrice=72, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Katana_Handle", basePrice=61, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Latch", basePrice=67, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Nails", basePrice=68, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=40} },
    { item="Base.NailsBox", basePrice=188, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.NailsCarton", basePrice=488, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.NutsBolts", basePrice=62, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Screws", basePrice=62, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=40} },
    { item="Base.ScrewsBox", basePrice=182, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.ScrewsCarton", basePrice=482, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SmallHandle", basePrice=72, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.SmallSawblade", basePrice=81, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.SmokingPipe", basePrice=61, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.SmokingPipeUnfired", basePrice=61, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Wire", basePrice=110, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.WireStack", basePrice=302, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Hardware Registry Complete")
