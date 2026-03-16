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
    { item="Base.BallPeenHammer", basePrice=80, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BallPeenHammerForged", basePrice=80, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BaseballBat", basePrice=121, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Broken", basePrice=18, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.BaseballBat_Broken_Nails", basePrice=21, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.BaseballBat_Can", basePrice=136, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Crafted", basePrice=121, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_GardenForkHead", basePrice=116, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Metal", basePrice=135, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Metal_Bolts", basePrice=138, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Nails", basePrice=123, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_RailSpike", basePrice=117, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_RakeHead", basePrice=85, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_ScrapSheet", basePrice=45, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Spiked", basePrice=117, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BlockMace", basePrice=83, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BoneClub", basePrice=64, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BoneClub_Spiked", basePrice=83, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BucketMace_Metal", basePrice=130, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.BucketMace_Wood", basePrice=130, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.ClubHammer", basePrice=80, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.ClubHammerForged", basePrice=80, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Crowbar", basePrice=104, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.CrowbarForged", basePrice=104, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Golfclub", basePrice=101, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Hammer", basePrice=80, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.HammerForged", basePrice=80, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.HammerStone", basePrice=66, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.JawboneBovide_Club", basePrice=79, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.KettleMace_Metal", basePrice=143, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.KettleMace_Wood", basePrice=143, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.LargeBoneClub", basePrice=66, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LargeBoneClub_Spiked", basePrice=85, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LeadPipe", basePrice=118, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.LongMace", basePrice=126, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LongMace_Stone", basePrice=121, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LongSpikedClub", basePrice=96, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Mace", basePrice=104, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Mace_Stone", basePrice=103, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.MetalPipe", basePrice=96, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.MetalPipe_Broken", basePrice=26, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.MetalPipe_Railspike", basePrice=96, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Nightstick", basePrice=116, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.PipeWrench", basePrice=75, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat", basePrice=80, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat_Can", basePrice=96, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.ShortBat_Nails", basePrice=84, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat_RailSpike", basePrice=96, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat_RakeHead", basePrice=76, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Sledgehammer", basePrice=88, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Sledgehammer2", basePrice=88, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SledgehammerForged", basePrice=88, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SmithingHammer", basePrice=80, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.SpikedShortBat", basePrice=94, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.WoodenMallet", basePrice=75, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Wrench", basePrice=74, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Blunt Registry Complete")
