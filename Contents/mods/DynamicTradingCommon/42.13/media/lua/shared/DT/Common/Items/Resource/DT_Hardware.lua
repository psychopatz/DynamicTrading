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
    { item="Base.BarbedWire", basePrice=989, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.BarbedWireStack", basePrice=1207, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Buckle", basePrice=966, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Button", basePrice=966, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.CircularSawblade", basePrice=985, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.CircularSawblade_Half", basePrice=986, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.ClayPipeSegment", basePrice=966, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.ClayPipeSegmentUnfired", basePrice=966, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Doorknob", basePrice=977, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.GlassBlowingPipe", basePrice=966, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.GlassBlowingPipeUnfired", basePrice=966, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.HacksawBlade", basePrice=986, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.HeavyChain", basePrice=963, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.HeavyChain_Hook", basePrice=962, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.HeavyChainLink", basePrice=971, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Hinge", basePrice=977, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Katana_Handle", basePrice=966, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Latch", basePrice=971, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Nails", basePrice=973, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=40} },
    { item="Base.NailsBox", basePrice=1093, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.NailsCarton", basePrice=1393, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.NutsBolts", basePrice=967, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Screws", basePrice=967, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=40} },
    { item="Base.ScrewsBox", basePrice=1087, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.ScrewsCarton", basePrice=1387, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SmallHandle", basePrice=977, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.SmallSawblade", basePrice=986, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.SmokingPipe", basePrice=966, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.SmokingPipeUnfired", basePrice=966, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.Wire", basePrice=1015, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.WireStack", basePrice=1207, tags={"Resource.Material.Hardware", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Hardware Registry Complete")
