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
    { item="Base.AmericanLadyCaterpillar", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.BaitFish", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.BandedWoolyBearCaterpillar", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Bobber", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.BrokenFishingNet", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Centipede", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Centipede2", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Chum", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Cockroach", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Cricket", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.FishGuts", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.FishingHook", basePrice=36, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.FishingHook_Bone", basePrice=36, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.FishingHook_Forged", basePrice=36, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.FishingHookBox", basePrice=71, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.FishingLine", basePrice=67, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.FishingNet", basePrice=40, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.FishingTrash", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Grasshopper", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.JigLure", basePrice=41, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Leech", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Maggots", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.Millipede", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Millipede2", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.MinnowLure", basePrice=41, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.MonarchCaterpillar", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Pillbug", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.PremiumFishingLine", basePrice=67, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=18} },
    { item="Base.SawflyLarva", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.SilkMothCaterpillar", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Slug", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Slug2", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Snail", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.SwallowtailCaterpillar", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Tadpole", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Termites", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.Worm", basePrice=35, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
})

print("[DynamicTrading] Fishing Registry Complete")
