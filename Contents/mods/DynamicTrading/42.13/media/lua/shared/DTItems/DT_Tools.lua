require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({

    -- =============================================================================
    -- 1. BLACKSMITHING & METALWORKING (High Value)
    -- =============================================================================
    
    -- HAMMERS
    { item="Base.BallPeenHammer",       tags={"Tool", "Mechanic", "Common"},   basePrice=35, stockRange={min=1, max=4} },
    { item="Base.BallPeenHammerForged", tags={"Tool", "Mechanic", "Common"},   basePrice=50, stockRange={min=0, max=2} },
    { item="Base.SmithingHammer",       tags={"Tool", "Smithing", "Uncommon"}, basePrice=65, stockRange={min=1, max=3} },
    { item="Base.ClubHammer",           tags={"Tool", "Builder", "Common"},    basePrice=50, stockRange={min=1, max=3} },
    { item="Base.ClubHammerForged",     tags={"Tool", "Smithing", "Uncommon"}, basePrice=70, stockRange={min=0, max=2} },

    -- METALWORKING BASICS
    { item="Base.Tongs",                tags={"Tool", "Smithing", "Uncommon"}, basePrice=45, stockRange={min=1, max=4} },
    { item="Base.CrudeWoodenTongs",     tags={"Tool", "Smithing", "Survivalist"}, basePrice=15, stockRange={min=2, max=6} },
    { item="Base.BlowTorch",            tags={"Tool", "Mechanic", "Rare"},     basePrice=150,stockRange={min=1, max=3} },
    { item="Base.WeldingMask",          tags={"Tool", "Mechanic", "Uncommon"}, basePrice=80, stockRange={min=1, max=2} },
    { item="Base.BoltCutters",          tags={"Tool", "Thief", "Rare"},        basePrice=140,stockRange={min=0, max=2} }, -- High utility
    
    -- PRECISION METAL TOOLS
    { item="Base.MetalworkingPliers",   tags={"Tool", "Smithing", "Uncommon"}, basePrice=40, stockRange={min=1, max=4} },
    { item="Base.MetalworkingPunch",    tags={"Tool", "Smithing", "Uncommon"}, basePrice=35, stockRange={min=1, max=4} },
    { item="Base.MetalworkingChisel",   tags={"Tool", "Smithing", "Uncommon"}, basePrice=35, stockRange={min=1, max=4} },
    { item="Base.SheetMetalSnips",      tags={"Tool", "Mechanic", "Uncommon"}, basePrice=45, stockRange={min=1, max=4} },
    { item="Base.HeadingTool",          tags={"Tool", "Smithing", "Uncommon"}, basePrice=55, stockRange={min=0, max=2} },
    { item="Base.ViseGrips",            tags={"Tool", "Mechanic", "Common"},   basePrice=45, stockRange={min=1, max=3} },
    { item="Base.SmallPunchSet",        tags={"Tool", "Smithing", "Rare"},     basePrice=90, stockRange={min=0, max=2} },

    -- =============================================================================
    -- 2. CARPENTRY & MASONRY
    -- =============================================================================

    -- SAWS
    { item="Base.Saw",                  tags={"Tool", "Carpenter", "Common"},      basePrice=60, stockRange={min=1, max=4} },
    { item="Base.GardenSaw",            tags={"Tool", "Farmer", "Common"},         basePrice=55, stockRange={min=1, max=4} },
    { item="Base.SmallSaw",             tags={"Tool", "Carpenter", "Uncommon"},    basePrice=40, stockRange={min=1, max=5} },
    { item="Base.Saw_Flint",            tags={"Tool", "Survivalist", "Common"},    basePrice=15, stockRange={min=2, max=6} },
    { item="Base.CrudeSaw",             tags={"Tool", "Survivalist", "Common"},    basePrice=25, stockRange={min=1, max=4} },

    -- DRILLS
    { item="Base.HandDrill",            tags={"Tool", "Carpenter", "Common"},      basePrice=85, stockRange={min=1, max=3} },
    { item="Base.OldDrill",             tags={"Tool", "Scavenger", "Uncommon"},    basePrice=65, stockRange={min=1, max=3} },
    { item="Base.StoneDrill",           tags={"Tool", "Survivalist", "Common"},    basePrice=20, stockRange={min=1, max=4} },

    -- MASONRY & DEMOLITION
    { item="Base.MasonsChisel",         tags={"Tool", "Builder", "Common"},        basePrice=35, stockRange={min=1, max=4} },
    { item="Base.StoneChisel",          tags={"Tool", "Survivalist", "Common"},    basePrice=15, stockRange={min=2, max=6} },
    { item="Base.MasonsTrowel",         tags={"Tool", "Builder", "Common"},        basePrice=30, stockRange={min=1, max=5} },
    { item="Base.MasonsTrowel_Wood",    tags={"Tool", "Survivalist", "Common"},    basePrice=10, stockRange={min=1, max=4} },
    { item="Base.PlasterTrowel",        tags={"Tool", "Builder", "Common"},        basePrice=35, stockRange={min=1, max=3} },
    { item="Base.PickAxe",              tags={"Tool", "Heavy", "Builder", "Rare"}, basePrice=140, stockRange={min=1, max=3} },
    
    -- THE LEGENDARY SLEDGE
    { item="Base.Sledgehammer",         tags={"Tool", "Heavy", "Legendary"},       basePrice=400, stockRange={min=0, max=1} }, -- Real: 2000

    -- =============================================================================
    -- 3. TAILORING & PRECISION
    -- =============================================================================

    -- SEWING
    { item="Base.Needle",               tags={"Tool", "Tailor", "Common"},         basePrice=15, stockRange={min=5, max=15} },
    { item="Base.Needle_Forged",        tags={"Tool", "Tailor", "Uncommon"},       basePrice=20, stockRange={min=2, max=8} },
    { item="Base.Needle_Brass",         tags={"Tool", "Tailor", "Uncommon"},       basePrice=25, stockRange={min=1, max=5} },
    { item="Base.Needle_Bone",          tags={"Tool", "Survivalist", "Common"},    basePrice=10, stockRange={min=3, max=10} },
    { item="Base.Awl",                  tags={"Tool", "Tailor", "Common"},         basePrice=25, stockRange={min=2, max=6} },
    { item="Base.Awl_Stone",            tags={"Tool", "Survivalist", "Common"},    basePrice=10, stockRange={min=2, max=8} },
    { item="Base.KnittingNeedles",      tags={"Tool", "Tailor", "Common"},         basePrice=20, stockRange={min=1, max=4} },
    { item="Base.Thimble",              tags={"Tool", "Tailor", "Common"},         basePrice=5,  stockRange={min=2, max=8} },

    -- MEASUREMENT (High Value for Crafters)
    { item="Base.Calipers",             tags={"Tool", "Mechanic", "Rare"},         basePrice=100, stockRange={min=0, max=2} },
    { item="Base.Loupe",                tags={"Tool", "Scavenger", "Rare"},        basePrice=85,  stockRange={min=0, max=2} },
    { item="Base.MeasuringTape",        tags={"Tool", "Builder", "Common"},        basePrice=15,  stockRange={min=2, max=6} },
    { item="Base.CompassGeometry",      tags={"Tool", "Scavenger", "Common"},      basePrice=30,  stockRange={min=1, max=3} },

    -- =============================================================================
    -- 4. SURVIVAL & MEDICAL TOOLS
    -- =============================================================================

    -- MULTI-USE
    { item="Base.Multitool",            tags={"Tool", "Survival", "Rare"},         basePrice=200, stockRange={min=0, max=2} },
    { item="Base.Handiknife",           tags={"Tool", "Survival", "Common"},       basePrice=45,  stockRange={min=1, max=4} },
    { item="Base.Whetstone",            tags={"Tool", "Blade", "Common"},          basePrice=60,  stockRange={min=1, max=3} },
    { item="Base.CrudeWhetstone",       tags={"Tool", "Survivalist", "Common"},    basePrice=20,  stockRange={min=2, max=6} },

    -- PHARMACY
    { item="Base.Tweezers",             tags={"Tool", "Medical", "Common"},        basePrice=20,  stockRange={min=2, max=6} },
    { item="Base.SutureNeedleHolder",   tags={"Tool", "Medical", "Rare"},          basePrice=75,  stockRange={min=0, max=2} },
    { item="Base.MortarPestle",         tags={"Tool", "Medical", "Common"},        basePrice=40,  stockRange={min=1, max=3} },
    { item="Base.CeramicMortarandPestle",tags={"Tool", "Medical", "Uncommon"},     basePrice=50,  stockRange={min=1, max=3} },

    -- BUTCHERY & FARMING
    { item="Base.Fleshing_Tool",        tags={"Tool", "Butcher", "Common"},        basePrice=35,  stockRange={min=1, max=4} },
    { item="Base.Fleshing_Tool_Bone",   tags={"Tool", "Survivalist", "Common"},    basePrice=15,  stockRange={min=2, max=6} },
    { item="Base.OilPress",             tags={"Tool", "Farmer", "Uncommon"},       basePrice=120, stockRange={min=0, max=2} },
    { item="Base.SheepShears",          tags={"Tool", "Farmer", "Common"},         basePrice=45,  stockRange={min=1, max=4} },

    -- =============================================================================
    -- 5. HEAVY INFRASTRUCTURE (ANVILS)
    -- =============================================================================
    -- Logic: Anvils are rare and extremely heavy. Their price reflects their
    -- status as the "Workbench" for B42 metalworking.

    { item="Base.BlacksmithAnvil",          tags={"Tool", "Smithing", "Heavy", "Rare"}, basePrice=800, stockRange={min=0, max=1} },
    { item="Base.BlacksmithAnvilAssembled", tags={"Tool", "Smithing", "Heavy", "Rare"}, basePrice=950, stockRange={min=0, max=1} },
    { item="Base.BenchAnvil",               tags={"Tool", "Smithing", "Heavy", "Uncommon"}, basePrice=450, stockRange={min=0, max=1} },
    { item="Base.BlockAnvil",               tags={"Tool", "Smithing", "Heavy", "Uncommon"}, basePrice=600, stockRange={min=0, max=1} },
    { item="Base.StoneAnvil",               tags={"Tool", "Survivalist", "Heavy", "Common"},basePrice=150, stockRange={min=0, max=1} },

    -- VISES & BELLOWS
    { item="Base.CrudeBenchVise",           tags={"Tool", "Smithing", "Common"},       basePrice=180, stockRange={min=0, max=2} },
    { item="Base.Bellows",                  tags={"Tool", "Smithing", "Uncommon"},     basePrice=120, stockRange={min=1, max=3} },
    { item="Base.LargeBellows",             tags={"Tool", "Smithing", "Heavy", "Rare"},basePrice=300, stockRange={min=0, max=1} },

    -- INDUSTRIAL
    { item="Base.HeavyChain",               tags={"Tool", "Mechanic", "Heavy", "Uncommon"}, basePrice=90,  stockRange={min=1, max=3} },
    { item="Base.HeavyChain_Hook",          tags={"Tool", "Mechanic", "Heavy", "Uncommon"}, basePrice=130, stockRange={min=1, max=2} },
    { item="Base.RailroadSpikePuller",      tags={"Tool", "Mechanic", "Heavy", "Uncommon"}, basePrice=160, stockRange={min=0, max=1} },

    -- =============================================================================
    -- 6. MISCELLANEOUS TOOLS
    -- =============================================================================

    { item="Base.Paintbrush",           tags={"Tool", "Painter", "Common"},        basePrice=25,  stockRange={min=2, max=6} },
    { item="Base.PaintbrushCrafted",    tags={"Tool", "Survivalist", "Common"},    basePrice=10,  stockRange={min=2, max=8} },
    { item="Base.Bullhorn",             tags={"Tool", "Police", "Uncommon"},       basePrice=120, stockRange={min=0, max=2} },
    { item="Base.Zipties",              tags={"Tool", "Thief", "Common"},          basePrice=15,  stockRange={min=5, max=20} },
    { item="Base.RubberHose",           tags={"Tool", "Mechanic", "Common"},       basePrice=20,  stockRange={min=2, max=8} },
    { item="Base.SteelWool",            tags={"Tool", "Clean", "Common"},          basePrice=12,  stockRange={min=5, max=15} },
    { item="Base.Funnel",               tags={"Tool", "Mechanic", "Common"},       basePrice=15,  stockRange={min=2, max=6} },
})