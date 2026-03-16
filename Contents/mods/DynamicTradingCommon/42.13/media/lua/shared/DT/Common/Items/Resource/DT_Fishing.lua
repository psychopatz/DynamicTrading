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

    -- [Resource.Fishing] [Rarity.Rare] (37 items)
    { item="Base.AmericanLadyCaterpillar", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.BaitFish", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.BandedWoolyBearCaterpillar", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Bobber", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.BrokenFishingNet", basePrice=3, tags={"Resource.Fishing", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Centipede", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Centipede2", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Chum", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Cockroach", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Cricket", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.FishGuts", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.FishingHook", basePrice=11, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.FishingHook_Bone", basePrice=11, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.FishingHook_Forged", basePrice=11, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.FishingHookBox", basePrice=46, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.FishingLine", basePrice=42, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.FishingNet", basePrice=16, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.FishingTrash", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Grasshopper", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.JigLure", basePrice=16, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Leech", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Maggots", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.Millipede", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Millipede2", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.MinnowLure", basePrice=16, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.MonarchCaterpillar", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Pillbug", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.PremiumFishingLine", basePrice=42, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=18} },
    { item="Base.SawflyLarva", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.SilkMothCaterpillar", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Slug", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Slug2", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Snail", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.SwallowtailCaterpillar", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Tadpole", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Termites", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.Worm", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
})

print("[DynamicTrading] Fishing Registry Complete")
