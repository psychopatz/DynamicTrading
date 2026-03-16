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

    -- [Resource.Parts] [Rarity.Rare] (28 items)
    { item="Base.ClawhammerHead", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CrudeShortSwordBlade", basePrice=40, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.CrudeShortSwordBlade_NoTang", basePrice=40, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.CrudeSwordBlade", basePrice=40, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.CrudeSwordBlade_Broken", basePrice=12, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.CrudeSwordBlade_Broken_NoTang", basePrice=12, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.CrudeSwordBlade_NoTang", basePrice=40, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.FireAxeHead", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.HandAxeHead", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.HatchetHead_Bone", basePrice=35, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=5} },
    { item="Base.HuntingKnifeBlade", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.KitchenKnifeBlade", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.LargeKnifeBlade", basePrice=40, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.MaceHead", basePrice=40, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.MacheteBlade", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.MacheteBlade_NoTang", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.OldAxeHead", basePrice=40, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.ShortSwordBlade", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.ShortSwordBlade_NoTang", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.SledgehammerHead", basePrice=54, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SpearHead", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneAxeHead", basePrice=49, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.StoneMaceHead", basePrice=49, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.SwordBlade", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SwordBlade_Broken", basePrice=16, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.SwordBlade_Broken_NoTang", basePrice=16, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.SwordBlade_NoTang", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.WoodAxeHead", basePrice=55, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Parts Registry Complete")
