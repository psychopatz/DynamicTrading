-- ============================================================================
-- Clothing Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Clothing.Face] [Rarity.Common] (12 items)
    { item="Base.Hat_BandanaMask", basePrice=20, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Hat_BandanaMask_Green", basePrice=20, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Hat_BandanaMaskTINT", basePrice=20, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Hat_HalloweenMaskDevil", basePrice=26, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla", "Clothing.WindResistant"}, stockRange={min=2, max=14} },
    { item="Base.Hat_HalloweenMaskMonster", basePrice=26, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla", "Clothing.WindResistant"}, stockRange={min=2, max=14} },
    { item="Base.Hat_HalloweenMaskPumpkin", basePrice=26, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla", "Clothing.WindResistant"}, stockRange={min=2, max=14} },
    { item="Base.Hat_HalloweenMaskSkeleton", basePrice=26, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla", "Clothing.WindResistant"}, stockRange={min=2, max=14} },
    { item="Base.Hat_HalloweenMaskVampire", basePrice=26, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla", "Clothing.WindResistant"}, stockRange={min=2, max=14} },
    { item="Base.Hat_HalloweenMaskWitch", basePrice=26, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla", "Clothing.WindResistant"}, stockRange={min=2, max=14} },
    { item="Base.Hat_RagBandanaMask", basePrice=20, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Hat_SurgicalMask", basePrice=22, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla", "Theme.Clinical"}, stockRange={min=3, max=17} },
    { item="Base.WeldingMask", basePrice=86, tags={"Clothing.Face", "Rarity.Common", "Origin.Vanilla", "Clothing.Protective", "Clothing.BiteResistant", "Clothing.ScratchResistant", "Clothing.WindResistant"}, stockRange={min=4, max=23} },

    -- [Clothing.Face] [Rarity.Rare] (4 items)
    { item="Base.Hat_BalaclavaFace", basePrice=57, tags={"Clothing.Face", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=7} },
    { item="Base.Hat_BalaclavaFull", basePrice=62, tags={"Clothing.Face", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=7} },
    { item="Base.ShemaghScarfFace", basePrice=62, tags={"Clothing.Face", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=7} },
    { item="Base.ShemaghScarfFace_Green", basePrice=62, tags={"Clothing.Face", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=7} },
})

print("[DynamicTrading] Face Registry Complete")
