-- ============================================================================
-- Container Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Container.Stash.Book] [Rarity.Rare] (6 items)
    { item="Base.HollowBook", basePrice=8, tags={"Container.Stash.Book", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.HollowBook_Handgun", basePrice=8, tags={"Container.Stash.Book", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.HollowBook_Kids", basePrice=8, tags={"Container.Stash.Book", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.HollowBook_Prison", basePrice=8, tags={"Container.Stash.Book", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.HollowBook_Valuables", basePrice=8, tags={"Container.Stash.Book", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.HollowBook_Whiskey", basePrice=8, tags={"Container.Stash.Book", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },

    -- [Container.Stash.Case] [Rarity.Rare] (73 items)
    { item="Base.Cashbox", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.CigarBox", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.CigarBox_Gaming", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.CigarBox_Keepsakes", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.CigarBox_Kids", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.CookieJar", basePrice=13, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.CookieJar_Bear", basePrice=13, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.DiceBag", basePrice=55, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Low"}, stockRange={min=0, max=10} },
    { item="Base.FirstAidKit", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.FirstAidKit_Camping", basePrice=42, tags={"Container.Stash.Case", "Rarity.Rare", "Theme.Survival", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.FirstAidKit_Camping_New", basePrice=42, tags={"Container.Stash.Case", "Rarity.Rare", "Theme.Survival", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.FirstAidKit_Military", basePrice=42, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Militia", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.FirstAidKit_New", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.FirstAidKit_NewPro", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Flightcase", basePrice=45, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.GemBag", basePrice=64, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=10} },
    { item="Base.Guitarcase", basePrice=32, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.HalloweenCandyBucket", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.Hatbox", basePrice=13, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.HollowFancyBook", basePrice=8, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.Humidor", basePrice=13, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.JewelleryBox", basePrice=13, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.JewelleryBox_Fancy", basePrice=13, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Lunchbox", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Lunchbox2", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.MakeupCase_Professional", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.PaperBag", basePrice=128, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=10} },
    { item="Base.Parcel_ExtraLarge", basePrice=85, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.High"}, stockRange={min=0, max=4} },
    { item="Base.Parcel_ExtraSmall", basePrice=4, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.Parcel_Large", basePrice=42, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Parcel_Medium", basePrice=21, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low"}, stockRange={min=0, max=4} },
    { item="Base.Parcel_Small", basePrice=8, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.PencilCase", basePrice=21, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.PencilCase_Gaming", basePrice=21, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.PhotoAlbum", basePrice=42, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low"}, stockRange={min=0, max=6} },
    { item="Base.PhotoAlbum_Old", basePrice=42, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low"}, stockRange={min=0, max=6} },
    { item="Base.PistolCase1", basePrice=51, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.PistolCase2", basePrice=51, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.PistolCase3", basePrice=51, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.Present_ExtraLarge", basePrice=85, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.High"}, stockRange={min=0, max=4} },
    { item="Base.Present_ExtraSmall", basePrice=4, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.Present_Large", basePrice=42, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Present_Medium", basePrice=21, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low"}, stockRange={min=0, max=4} },
    { item="Base.Present_Small", basePrice=8, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.ProduceBox_ExtraLarge", basePrice=85, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.High"}, stockRange={min=0, max=4} },
    { item="Base.ProduceBox_ExtraSmall", basePrice=4, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.ProduceBox_Large", basePrice=42, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.ProduceBox_Medium", basePrice=21, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low"}, stockRange={min=0, max=4} },
    { item="Base.ProduceBox_Small", basePrice=8, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.RevolverCase1", basePrice=51, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.RevolverCase2", basePrice=51, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.RevolverCase3", basePrice=51, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.RifleCase1", basePrice=45, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.RifleCase2", basePrice=45, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.RifleCase3", basePrice=45, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.RifleCase4", basePrice=45, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.SeedBag", basePrice=64, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=10} },
    { item="Base.SewingKit", basePrice=13, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Shoebox", basePrice=13, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.ShotgunCase1", basePrice=45, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.ShotgunCase2", basePrice=45, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Suitcase", basePrice=34, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=2} },
    { item="Base.Tacklebox", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.TakeoutBox_Chinese", basePrice=42, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.TakeoutBox_Styrofoam", basePrice=42, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.Toolbox", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=2} },
    { item="Base.Toolbox_Farming", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=2} },
    { item="Base.Toolbox_Fishing", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=2} },
    { item="Base.Toolbox_Gardening", basePrice=26, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=2} },
    { item="Base.Toolbox_Wooden", basePrice=38, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.ToolRoll_Fabric", basePrice=51, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.ToolRoll_Leather", basePrice=51, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.Wallet_Hide", basePrice=21, tags={"Container.Stash.Case", "Rarity.Rare", "Container.Stash", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Stash Registry Complete")
