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
    { item="Base.Hat_BandanaMask", basePrice=4, tags={"Clothing.Face", "Rarity.Common"}, stockRange={min=5, max=25} },
    { item="Base.Hat_BandanaMask_Green", basePrice=4, tags={"Clothing.Face", "Rarity.Common"}, stockRange={min=5, max=25} },
    { item="Base.Hat_BandanaMaskTINT", basePrice=4, tags={"Clothing.Face", "Rarity.Common"}, stockRange={min=5, max=25} },
    { item="Base.Hat_HalloweenMaskDevil", basePrice=8, tags={"Clothing.Face", "Rarity.Common", "Clothing.WindResistant"}, stockRange={min=3, max=15} },
    { item="Base.Hat_HalloweenMaskMonster", basePrice=8, tags={"Clothing.Face", "Rarity.Common", "Clothing.WindResistant"}, stockRange={min=3, max=15} },
    { item="Base.Hat_HalloweenMaskPumpkin", basePrice=8, tags={"Clothing.Face", "Rarity.Common", "Clothing.WindResistant"}, stockRange={min=3, max=15} },
    { item="Base.Hat_HalloweenMaskSkeleton", basePrice=8, tags={"Clothing.Face", "Rarity.Common", "Clothing.WindResistant"}, stockRange={min=3, max=15} },
    { item="Base.Hat_HalloweenMaskVampire", basePrice=8, tags={"Clothing.Face", "Rarity.Common", "Clothing.WindResistant"}, stockRange={min=3, max=15} },
    { item="Base.Hat_HalloweenMaskWitch", basePrice=8, tags={"Clothing.Face", "Rarity.Common", "Clothing.WindResistant"}, stockRange={min=3, max=15} },
    { item="Base.Hat_RagBandanaMask", basePrice=4, tags={"Clothing.Face", "Rarity.Common"}, stockRange={min=5, max=25} },
    { item="Base.Hat_SurgicalMask", basePrice=3, tags={"Clothing.Face", "Rarity.Common", "Origin.Clinical"}, stockRange={min=5, max=25} },
    { item="Base.WeldingMask", basePrice=177, tags={"Clothing.Face", "Rarity.Common", "Clothing.Protective", "Clothing.BiteResistant", "Clothing.ScratchResistant", "Clothing.WindResistant"}, stockRange={min=3, max=15} },

    -- [Clothing.Face] [Rarity.Rare] (4 items)
    { item="Base.Hat_BalaclavaFace", basePrice=20, tags={"Clothing.Face", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=6} },
    { item="Base.Hat_BalaclavaFull", basePrice=24, tags={"Clothing.Face", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=6} },
    { item="Base.ShemaghScarfFace", basePrice=32, tags={"Clothing.Face", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=6} },
    { item="Base.ShemaghScarfFace_Green", basePrice=32, tags={"Clothing.Face", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Face Registry Complete")
