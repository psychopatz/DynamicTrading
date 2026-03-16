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
    { item="Base.AmericanLadyCaterpillar", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.BaitFish", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.BandedWoolyBearCaterpillar", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Bobber", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.BrokenFishingNet", basePrice=152, tags={"Resource.Fishing", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Centipede", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Centipede2", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Chum", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Cockroach", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Cricket", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.FishGuts", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.FishingHook", basePrice=509, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.FishingHook_Bone", basePrice=509, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.FishingHook_Forged", basePrice=509, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.FishingHookBox", basePrice=544, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.FishingLine", basePrice=539, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=11} },
    { item="Base.FishingNet", basePrice=513, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.FishingTrash", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Grasshopper", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.JigLure", basePrice=513, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Leech", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Maggots", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.Millipede", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Millipede2", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.MinnowLure", basePrice=513, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.MonarchCaterpillar", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Pillbug", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.PremiumFishingLine", basePrice=539, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=18} },
    { item="Base.SawflyLarva", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.SilkMothCaterpillar", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Slug", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Slug2", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Snail", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.SwallowtailCaterpillar", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Tadpole", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },
    { item="Base.Termites", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
    { item="Base.Worm", basePrice=507, tags={"Resource.Fishing", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=30} },
})

print("[DynamicTrading] Fishing Registry Complete")
