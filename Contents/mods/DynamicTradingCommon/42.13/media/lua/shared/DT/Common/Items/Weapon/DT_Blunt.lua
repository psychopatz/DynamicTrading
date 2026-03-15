-- ============================================================================
-- Weapon Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Weapon.Melee.Blunt] [Rarity.Common] (56 items)
    { item="Base.BallPeenHammer", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.BallPeenHammerForged", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.BaseballBat", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_Broken", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.BaseballBat_Broken_Nails", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.BaseballBat_Can", basePrice=3, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_Crafted", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_GardenForkHead", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_Metal", basePrice=3, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_Metal_Bolts", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_Nails", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_RailSpike", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_RakeHead", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_ScrapSheet", basePrice=4, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_Spiked", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BlockMace", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BoneClub", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.BoneClub_Spiked", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BucketMace_Metal", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=0, max=2} },
    { item="Base.BucketMace_Wood", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=0, max=2} },
    { item="Base.ClubHammer", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.ClubHammerForged", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Crowbar", basePrice=6, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.CrowbarForged", basePrice=6, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Golfclub", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Hammer", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.HammerForged", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.HammerStone", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.JawboneBovide_Club", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.KettleMace_Metal", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=0, max=2} },
    { item="Base.KettleMace_Wood", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=0, max=2} },
    { item="Base.LargeBoneClub", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.LargeBoneClub_Spiked", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.LeadPipe", basePrice=3, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.LongMace", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.LongMace_Stone", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.LongSpikedClub", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Mace", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.Mace_Stone", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.MetalPipe", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.MetalPipe_Broken", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.MetalPipe_Railspike", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.Nightstick", basePrice=3, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.PipeWrench", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.ShortBat", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.ShortBat_Can", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.ShortBat_Nails", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.ShortBat_RailSpike", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.ShortBat_RakeHead", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.Sledgehammer", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=0, max=2} },
    { item="Base.Sledgehammer2", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=0, max=2} },
    { item="Base.SledgehammerForged", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=0, max=2} },
    { item="Base.SmithingHammer", basePrice=2, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.SpikedShortBat", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.WoodenMallet", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.Wrench", basePrice=1, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
})

print("[DynamicTrading] Blunt Registry Complete")
