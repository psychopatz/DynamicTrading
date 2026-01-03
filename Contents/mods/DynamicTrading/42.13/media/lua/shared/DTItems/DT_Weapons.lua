require "DynamicTrading_Config"
if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        -- data.item is the ID (e.g. "Base.Axe")
        DynamicTrading.AddItem(data.item, data)
    end
end


Register({
    -- ==========================================================
    -- MELEE WEAPONS: AXES
    -- Balancing: Based on tree-cutting utility + high combat damage.
    -- ==========================================================
    -- High-Tier Axes
    { item="Base.Axe", category="Weapon", tags={"Blade", "Heavy", "Survivalist"}, basePrice=150, stockRange={min=1, max=3} },
    { item="Base.Axe_Old", category="Weapon", tags={"Blade", "Heavy"}, basePrice=110, stockRange={min=1, max=2} },
    { item="Base.WoodAxe", category="Weapon", tags={"Blade", "Heavy", "Carpenter"}, basePrice=180, stockRange={min=0, max=2} },
    { item="Base.WoodAxeForged", category="Weapon", tags={"Blade", "Heavy", "Rare"}, basePrice=220, stockRange={min=0, max=1} },
    { item="Base.PickAxe", category="Weapon", tags={"Heavy", "Mechanic"}, basePrice=160, stockRange={min=0, max=2} },
    { item="Base.PickAxeForged", category="Weapon", tags={"Heavy", "Rare"}, basePrice=190, stockRange={min=0, max=1} },

    -- Mid-Tier / One-Handed
    { item="Base.HandAxe", category="Weapon", tags={"Blade", "Survivalist"}, basePrice=75, stockRange={min=1, max=4} },
    { item="Base.HandAxe_Old", category="Weapon", tags={"Blade"}, basePrice=55, stockRange={min=1, max=3} },
    { item="Base.HandAxeForged", category="Weapon", tags={"Blade", "Rare"}, basePrice=90, stockRange={min=0, max=2} },
    { item="Base.Hatchet", category="Weapon", tags={"Blade", "Survivalist"}, basePrice=70, stockRange={min=1, max=4} }, -- Alias for HandAxe usually
    { item="Base.IceAxe", category="Weapon", tags={"Blade", "Rare"}, basePrice=100, stockRange={min=0, max=1} },

    -- Cleavers & Specialized
    { item="Base.MeatCleaver", category="Weapon", tags={"Blade", "Butcher"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.MeatCleaverForged", category="Weapon", tags={"Blade", "Butcher"}, basePrice=60, stockRange={min=0, max=2} },
    { item="Base.HandScythe", category="Weapon", tags={"Blade", "Farmer"}, basePrice=50, stockRange={min=1, max=3} },
    { item="Base.HandScytheForged", category="Weapon", tags={"Blade", "Farmer"}, basePrice=65, stockRange={min=0, max=2} },

    -- Scrap / Improvised Axes
    { item="Base.AxeStone", category="Weapon", tags={"Blade", "Survivalist", "Junk"}, basePrice=15, stockRange={min=2, max=6} },
    { item="Base.StoneAxeLarge", category="Weapon", tags={"Blade", "Survivalist"}, basePrice=25, stockRange={min=1, max=4} },
    { item="Base.Axe_ScrapCleaver", category="Weapon", tags={"Blade", "Scavenger"}, basePrice=55, stockRange={min=1, max=3} },
    { item="Base.Axe_Sawblade", category="Weapon", tags={"Blade", "Scavenger"}, basePrice=85, stockRange={min=0, max=2} },
    { item="Base.Axe_Sawblade_Hatchet", category="Weapon", tags={"Blade", "Scavenger"}, basePrice=65, stockRange={min=1, max=3} },
    { item="Base.ScrapWeapon_Brake", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=80, stockRange={min=0, max=2} },
    { item="Base.Cudgel_Brake", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=95, stockRange={min=0, max=1} },
    { item="Base.Cudgel_Sawblade", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=90, stockRange={min=0, max=1} },
    { item="Base.Cudgel_SpadeHead", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=85, stockRange={min=0, max=1} },

    -- Primitive / Bone
    { item="Base.Hatchet_Bone", category="Weapon", tags={"Blade", "Butcher"}, basePrice=30, stockRange={min=1, max=3} },
    { item="Base.JawboneBovide_Axe", category="Weapon", tags={"Blade", "Butcher"}, basePrice=35, stockRange={min=1, max=3} },
    { item="Base.Saw_Flint", category="Weapon", tags={"Blade", "Survivalist"}, basePrice=20, stockRange={min=1, max=4} },
    { item="Base.PrimitiveScythe", category="Weapon", tags={"Blade", "Farmer"}, basePrice=25, stockRange={min=1, max=3} },

    -- Miscellaneous Crafting Axe-types
    { item="Base.TableLeg_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=40, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_RailSpike", category="Weapon", tags={"Survivalist"}, basePrice=65, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=75, stockRange={min=0, max=2} },
    { item="Base.FieldHockeyStick_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=45, stockRange={min=0, max=2} },
    { item="Base.EntrenchingTool", category="Weapon", tags={"Survivalist", "Military"}, basePrice=55, stockRange={min=1, max=3} },
    { item="Base.ScrapWeaponGardenFork", category="Weapon", tags={"Farmer", "Scavenger"}, basePrice=70, stockRange={min=0, max=2} },
    { item="Base.MetalPipe_Railspike", category="Weapon", tags={"Scavenger"}, basePrice=45, stockRange={min=0, max=2} },
    { item="Base.LongHandle_Railspike", category="Weapon", tags={"Scavenger"}, basePrice=35, stockRange={min=0, max=3} },
    { item="Base.LongHandle_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=40, stockRange={min=0, max=3} },
    { item="Base.Plank_Brake", category="Weapon", tags={"Scavenger"}, basePrice=50, stockRange={min=0, max=3} },
    { item="Base.Plank_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=45, stockRange={min=0, max=3} },
    { item="Base.MeatCleaver_Scrap", category="Weapon", tags={"Scavenger", "Butcher"}, basePrice=25, stockRange={min=1, max=4} },
    { item="Base.ShortBat_RailSpike", category="Weapon", tags={"Scavenger"}, basePrice=40, stockRange={min=1, max=3} },
    { item="Base.ShortBat_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.ScrapWeaponSpade", category="Weapon", tags={"Scavenger", "Farmer"}, basePrice=65, stockRange={min=0, max=2} },
    { item="Base.LargeBoneClub_Spiked", category="Weapon", tags={"Butcher"}, basePrice=40, stockRange={min=0, max=2} },
    { item="Base.TreeBranch_Railspike", category="Weapon", tags={"Survivalist"}, basePrice=20, stockRange={min=1, max=4} },

-- ==========================================================
-- MELEE WEAPONS: LONG BLUNTS
-- Balancing: Crowbars (Durability), Sledge (Rare utility), Bats (Reliability)
-- ==========================================================

    -- Heavy Duty Tools
    { item="Base.Sledgehammer", category="Weapon", tags={"Heavy", "Mechanic", "Rare"}, basePrice=500, stockRange={min=0, max=1} },
    { item="Base.Sledgehammer2", category="Weapon", tags={"Heavy", "Mechanic", "Rare"}, basePrice=500, stockRange={min=0, max=1} },
    { item="Base.SledgehammerForged", category="Weapon", tags={"Heavy", "Rare"}, basePrice=650, stockRange={min=0, max=1} },
    { item="Base.Crowbar", category="Weapon", tags={"Heavy", "Mechanic", "Scavenger"}, basePrice=150, stockRange={min=1, max=3} },
    { item="Base.CrowbarForged", category="Weapon", tags={"Heavy", "Rare"}, basePrice=200, stockRange={min=0, max=1} },

    -- Baseball Bats & Reinforced Variants
    { item="Base.BaseballBat", category="Weapon", tags={"General"}, basePrice=50, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_Crafted", category="Weapon", tags={"General"}, basePrice=40, stockRange={min=1, max=4} },
    { item="Base.BaseballBat_Metal", category="Weapon", tags={"Rare", "General"}, basePrice=120, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_Nails", category="Weapon", tags={"Survivalist"}, basePrice=60, stockRange={min=1, max=3} },
    { item="Base.BaseballBat_Spiked", category="Weapon", tags={"Survivalist"}, basePrice=70, stockRange={min=1, max=3} },
    { item="Base.BaseballBat_Can", category="Weapon", tags={"Scavenger"}, basePrice=85, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_ScrapSheet", category="Weapon", tags={"Scavenger"}, basePrice=100, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_GardenForkHead", category="Weapon", tags={"Farmer"}, basePrice=90, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_RakeHead", category="Weapon", tags={"Farmer"}, basePrice=85, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_Metal_Bolts", category="Weapon", tags={"Scavenger"}, basePrice=140, stockRange={min=0, max=1} },
    { item="Base.BaseballBat_Metal_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=160, stockRange={min=0, max=1} },

    -- Gardening/Agricultural Tools
    { item="Base.Shovel", category="Weapon", tags={"Heavy", "Farmer"}, basePrice=65, stockRange={min=1, max=4} },
    { item="Base.Shovel2", category="Weapon", tags={"Heavy", "Farmer"}, basePrice=65, stockRange={min=1, max=4} },
    { item="Base.SpadeForged", category="Weapon", tags={"Heavy", "Farmer", "Rare"}, basePrice=85, stockRange={min=0, max=2} },
    { item="Base.SnowShovel", category="Weapon", tags={"Heavy", "General"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.GardenHoe", category="Weapon", tags={"Heavy", "Farmer"}, basePrice=55, stockRange={min=1, max=3} },
    { item="Base.GardenHoeForged", category="Weapon", tags={"Heavy", "Farmer"}, basePrice=75, stockRange={min=0, max=2} },
    { item="Base.Rake", category="Weapon", tags={"Farmer"}, basePrice=30, stockRange={min=1, max=4} },
    { item="Base.LeafRake", category="Weapon", tags={"Farmer"}, basePrice=20, stockRange={min=1, max=4} },
    { item="Base.GardenForkHead", category="Weapon", tags={"Farmer", "Material"}, basePrice=40, stockRange={min=1, max=5} },
    { item="Base.SpadeHead", category="Weapon", tags={"Farmer", "Material"}, basePrice=40, stockRange={min=1, max=5} },

    -- Heavy / Combat Blunts
    { item="Base.BarBell", category="Weapon", tags={"Heavy", "Junk"}, basePrice=180, stockRange={min=0, max=2} },
    { item="Base.BarBell_Forged", category="Weapon", tags={"Heavy", "Rare"}, basePrice=250, stockRange={min=0, max=1} },
    { item="Base.BlockMaul", category="Weapon", tags={"Heavy", "Mechanic"}, basePrice=210, stockRange={min=0, max=2} },
    { item="Base.RailroadSpikePuller", category="Weapon", tags={"Heavy", "Mechanic"}, basePrice=190, stockRange={min=0, max=1} },
    { item="Base.LongMace", category="Weapon", tags={"Heavy", "Survivalist"}, basePrice=140, stockRange={min=0, max=2} },
    { item="Base.LongMace_Stone", category="Weapon", tags={"Heavy", "Survivalist"}, basePrice=60, stockRange={min=1, max=3} },

    -- Mauls & Scrap Mauls
    { item="Base.BucketMace_Metal", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=115, stockRange={min=0, max=2} },
    { item="Base.BucketMace_Wood", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=95, stockRange={min=0, max=2} },
    { item="Base.KettleMace_Metal", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=130, stockRange={min=0, max=2} },
    { item="Base.KettleMace_Wood", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=110, stockRange={min=0, max=2} },
    { item="Base.EngineMaul", category="Weapon", tags={"Heavy", "Mechanic"}, basePrice=175, stockRange={min=0, max=1} },
    { item="Base.ScrapMaul", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=150, stockRange={min=0, max=2} },
    { item="Base.StoneMaul", category="Weapon", tags={"Heavy", "Survivalist"}, basePrice=70, stockRange={min=1, max=3} },

    -- Cudgels & Reinforced Handles
    { item="Base.Cudgel_ScrapSheet", category="Weapon", tags={"Scavenger"}, basePrice=95, stockRange={min=0, max=2} },
    { item="Base.Cudgel_Bone", category="Weapon", tags={"Butcher"}, basePrice=80, stockRange={min=1, max=3} },
    { item="Base.Cudgel_GardenForkHead", category="Weapon", tags={"Farmer"}, basePrice=90, stockRange={min=1, max=3} },
    { item="Base.Cudgel_Nails", category="Weapon", tags={"Survivalist"}, basePrice=65, stockRange={min=1, max=4} },
    { item="Base.Cudgel_Railspike", category="Weapon", tags={"Scavenger"}, basePrice=85, stockRange={min=1, max=3} },
    { item="Base.Cudgel_Spike", category="Weapon", tags={"Survivalist"}, basePrice=75, stockRange={min=1, max=3} },
    { item="Base.LongHandle_Can", category="Weapon", tags={"Scavenger"}, basePrice=45, stockRange={min=1, max=5} },
    { item="Base.LongHandle_Brake", category="Weapon", tags={"Scavenger"}, basePrice=70, stockRange={min=0, max=3} },
    { item="Base.LongHandle_Nails", category="Weapon", tags={"Survivalist"}, basePrice=35, stockRange={min=1, max=5} },
    { item="Base.LongHandle_RakeHead", category="Weapon", tags={"Farmer"}, basePrice=55, stockRange={min=1, max=4} },

    -- Miscellaneous & Sports
    { item="Base.Golfclub", category="Weapon", tags={"General", "Junk"}, basePrice=35, stockRange={min=1, max=4} },
    { item="Base.Poolcue", category="Weapon", tags={"General", "Junk"}, basePrice=15, stockRange={min=1, max=5} },
    { item="Base.FieldHockeyStick", category="Weapon", tags={"General"}, basePrice=25, stockRange={min=1, max=4} },
    { item="Base.FieldHockeyStick_Nails", category="Weapon", tags={"Survivalist"}, basePrice=35, stockRange={min=1, max=3} },
    { item="Base.IceHockeyStick", category="Weapon", tags={"General"}, basePrice=25, stockRange={min=1, max=4} },
    { item="Base.IceHockeyStick_BarbedWire", category="Weapon", tags={"Survivalist"}, basePrice=45, stockRange={min=0, max=2} },
    { item="Base.LaCrosseStick", category="Weapon", tags={"General"}, basePrice=30, stockRange={min=1, max=3} },

    -- Musical Instruments (High durability-damage ratio penalty, high "flavor" price)
    { item="Base.GuitarAcoustic", category="Weapon", tags={"Junk"}, basePrice=80, stockRange={min=0, max=2} },
    { item="Base.GuitarElectric", category="Weapon", tags={"Junk"}, basePrice=120, stockRange={min=0, max=1} },
    { item="Base.GuitarElectricBass", category="Weapon", tags={"Junk"}, basePrice=130, stockRange={min=0, max=1} },
    { item="Base.Banjo", category="Weapon", tags={"Junk"}, basePrice=70, stockRange={min=0, max=2} },
    { item="Base.Saxophone", category="Weapon", tags={"Junk"}, basePrice=150, stockRange={min=0, max=1} },
    { item="Base.Trumpet", category="Weapon", tags={"Junk"}, basePrice=100, stockRange={min=0, max=1} },
    { item="Base.Keytar", category="Weapon", tags={"Junk"}, basePrice=200, stockRange={min=0, max=1} },

    -- Low-Tier / Improvised
    { item="Base.Plank", category="Weapon", tags={"Build", "Carpenter"}, basePrice=5, stockRange={min=5, max=20} },
    { item="Base.Plank_Nails", category="Weapon", tags={"Build", "Survivalist"}, basePrice=12, stockRange={min=2, max=10} },
    { item="Base.Plank_Saw", category="Weapon", tags={"Build", "Scavenger"}, basePrice=15, stockRange={min=1, max=5} },
    { item="Base.LongStick", category="Weapon", tags={"Survivalist"}, basePrice=8, stockRange={min=2, max=10} },
    { item="Base.LargeBranch", category="Weapon", tags={"Survivalist"}, basePrice=15, stockRange={min=2, max=8} },
    { item="Base.Broom", category="Weapon", tags={"General", "Clean"}, basePrice=10, stockRange={min=1, max=5} },
    { item="Base.Mop", category="Weapon", tags={"General", "Clean"}, basePrice=12, stockRange={min=1, max=5} },

       -- High-Tier Axes
    { item="Base.Axe", category="Weapon", tags={"Blade", "Heavy", "Survivalist"}, basePrice=150, stockRange={min=1, max=3} },
    { item="Base.Axe_Old", category="Weapon", tags={"Blade", "Heavy"}, basePrice=110, stockRange={min=1, max=2} },
    { item="Base.WoodAxe", category="Weapon", tags={"Blade", "Heavy", "Carpenter"}, basePrice=180, stockRange={min=0, max=2} },
    { item="Base.WoodAxeForged", category="Weapon", tags={"Blade", "Heavy", "Rare"}, basePrice=220, stockRange={min=0, max=1} },
    { item="Base.PickAxe", category="Weapon", tags={"Heavy", "Mechanic"}, basePrice=160, stockRange={min=0, max=2} },
    { item="Base.PickAxeForged", category="Weapon", tags={"Heavy", "Rare"}, basePrice=190, stockRange={min=0, max=1} },

    -- Mid-Tier / One-Handed
    { item="Base.HandAxe", category="Weapon", tags={"Blade", "Survivalist"}, basePrice=75, stockRange={min=1, max=4} },
    { item="Base.HandAxe_Old", category="Weapon", tags={"Blade"}, basePrice=55, stockRange={min=1, max=3} },
    { item="Base.HandAxeForged", category="Weapon", tags={"Blade", "Rare"}, basePrice=90, stockRange={min=0, max=2} },
    { item="Base.Hatchet", category="Weapon", tags={"Blade", "Survivalist"}, basePrice=70, stockRange={min=1, max=4} }, -- Alias for HandAxe usually
    { item="Base.IceAxe", category="Weapon", tags={"Blade", "Rare"}, basePrice=100, stockRange={min=0, max=1} },

    -- Cleavers & Specialized
    { item="Base.MeatCleaver", category="Weapon", tags={"Blade", "Butcher"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.MeatCleaverForged", category="Weapon", tags={"Blade", "Butcher"}, basePrice=60, stockRange={min=0, max=2} },
    { item="Base.HandScythe", category="Weapon", tags={"Blade", "Farmer"}, basePrice=50, stockRange={min=1, max=3} },
    { item="Base.HandScytheForged", category="Weapon", tags={"Blade", "Farmer"}, basePrice=65, stockRange={min=0, max=2} },

    -- Scrap / Improvised Axes
    { item="Base.AxeStone", category="Weapon", tags={"Blade", "Survivalist", "Junk"}, basePrice=15, stockRange={min=2, max=6} },
    { item="Base.StoneAxeLarge", category="Weapon", tags={"Blade", "Survivalist"}, basePrice=25, stockRange={min=1, max=4} },
    { item="Base.Axe_ScrapCleaver", category="Weapon", tags={"Blade", "Scavenger"}, basePrice=55, stockRange={min=1, max=3} },
    { item="Base.Axe_Sawblade", category="Weapon", tags={"Blade", "Scavenger"}, basePrice=85, stockRange={min=0, max=2} },
    { item="Base.Axe_Sawblade_Hatchet", category="Weapon", tags={"Blade", "Scavenger"}, basePrice=65, stockRange={min=1, max=3} },
    { item="Base.ScrapWeapon_Brake", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=80, stockRange={min=0, max=2} },
    { item="Base.Cudgel_Brake", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=95, stockRange={min=0, max=1} },
    { item="Base.Cudgel_Sawblade", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=90, stockRange={min=0, max=1} },
    { item="Base.Cudgel_SpadeHead", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=85, stockRange={min=0, max=1} },

    -- Primitive / Bone
    { item="Base.Hatchet_Bone", category="Weapon", tags={"Blade", "Butcher"}, basePrice=30, stockRange={min=1, max=3} },
    { item="Base.JawboneBovide_Axe", category="Weapon", tags={"Blade", "Butcher"}, basePrice=35, stockRange={min=1, max=3} },
    { item="Base.Saw_Flint", category="Weapon", tags={"Blade", "Survivalist"}, basePrice=20, stockRange={min=1, max=4} },
    { item="Base.PrimitiveScythe", category="Weapon", tags={"Blade", "Farmer"}, basePrice=25, stockRange={min=1, max=3} },

    -- Miscellaneous Crafting Axe-types
    { item="Base.TableLeg_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=40, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_RailSpike", category="Weapon", tags={"Survivalist"}, basePrice=65, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=75, stockRange={min=0, max=2} },
    { item="Base.FieldHockeyStick_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=45, stockRange={min=0, max=2} },
    { item="Base.EntrenchingTool", category="Weapon", tags={"Survivalist", "Military"}, basePrice=55, stockRange={min=1, max=3} },
    { item="Base.ScrapWeaponGardenFork", category="Weapon", tags={"Farmer", "Scavenger"}, basePrice=70, stockRange={min=0, max=2} },
    { item="Base.MetalPipe_Railspike", category="Weapon", tags={"Scavenger"}, basePrice=45, stockRange={min=0, max=2} },
    { item="Base.LongHandle_Railspike", category="Weapon", tags={"Scavenger"}, basePrice=35, stockRange={min=0, max=3} },
    { item="Base.LongHandle_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=40, stockRange={min=0, max=3} },
    { item="Base.Plank_Brake", category="Weapon", tags={"Scavenger"}, basePrice=50, stockRange={min=0, max=3} },
    { item="Base.Plank_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=45, stockRange={min=0, max=3} },
    { item="Base.MeatCleaver_Scrap", category="Weapon", tags={"Scavenger", "Butcher"}, basePrice=25, stockRange={min=1, max=4} },
    { item="Base.ShortBat_RailSpike", category="Weapon", tags={"Scavenger"}, basePrice=40, stockRange={min=1, max=3} },
    { item="Base.ShortBat_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.ScrapWeaponSpade", category="Weapon", tags={"Scavenger", "Farmer"}, basePrice=65, stockRange={min=0, max=2} },
    { item="Base.LargeBoneClub_Spiked", category="Weapon", tags={"Butcher"}, basePrice=40, stockRange={min=0, max=2} },
    { item="Base.TreeBranch_Railspike", category="Weapon", tags={"Survivalist"}, basePrice=20, stockRange={min=1, max=4} },

    -- Heavy Duty Tools
    { item="Base.Sledgehammer", category="Weapon", tags={"Heavy", "Mechanic", "Rare"}, basePrice=500, stockRange={min=0, max=1} },
    { item="Base.Sledgehammer2", category="Weapon", tags={"Heavy", "Mechanic", "Rare"}, basePrice=500, stockRange={min=0, max=1} },
    { item="Base.SledgehammerForged", category="Weapon", tags={"Heavy", "Rare"}, basePrice=650, stockRange={min=0, max=1} },
    { item="Base.Crowbar", category="Weapon", tags={"Heavy", "Mechanic", "Scavenger"}, basePrice=150, stockRange={min=1, max=3} },
    { item="Base.CrowbarForged", category="Weapon", tags={"Heavy", "Rare"}, basePrice=200, stockRange={min=0, max=1} },

    -- Baseball Bats & Reinforced Variants
    { item="Base.BaseballBat", category="Weapon", tags={"General"}, basePrice=50, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_Crafted", category="Weapon", tags={"General"}, basePrice=40, stockRange={min=1, max=4} },
    { item="Base.BaseballBat_Metal", category="Weapon", tags={"Rare", "General"}, basePrice=120, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_Nails", category="Weapon", tags={"Survivalist"}, basePrice=60, stockRange={min=1, max=3} },
    { item="Base.BaseballBat_Spiked", category="Weapon", tags={"Survivalist"}, basePrice=70, stockRange={min=1, max=3} },
    { item="Base.BaseballBat_Can", category="Weapon", tags={"Scavenger"}, basePrice=85, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_ScrapSheet", category="Weapon", tags={"Scavenger"}, basePrice=100, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_GardenForkHead", category="Weapon", tags={"Farmer"}, basePrice=90, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_RakeHead", category="Weapon", tags={"Farmer"}, basePrice=85, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_Metal_Bolts", category="Weapon", tags={"Scavenger"}, basePrice=140, stockRange={min=0, max=1} },
    { item="Base.BaseballBat_Metal_Sawblade", category="Weapon", tags={"Scavenger"}, basePrice=160, stockRange={min=0, max=1} },

    -- Gardening/Agricultural Tools
    { item="Base.Shovel", category="Weapon", tags={"Heavy", "Farmer"}, basePrice=65, stockRange={min=1, max=4} },
    { item="Base.Shovel2", category="Weapon", tags={"Heavy", "Farmer"}, basePrice=65, stockRange={min=1, max=4} },
    { item="Base.SpadeForged", category="Weapon", tags={"Heavy", "Farmer", "Rare"}, basePrice=85, stockRange={min=0, max=2} },
    { item="Base.SnowShovel", category="Weapon", tags={"Heavy", "General"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.GardenHoe", category="Weapon", tags={"Heavy", "Farmer"}, basePrice=55, stockRange={min=1, max=3} },
    { item="Base.GardenHoeForged", category="Weapon", tags={"Heavy", "Farmer"}, basePrice=75, stockRange={min=0, max=2} },
    { item="Base.Rake", category="Weapon", tags={"Farmer"}, basePrice=30, stockRange={min=1, max=4} },
    { item="Base.LeafRake", category="Weapon", tags={"Farmer"}, basePrice=20, stockRange={min=1, max=4} },
    { item="Base.GardenForkHead", category="Weapon", tags={"Farmer", "Material"}, basePrice=40, stockRange={min=1, max=5} },
    { item="Base.SpadeHead", category="Weapon", tags={"Farmer", "Material"}, basePrice=40, stockRange={min=1, max=5} },

    -- Heavy / Combat Blunts
    { item="Base.BarBell", category="Weapon", tags={"Heavy", "Junk"}, basePrice=180, stockRange={min=0, max=2} },
    { item="Base.BarBell_Forged", category="Weapon", tags={"Heavy", "Rare"}, basePrice=250, stockRange={min=0, max=1} },
    { item="Base.BlockMaul", category="Weapon", tags={"Heavy", "Mechanic"}, basePrice=210, stockRange={min=0, max=2} },
    { item="Base.RailroadSpikePuller", category="Weapon", tags={"Heavy", "Mechanic"}, basePrice=190, stockRange={min=0, max=1} },
    { item="Base.LongMace", category="Weapon", tags={"Heavy", "Survivalist"}, basePrice=140, stockRange={min=0, max=2} },
    { item="Base.LongMace_Stone", category="Weapon", tags={"Heavy", "Survivalist"}, basePrice=60, stockRange={min=1, max=3} },

    -- Mauls & Scrap Mauls
    { item="Base.BucketMace_Metal", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=115, stockRange={min=0, max=2} },
    { item="Base.BucketMace_Wood", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=95, stockRange={min=0, max=2} },
    { item="Base.KettleMace_Metal", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=130, stockRange={min=0, max=2} },
    { item="Base.KettleMace_Wood", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=110, stockRange={min=0, max=2} },
    { item="Base.EngineMaul", category="Weapon", tags={"Heavy", "Mechanic"}, basePrice=175, stockRange={min=0, max=1} },
    { item="Base.ScrapMaul", category="Weapon", tags={"Heavy", "Scavenger"}, basePrice=150, stockRange={min=0, max=2} },
    { item="Base.StoneMaul", category="Weapon", tags={"Heavy", "Survivalist"}, basePrice=70, stockRange={min=1, max=3} },

    -- Cudgels & Reinforced Handles
    { item="Base.Cudgel_ScrapSheet", category="Weapon", tags={"Scavenger"}, basePrice=95, stockRange={min=0, max=2} },
    { item="Base.Cudgel_Bone", category="Weapon", tags={"Butcher"}, basePrice=80, stockRange={min=1, max=3} },
    { item="Base.Cudgel_GardenForkHead", category="Weapon", tags={"Farmer"}, basePrice=90, stockRange={min=1, max=3} },
    { item="Base.Cudgel_Nails", category="Weapon", tags={"Survivalist"}, basePrice=65, stockRange={min=1, max=4} },
    { item="Base.Cudgel_Railspike", category="Weapon", tags={"Scavenger"}, basePrice=85, stockRange={min=1, max=3} },
    { item="Base.Cudgel_Spike", category="Weapon", tags={"Survivalist"}, basePrice=75, stockRange={min=1, max=3} },
    { item="Base.LongHandle_Can", category="Weapon", tags={"Scavenger"}, basePrice=45, stockRange={min=1, max=5} },
    { item="Base.LongHandle_Brake", category="Weapon", tags={"Scavenger"}, basePrice=70, stockRange={min=0, max=3} },
    { item="Base.LongHandle_Nails", category="Weapon", tags={"Survivalist"}, basePrice=35, stockRange={min=1, max=5} },
    { item="Base.LongHandle_RakeHead", category="Weapon", tags={"Farmer"}, basePrice=55, stockRange={min=1, max=4} },

    -- Miscellaneous & Sports
    { item="Base.Golfclub", category="Weapon", tags={"General", "Junk"}, basePrice=35, stockRange={min=1, max=4} },
    { item="Base.Poolcue", category="Weapon", tags={"General", "Junk"}, basePrice=15, stockRange={min=1, max=5} },
    { item="Base.FieldHockeyStick", category="Weapon", tags={"General"}, basePrice=25, stockRange={min=1, max=4} },
    { item="Base.FieldHockeyStick_Nails", category="Weapon", tags={"Survivalist"}, basePrice=35, stockRange={min=1, max=3} },
    { item="Base.IceHockeyStick", category="Weapon", tags={"General"}, basePrice=25, stockRange={min=1, max=4} },
    { item="Base.IceHockeyStick_BarbedWire", category="Weapon", tags={"Survivalist"}, basePrice=45, stockRange={min=0, max=2} },
    { item="Base.LaCrosseStick", category="Weapon", tags={"General"}, basePrice=30, stockRange={min=1, max=3} },

    -- Musical Instruments (High durability-damage ratio penalty, high "flavor" price)
    { item="Base.GuitarAcoustic", category="Weapon", tags={"Junk"}, basePrice=80, stockRange={min=0, max=2} },
    { item="Base.GuitarElectric", category="Weapon", tags={"Junk"}, basePrice=120, stockRange={min=0, max=1} },
    { item="Base.GuitarElectricBass", category="Weapon", tags={"Junk"}, basePrice=130, stockRange={min=0, max=1} },
    { item="Base.Banjo", category="Weapon", tags={"Junk"}, basePrice=70, stockRange={min=0, max=2} },
    { item="Base.Saxophone", category="Weapon", tags={"Junk"}, basePrice=150, stockRange={min=0, max=1} },
    { item="Base.Trumpet", category="Weapon", tags={"Junk"}, basePrice=100, stockRange={min=0, max=1} },
    { item="Base.Keytar", category="Weapon", tags={"Junk"}, basePrice=200, stockRange={min=0, max=1} },

    -- Low-Tier / Improvised
    { item="Base.Plank", category="Weapon", tags={"Build", "Carpenter"}, basePrice=5, stockRange={min=5, max=20} },
    { item="Base.Plank_Nails", category="Weapon", tags={"Build", "Survivalist"}, basePrice=12, stockRange={min=2, max=10} },
    { item="Base.Plank_Saw", category="Weapon", tags={"Build", "Scavenger"}, basePrice=15, stockRange={min=1, max=5} },
    { item="Base.LongStick", category="Weapon", tags={"Survivalist"}, basePrice=8, stockRange={min=2, max=10} },
    { item="Base.LargeBranch", category="Weapon", tags={"Survivalist"}, basePrice=15, stockRange={min=2, max=8} },
    { item="Base.Broom", category="Weapon", tags={"General", "Clean"}, basePrice=10, stockRange={min=1, max=5} },
    { item="Base.Mop", category="Weapon", tags={"General", "Clean"}, basePrice=12, stockRange={min=1, max=5} },
-- ==========================================================
-- MELEE WEAPONS: SPEARS
-- Balancing: High damage/range but extremely fragile.
-- ==========================================================

    -- Tools used as Spears
    { item="Base.GardenFork", category="Weapon", tags={"Spear", "Farmer", "Survivalist"}, basePrice=85, stockRange={min=1, max=3} },
    { item="Base.GardenFork_Forged", category="Weapon", tags={"Spear", "Rare"}, basePrice=110, stockRange={min=0, max=2} },

    -- High-Tier Spears (Attachment-based)
    { item="Base.SpearLong", category="Weapon", tags={"Spear", "Survivalist"}, basePrice=95, stockRange={min=0, max=2} },
    { item="Base.SpearHuntingKnife", category="Weapon", tags={"Spear", "Survivalist"}, basePrice=130, stockRange={min=0, max=1} },
    { item="Base.SpearFightingKnife", category="Weapon", tags={"Spear", "Military"}, basePrice=140, stockRange={min=0, max=1} },
    { item="Base.SpearLargeKnife", category="Weapon", tags={"Spear", "Survivalist"}, basePrice=120, stockRange={min=0, max=2} },

    -- Mid-Tier Spears
    { item="Base.SpearShort", category="Weapon", tags={"Spear", "Scavenger"}, basePrice=75, stockRange={min=1, max=3} },
    { item="Base.SpearStone", category="Weapon", tags={"Spear", "Survivalist"}, basePrice=40, stockRange={min=1, max=4} },
    { item="Base.SpearKnife", category="Weapon", tags={"Spear", "Scavenger"}, basePrice=60, stockRange={min=1, max=4} },
    { item="Base.SpearScrewdriver", category="Weapon", tags={"Spear", "Scavenger"}, basePrice=55, stockRange={min=1, max=3} },

    -- Low-Tier Spears
    { item="Base.SpearCrafted", category="Weapon", tags={"Spear", "Survivalist"}, basePrice=15, stockRange={min=2, max=6} },
    { item="Base.SpearCraftedFireHardened", category="Weapon", tags={"Spear", "Survivalist"}, basePrice=25, stockRange={min=1, max=5} },
    { item="Base.ClosedUmbrellaBlack", category="Weapon", tags={"Junk"}, basePrice=10, stockRange={min=1, max=3} },


-- ==========================================================
-- IMPROVISED & JUNK WEAPONS
-- Balancing: Minimum value items, mostly for Scavenger filler.
-- ==========================================================

    { item="Base.Stone2", category="Weapon", tags={"Junk", "Survivalist"}, basePrice=2, stockRange={min=5, max=15} },
    { item="Base.FlintNodule", category="Weapon", tags={"Junk", "Survivalist"}, basePrice=5, stockRange={min=2, max=8} },
    { item="Base.Pen", category="Weapon", tags={"Junk", "Literature"}, basePrice=1, stockRange={min=5, max=10} },
    { item="Base.Pencil", category="Weapon", tags={"Junk", "Literature"}, basePrice=1, stockRange={min=5, max=10} },
    { item="Base.CompassGeometry", category="Weapon", tags={"Junk"}, basePrice=8, stockRange={min=1, max=3} },

-- ==========================================================
-- FIREARMS
-- Balancing: Based on damage, rarity, and ammo type utility.
-- ==========================================================

    -- Handguns
    { item="Base.Pistol", category="Weapon", tags={"Gun", "Police"}, basePrice=300, stockRange={min=1, max=3} }, -- M9
    { item="Base.Pistol2", category="Weapon", tags={"Gun", "Police"}, basePrice=350, stockRange={min=1, max=2} }, -- M1911
    { item="Base.Pistol3", category="Weapon", tags={"Gun", "Rare", "Military"}, basePrice=650, stockRange={min=0, max=1} }, -- D-E
    { item="Base.Revolver_Short", category="Weapon", tags={"Gun", "General"}, basePrice=200, stockRange={min=1, max=3} }, -- M36
    { item="Base.Revolver", category="Weapon", tags={"Gun", "Police"}, basePrice=320, stockRange={min=1, max=2} }, -- M625
    { item="Base.Revolver_Long", category="Weapon", tags={"Gun", "Rare", "Hunting"}, basePrice=550, stockRange={min=0, max=1} }, -- Magnum

    -- Shotguns
    { item="Base.Shotgun", category="Weapon", tags={"Gun", "Police", "Hunting"}, basePrice=500, stockRange={min=1, max=2} }, -- JS2000
    { item="Base.DoubleBarrelShotgun", category="Weapon", tags={"Gun", "Hunting"}, basePrice=450, stockRange={min=1, max=2} },
    { item="Base.ShotgunSawnoff", category="Weapon", tags={"Gun", "Survivalist"}, basePrice=400, stockRange={min=0, max=1} },

    -- Rifles
    { item="Base.AssaultRifle", category="Weapon", tags={"Gun", "Military", "Rare"}, basePrice=1500, stockRange={min=0, max=1} }, -- M16
    { item="Base.AssaultRifle2", category="Weapon", tags={"Gun", "Military"}, basePrice=850, stockRange={min=0, max=1} }, -- M14
    { item="Base.HuntingRifle", category="Weapon", tags={"Gun", "Hunting"}, basePrice=700, stockRange={min=1, max=2} }, -- MSR788
    { item="Base.VarmintRifle", category="Weapon", tags={"Gun", "Hunting"}, basePrice=450, stockRange={min=1, max=3} }, -- MSR700

    -- Novelty
    { item="Base.Revolver_CapGun", category="Weapon", tags={"Junk"}, basePrice=20, stockRange={min=1, max=2} },


-- ==========================================================
-- AMMO PARTS & ATTACHMENTS
-- Balancing: High price as these do not degrade.
-- ==========================================================
    { item="Base.x8Scope", category="WeaponPart", tags={"Gun", "Rare", "Military"}, basePrice=400, stockRange={min=0, max=1} },
    { item="Base.x4Scope", category="WeaponPart", tags={"Gun", "Hunting"}, basePrice=250, stockRange={min=0, max=2} },
    { item="Base.x2Scope", category="WeaponPart", tags={"Gun", "General"}, basePrice=150, stockRange={min=1, max=3} },
    { item="Base.RedDot", category="WeaponPart", tags={"Gun", "Military"}, basePrice=220, stockRange={min=1, max=2} },
    { item="Base.Laser", category="WeaponPart", tags={"Gun", "Military"}, basePrice=350, stockRange={min=0, max=1} },
    { item="Base.GunLight", category="WeaponPart", tags={"Gun", "Police"}, basePrice=120, stockRange={min=1, max=4} },
    { item="Base.AmmoStraps", category="WeaponPart", tags={"Gun", "Gunrunner"}, basePrice=100, stockRange={min=1, max=3} },
    { item="Base.RecoilPad", category="WeaponPart", tags={"Gun", "Gunrunner"}, basePrice=90, stockRange={min=1, max=3} },
    { item="Base.ChokeTubeFull", category="WeaponPart", tags={"Gun", "Hunting"}, basePrice=130, stockRange={min=0, max=2} },

    -- ==========================================================
    -- ITEMS: EXPLOSIVES & TRAPS
    -- Balancing: Scaled by Damage and Tech level (Sensor/Remote).
    -- ==========================================================
    -- Throwables / Basic
    { item="Base.Molotov", category="Weapon", tags={"Survivalist", "Scavenger"}, basePrice=120, stockRange={min=1, max=4} },
    { item="Base.PipeBomb", category="Weapon", tags={"Military", "Gunrunner"}, basePrice=180, stockRange={min=1, max=3} },
    { item="Base.Aerosolbomb", category="Weapon", tags={"Scavenger"}, basePrice=110, stockRange={min=1, max=3} },
    { item="Base.FlameTrap", category="Weapon", tags={"Survivalist"}, basePrice=140, stockRange={min=1, max=3} },
    { item="Base.SmokeBomb", category="Weapon", tags={"Survivalist", "Military"}, basePrice=70, stockRange={min=1, max=5} },
    { item="Base.NoiseTrap", category="Weapon", tags={"Scavenger", "Electronics"}, basePrice=50, stockRange={min=2, max=6} },

    -- Advanced (Timer / Remote / Sensor)
    { item="Base.PipeBombRemote", category="Weapon", tags={"Military", "Rare"}, basePrice=300, stockRange={min=0, max=1} },
    { item="Base.AerosolbombSensorV3", category="Weapon", tags={"Scavenger", "Rare"}, basePrice=250, stockRange={min=0, max=1} },
    { item="Base.NoiseTrapSensorV3", category="Weapon", tags={"Scavenger"}, basePrice=150, stockRange={min=0, max=2} },

    -- Distractions
    { item="Base.Firecracker", category="Weapon", tags={"Junk", "General"}, basePrice=20, stockRange={min=2, max=10} },
})