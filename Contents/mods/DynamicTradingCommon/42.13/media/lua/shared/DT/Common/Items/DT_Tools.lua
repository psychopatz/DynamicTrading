require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({

    -- =============================================================================
    -- 1. BLACKSMITHING & METALWORKING (High Value)
    -- =============================================================================
    
    -- HAMMERS
    { item="Base.BallPeenHammer",       tags={"Tool.Crafting.Metal", "Rarity.Common"},   basePrice=70, stockRange={min=1, max=4} }, -- Worth: 35.0
    { item="Base.BallPeenHammerForged", tags={"Tool.Crafting.Metal", "Rarity.Uncommon"}, basePrice=100, stockRange={min=0, max=2} }, -- Worth: 50.0
    { item="Base.SmithingHammer",       tags={"Tool.Crafting.Metal", "Rarity.Uncommon"}, basePrice=130, stockRange={min=1, max=3} }, -- Worth: 65.0
    { item="Base.ClubHammer",           tags={"Tool.Crafting.Metal", "Rarity.Common"},    basePrice=100, stockRange={min=1, max=3} },
    { item="Base.ClubHammerForged",     tags={"Tool.Crafting.Metal", "Rarity.Uncommon"}, basePrice=140, stockRange={min=0, max=2} },

    -- METALWORKING BASICS
    { item="Base.Tongs",                tags={"Tool.Crafting.Metal", "Rarity.Uncommon"}, basePrice=90, stockRange={min=1, max=4} },
    { item="Base.CrudeWoodenTongs",     tags={"Tool.Crafting.Metal", "Theme.Survival"}, basePrice=30, stockRange={min=2, max=6} },
    { item="Base.BlowTorch",            tags={"Tool.Crafting.Metal", "Rarity.Rare"},     basePrice=300,stockRange={min=1, max=3} },
    { item="Base.WeldingMask",          tags={"Tool.Crafting.Metal", "Rarity.Uncommon"}, basePrice=160, stockRange={min=1, max=2} },
    { item="Base.BoltCutters",          tags={"Tool.Crafting.Metal", "Rarity.Rare"},        basePrice=280,stockRange={min=0, max=2} }, -- High utility
    
    -- PRECISION METAL TOOLS
    { item="Base.MetalworkingPliers",   tags={"Tool.Crafting.Metal", "Rarity.Uncommon"}, basePrice=80, stockRange={min=1, max=4} },
    { item="Base.MetalworkingPunch",    tags={"Tool.Crafting.Metal", "Rarity.Uncommon"}, basePrice=70, stockRange={min=1, max=4} },
    { item="Base.MetalworkingChisel",   tags={"Tool.Crafting.Metal", "Rarity.Uncommon"}, basePrice=70, stockRange={min=1, max=4} },
    { item="Base.SheetMetalSnips",      tags={"Tool.Crafting.Metal", "Rarity.Uncommon"}, basePrice=90, stockRange={min=1, max=4} },
    { item="Base.HeadingTool",          tags={"Tool.Crafting.Metal", "Rarity.Uncommon"}, basePrice=110, stockRange={min=0, max=2} },
    { item="Base.ViseGrips",            tags={"Tool.Crafting.Metal", "Rarity.Common"},   basePrice=90, stockRange={min=1, max=3} },
    { item="Base.SmallPunchSet",        tags={"Tool.Crafting.Metal", "Rarity.Rare"},     basePrice=180, stockRange={min=0, max=2} },

    -- =============================================================================
    -- 2. CARPENTRY & MASONRY
    -- =============================================================================

    -- SAWS
    { item="Base.Saw",                  tags={"Tool.Crafting.Carpenter", "Rarity.Common"},      basePrice=120, stockRange={min=1, max=4} },
    { item="Base.GardenSaw",            tags={"Tool.Crafting.Farmer", "Rarity.Common"},         basePrice=110, stockRange={min=1, max=4} },
    { item="Base.SmallSaw",             tags={"Tool.Crafting.Carpenter", "Rarity.Uncommon"},    basePrice=80, stockRange={min=1, max=5} },
    { item="Base.Saw_Flint",            tags={"Tool.Crafting.Survival", "Rarity.Common"},    basePrice=30, stockRange={min=2, max=6} },
    { item="Base.CrudeSaw",             tags={"Tool.Crafting.Survival", "Rarity.Common"},    basePrice=50, stockRange={min=1, max=4} },
    
    -- DRILLS
    { item="Base.HandDrill",            tags={"Tool.Crafting.Carpenter", "Rarity.Common"},      basePrice=170, stockRange={min=1, max=3} },
    { item="Base.OldDrill",             tags={"Tool.Crafting.Carpenter", "Rarity.Uncommon"},    basePrice=130, stockRange={min=1, max=3} },
    { item="Base.StoneDrill",           tags={"Tool.Crafting.Survival", "Rarity.Common"},    basePrice=40, stockRange={min=1, max=4} },

    -- MASONRY & DEMOLITION
    { item="Base.MasonsChisel",         tags={"Tool.Crafting.Mason", "Rarity.Common"},        basePrice=70, stockRange={min=1, max=4} },
    { item="Base.StoneChisel",          tags={"Tool.Crafting.Survival", "Rarity.Common"},    basePrice=30, stockRange={min=2, max=6} },
    { item="Base.MasonsTrowel",         tags={"Tool.Crafting.Mason", "Rarity.Common"},        basePrice=60, stockRange={min=1, max=5} },
    { item="Base.MasonsTrowel_Wood",    tags={"Tool.Crafting.Survival", "Rarity.Common"},    basePrice=20, stockRange={min=1, max=4} },
    { item="Base.PlasterTrowel",        tags={"Tool.Crafting.Mason", "Rarity.Common"},        basePrice=70, stockRange={min=1, max=3} },
    { item="Base.PickAxe",              tags={"Tool.Heavy", "Rarity.Uncommon"}, basePrice=300, stockRange={min=1, max=3} },
    
    -- THE LEGENDARY SLEDGE
    { item="Base.Sledgehammer",         tags={"Tool.Demolition", "Rarity.Rare"},       basePrice=800, stockRange={min=0, max=1} }, -- Real: 2000

    -- =============================================================================
    -- 3. TAILORING & PRECISION
    -- =============================================================================

    -- SEWING
    { item="Base.Needle",               tags={"Tool.Crafting.Tailor", "Rarity.Common"},      basePrice=15, stockRange={min=5, max=15} },
    { item="Base.Needle_Forged",        tags={"Tool.Crafting.Tailor", "Rarity.Uncommon"},    basePrice=25, stockRange={min=2, max=8} },
    { item="Base.Needle_Brass",         tags={"Tool.Crafting.Tailor", "Rarity.Uncommon"},    basePrice=35, stockRange={min=1, max=5} },
    { item="Base.Needle_Bone",          tags={"Tool.Crafting.Survival", "Rarity.Common"},    basePrice=10, stockRange={min=3, max=10} },
    { item="Base.Awl",                  tags={"Tool.Crafting.Tailor", "Rarity.Common"},      basePrice=25, stockRange={min=2, max=6} },
    { item="Base.Awl_Stone",            tags={"Tool.Crafting.Survival", "Rarity.Common"},    basePrice=10, stockRange={min=2, max=8} },
    { item="Base.KnittingNeedles",      tags={"Tool.Crafting.Tailor", "Rarity.Common"},      basePrice=20, stockRange={min=1, max=4} },
    { item="Base.Thimble",              tags={"Tool.Crafting.Tailor", "Rarity.Common"},      basePrice=5,  stockRange={min=2, max=8} },

    -- MEASUREMENT (High Value for Crafters)
    { item="Base.Calipers",             tags={"Tool.Crafting.Mechanic", "Rarity.Rare"},      basePrice=150, stockRange={min=0, max=2} },
    { item="Base.Loupe",                tags={"Tool.Crafting.Scavenger", "Rarity.Rare"},     basePrice=125,  stockRange={min=0, max=2} },
    { item="Base.MeasuringTape",        tags={"Tool.Crafting.Builder", "Rarity.Common"},     basePrice=25,  stockRange={min=2, max=6} },
    { item="Base.CompassGeometry",      tags={"Tool.Crafting.Scavenger", "Rarity.Common"},   basePrice=45,  stockRange={min=1, max=3} },

    -- =============================================================================
    -- 4. SURVIVAL & MEDICAL TOOLS
    -- =============================================================================

    -- MULTI-USE
    { item="Base.Multitool",            tags={"Tool.Crafting", "Theme.Survival", "Rarity.Rare"},  basePrice=400, stockRange={min=0, max=2} },
    { item="Base.Handiknife",           tags={"Tool.Crafting", "Theme.Survival", "Rarity.Common"}, basePrice=90,  stockRange={min=1, max=4} },
    { item="Base.Whetstone",            tags={"Tool.Crafting", "Rarity.Common"},          basePrice=120, stockRange={min=1, max=3} },
    { item="Base.CrudeWhetstone",       tags={"Tool.Crafting.Survival", "Rarity.Common"},    basePrice=40,  stockRange={min=2, max=6} },

    -- PHARMACY
    { item="Base.Tweezers",             tags={"Medical.Surgical.Tool", "Rarity.Common"},     basePrice=25,  stockRange={min=2, max=6} },
    { item="Base.SutureNeedleHolder",   tags={"Medical.Tool.Surgical", "Origin.Healthcare", "Rarity.Rare"}, basePrice=125,  stockRange={min=0, max=2} },
    { item="Base.MortarPestle",         tags={"Medical.Herb.Tool", "Theme.Survival", "Rarity.Common"}, basePrice=55,  stockRange={min=1, max=3} },
    { item="Base.CeramicMortarandPestle",tags={"Medical.Herb.Tool", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=75,  stockRange={min=1, max=3} },

    -- BUTCHERY & FARMING
    { item="Base.Fleshing_Tool",        tags={"Tool.Resource.Butcher", "Rarity.Common"},     basePrice=45,  stockRange={min=1, max=4} },
    { item="Base.Fleshing_Tool_Bone",   tags={"Tool.Resource.Survival", "Theme.Survival", "Rarity.Common"}, basePrice=15,  stockRange={min=2, max=6} },
    { item="Base.OilPress",             tags={"Tool.Resource.Farmer", "Rarity.Uncommon"},    basePrice=180, stockRange={min=0, max=2} },
    { item="Base.SheepShears",          tags={"Tool.Resource.Farmer", "Rarity.Common"},      basePrice=55,  stockRange={min=1, max=4} },

    -- =============================================================================
    -- 5. HEAVY INFRASTRUCTURE (ANVILS)
    -- =============================================================================
    -- Logic: Anvils are rare and extremely heavy. Their price reflects their
    -- status as the "Workbench" for B42 metalworking.

    { item="Base.BlacksmithAnvil",          tags={"Tool.Crafting.Metal", "Quality.Heavy", "Rarity.Rare"}, basePrice=1200, stockRange={min=0, max=1} },
    { item="Base.BlacksmithAnvilAssembled", tags={"Tool.Crafting.Metal", "Quality.Heavy", "Rarity.Rare"}, basePrice=1400, stockRange={min=0, max=1} },
    { item="Base.BenchAnvil",               tags={"Tool.Crafting.Metal", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=650, stockRange={min=0, max=1} },
    { item="Base.BlockAnvil",               tags={"Tool.Crafting.Metal", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=850, stockRange={min=0, max=1} },
    { item="Base.StoneAnvil",               tags={"Tool.Crafting.Survival", "Quality.Heavy", "Rarity.Common"}, basePrice=250, stockRange={min=0, max=1} },

    -- VISES & BELLOWS
    { item="Base.CrudeBenchVise",           tags={"Tool.Crafting.Metal", "Rarity.Common"},      basePrice=250, stockRange={min=0, max=2} },
    { item="Base.Bellows",                  tags={"Tool.Crafting.Metal", "Rarity.Uncommon"},    basePrice=180, stockRange={min=1, max=3} },
    { item="Base.LargeBellows",             tags={"Tool.Crafting.Metal", "Quality.Heavy", "Rarity.Rare"}, basePrice=450, stockRange={min=0, max=1} },

    -- INDUSTRIAL
    { item="Base.HeavyChain",               tags={"Tool.General.Heavy", "Origin.Industrial", "Rarity.Uncommon"}, basePrice=140, stockRange={min=1, max=3} },
    { item="Base.HeavyChain_Hook",          tags={"Tool.General.Heavy", "Origin.Industrial", "Rarity.Uncommon"}, basePrice=180, stockRange={min=1, max=2} },
    { item="Base.RailroadSpikePuller",      tags={"Tool.General.Heavy", "Origin.Industrial", "Rarity.Uncommon"}, basePrice=240, stockRange={min=0, max=1} },

    -- =============================================================================
    -- 6. MISCELLANEOUS TOOLS
    -- =============================================================================

    { item="Base.Paintbrush",           tags={"Tool.Crafting.Art", "Rarity.Common"},         basePrice=35,  stockRange={min=2, max=6} },
    { item="Base.PaintbrushCrafted",    tags={"Tool.Crafting.Survival", "Rarity.Common"},    basePrice=15,  stockRange={min=2, max=8} },
    { item="Base.Bullhorn",             tags={"Tool.General.Noise", "Origin.Police", "Rarity.Uncommon"}, basePrice=160, stockRange={min=0, max=2} },
    { item="Base.Zipties",              tags={"Tool.General.Restraint", "Rarity.Common"},    basePrice=25,  stockRange={min=5, max=20} },
    { item="Base.RubberHose",           tags={"Tool.General.Liquid", "Rarity.Common"},       basePrice=35,  stockRange={min=2, max=8} },
    { item="Base.SteelWool",            tags={"Tool.General.Clean", "Rarity.Common"},        basePrice=15,  stockRange={min=5, max=15} },
    { item="Base.Funnel",               tags={"Tool.General.Liquid", "Rarity.Common"},       basePrice=25,  stockRange={min=2, max=6} },
})

print("[DynamicTrading] Tools Registry Complete \n.")
