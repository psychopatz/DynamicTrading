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
    { item="Base.AmericanLadyCaterpillar", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.BaitFish", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.BandedWoolyBearCaterpillar", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bobber", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.BrokenFishingNet", basePrice=3, tags={"Resource.Fishing", "Rarity.Rare", "Quality.Waste"}, stockRange={min=0, max=4} },
    { item="Base.Centipede", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Centipede2", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Chum", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Cockroach", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Cricket", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.FishGuts", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.FishingHook", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.FishingHook_Bone", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.FishingHook_Forged", basePrice=10, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.FishingHookBox", basePrice=32, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.FishingLine", basePrice=20, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.FishingNet", basePrice=8, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.FishingTrash", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Grasshopper", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.JigLure", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Leech", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Maggots", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Millipede", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Millipede2", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MinnowLure", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MonarchCaterpillar", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Pillbug", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.PremiumFishingLine", basePrice=20, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SawflyLarva", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SilkMothCaterpillar", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Slug", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Slug2", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Snail", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SwallowtailCaterpillar", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Tadpole", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Termites", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Worm", basePrice=9, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
})

print("[DynamicTrading] Fishing Registry Complete")
