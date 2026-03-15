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
    { item="Base.AmericanLadyCaterpillar", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.BaitFish", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.BandedWoolyBearCaterpillar", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bobber", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.BrokenFishingNet", basePrice=2, tags={"Resource.Fishing", "Rarity.Rare", "Quality.Waste"}, stockRange={min=0, max=4} },
    { item="Base.Centipede", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Centipede2", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Chum", basePrice=3, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Cockroach", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Cricket", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.FishGuts", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.FishingHook", basePrice=19, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.FishingHook_Bone", basePrice=19, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.FishingHook_Forged", basePrice=19, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.FishingHookBox", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.FishingLine", basePrice=45, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.FishingNet", basePrice=2, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.FishingTrash", basePrice=3, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Grasshopper", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.JigLure", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Leech", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Maggots", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Millipede", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Millipede2", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MinnowLure", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.MonarchCaterpillar", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Pillbug", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.PremiumFishingLine", basePrice=136, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SawflyLarva", basePrice=340, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SilkMothCaterpillar", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Slug", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Slug2", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Snail", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SwallowtailCaterpillar", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Tadpole", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Termites", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Worm", basePrice=17, tags={"Resource.Fishing", "Rarity.Rare"}, stockRange={min=0, max=20} },
})

print("[DynamicTrading] Fishing Registry Complete")
