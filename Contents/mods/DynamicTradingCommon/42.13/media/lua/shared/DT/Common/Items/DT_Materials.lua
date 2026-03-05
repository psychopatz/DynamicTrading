require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({

    -- =============================================================================
    -- 1. METALS (Smithing & Crafting)
    -- =============================================================================
    
    -- ALUMINUM & BRASS
    -- ALUMINUM & BRASS
    { item="Base.Aluminum",          tags={"Resource.Material.Metal", "Rarity.Common"}, basePrice=30, stockRange={min=5, max=15} }, -- Worth: 15.0
    { item="Base.AluminumScrap",     tags={"Resource.Material.Metal", "Quality.Waste"},  basePrice=10, stockRange={min=5, max=15} }, -- Worth: 5.0
    { item="Base.BrassIngot",        tags={"Resource.Material.Metal", "Rarity.Uncommon"}, basePrice=160, stockRange={min=1, max=4} }, -- Worth: 80.0
    { item="Base.BrassScrap",        tags={"Resource.Material.Metal", "Quality.Waste"},  basePrice=20, stockRange={min=5, max=20} },
    
    -- COPPER (Electronics & Plumbing)
    { item="Base.CopperIngot",       tags={"Resource.Material.Metal", "Rarity.Uncommon"}, basePrice=120, stockRange={min=2, max=6} }, -- Worth: 60.0
    { item="Base.CopperOre",         tags={"Resource.Material.Raw", "Rarity.Common"},    basePrice=60, stockRange={min=1, max=4} },
    { item="Base.CopperScrap",       tags={"Resource.Material.Metal", "Quality.Waste"},  basePrice=16, stockRange={min=5, max=20} },
    { item="Base.CopperSheet",       tags={"Resource.Material.Metal", "Rarity.Common"},  basePrice=90, stockRange={min=2, max=8} },
    
    -- IRON (Basic Construction)
    { item="Base.IronIngot",         tags={"Resource.Material.Metal", "Rarity.Common"},  basePrice=140, stockRange={min=2, max=8} },
    { item="Base.IronBar",           tags={"Resource.Material.Metal", "Rarity.Common"},  basePrice=90, stockRange={min=2, max=10} },
    { item="Base.IronOre",           tags={"Resource.Material.Raw", "Rarity.Common"},    basePrice=70, stockRange={min=1, max=4} },
    { item="Base.IronScrap",         tags={"Resource.Material.Metal", "Quality.Waste"},  basePrice=24, stockRange={min=10, max=30} },
    { item="Base.IronBlock",         tags={"Resource.Material.Metal", "Rarity.Uncommon"},basePrice=200,stockRange={min=1, max=4} },
    
    -- STEEL (High Tier)
    { item="Base.SteelIngot",        tags={"Resource.Material.Metal", "Rarity.Rare"},    basePrice=240, stockRange={min=1, max=4} },
    { item="Base.SteelBar",          tags={"Resource.Material.Metal", "Rarity.Rare"},    basePrice=180, stockRange={min=2, max=6} },
    { item="Base.SteelScrap",        tags={"Resource.Material.Metal", "Rarity.Common"},  basePrice=60,  stockRange={min=5, max=15} },
    { item="Base.SteelBlock",        tags={"Resource.Material.Metal", "Rarity.Rare"},    basePrice=320, stockRange={min=1, max=4} },
    { item="Base.SteelSlug",         tags={"Resource.Material.Metal", "Rarity.Common"},  basePrice=20,  stockRange={min=10, max=50} },

    -- PRECIOUS METALS (Currency / Luxury)
    { item="Base.GoldBar",           tags={"Resource.Material.Precious", "Quality.Luxury", "Rarity.Legendary"}, basePrice=5000, stockRange={min=0, max=1} },
    { item="Base.SmallGoldBar",      tags={"Resource.Material.Precious", "Quality.Luxury", "Rarity.Rare"},      basePrice=1500, stockRange={min=0, max=2} },
    { item="Base.GoldScrap",         tags={"Resource.Material.Precious", "Quality.Luxury", "Rarity.Uncommon"},  basePrice=400,  stockRange={min=1, max=5} },
    { item="Base.SilverBar",         tags={"Resource.Material.Precious", "Quality.Luxury", "Rarity.Rare"},      basePrice=2500, stockRange={min=0, max=2} },
    { item="Base.SmallSilverBar",    tags={"Resource.Material.Precious", "Quality.Luxury", "Rarity.Uncommon"},  basePrice=800,  stockRange={min=1, max=4} },
    { item="Base.SilverScrap",       tags={"Resource.Material.Precious", "Quality.Luxury", "Rarity.Common"},    basePrice=200,  stockRange={min=2, max=10} },

    -- =============================================================================
    -- 2. CLAY, STONE & GLASS
    -- =============================================================================
    
    -- FUELS & ADDITIVES
    { item="Base.Charcoal",          tags={"Resource.Fuel.Solid", "Theme.Survival", "Rarity.Common"},        basePrice=15, stockRange={min=10, max=40} },
    { item="Base.Coke",              tags={"Resource.Fuel.Industrial", "Rarity.Uncommon"},                   basePrice=25, stockRange={min=5, max=20} },
    { item="Base.Limestone",         tags={"Resource.Material.Industrial", "Rarity.Common"},                 basePrice=10, stockRange={min=10, max=30} },
    
    -- CLAY & MOLDS (Molds are Tools)
    { item="Base.Claybag",           tags={"Resource.Material.Industrial", "Quality.Basic", "Rarity.Common"}, basePrice=60, stockRange={min=2, max=8} },
    { item="Base.ClayBrick",         tags={"Resource.Material.Build", "Rarity.Common"},                          basePrice=15, stockRange={min=10, max=40} },
    { item="Base.CeramicCrucible",   tags={"Tool.Smithing.Crucible", "Rarity.Uncommon"},                        basePrice=150, stockRange={min=1, max=3} },
    { item="Base.IronIngotMold",     tags={"Tool.Smithing.Mold", "Rarity.Uncommon"},                            basePrice=100, stockRange={min=1, max=2} }, -- Reusable
    { item="Base.SteelIngotMold",    tags={"Tool.Smithing.Mold", "Rarity.Uncommon"},                            basePrice=120, stockRange={min=1, max=2} },

    -- GLASS & STONE
    { item="Base.GlassPanel",        tags={"Resource.Material.Glass", "Rarity.Uncommon"}, basePrice=100, stockRange={min=2, max=10} }, -- Worth: 50.0
    { item="Base.StoneBlock",        tags={"Resource.Material.Raw", "Rarity.Common"},    basePrice=40, stockRange={min=5, max=15} },
    { item="Base.StoneWheel",        tags={"Resource.Material.Raw", "Rarity.Rare"},      basePrice=300, stockRange={min=0, max=2} },
    { item="Base.SharpedStone",      tags={"Resource.Material.Raw", "Rarity.Common"},    basePrice=20, stockRange={min=5, max=15} },

    -- =============================================================================
    -- 3. TEXTILES & LEATHER
    -- =============================================================================
    
    -- FABRICS
    { item="Base.FabricRoll_Cotton", tags={"Resource.Material.Textile", "Rarity.Uncommon"}, basePrice=240, stockRange={min=1, max=3} }, -- Worth: 120.0
    { item="Base.Sheet",             tags={"Resource.Material.Textile", "Rarity.Common"},   basePrice=30,  stockRange={min=5, max=20} }, -- Worth: 15.0
    -- (Consolidated in DT_Medical.lua)
    
    -- CORDAGE
    { item="Base.Rope",              tags={"Resource.Material.Cordage", "Rarity.Common"}, basePrice=70,  stockRange={min=2, max=10} }, -- Worth: 35.0
    { item="Base.Twine",             tags={"Resource.Material.Cordage", "Rarity.Common"}, basePrice=30,  stockRange={min=5, max=15} }, -- Worth: 15.0
    { item="Base.Thread",            tags={"Resource.Material.Cordage", "Rarity.Common"}, basePrice=24,  stockRange={min=5, max=20} }, -- Worth: 12.0
    
    -- LEATHER (Crucial for Armor)
    -- (Consolidated in DT_Medical.lua)
    { item="Base.Leather_Crude_Large",tags={"Resource.Material.Bio", "Theme.Survival"}, basePrice=120, stockRange={min=1, max=4} }, -- Worth: 60.0
    { item="Base.CowHide",           tags={"Resource.Material.Bio", "Rarity.Rare"},    basePrice=240, stockRange={min=1, max=3} }, -- Worth: 120.0
    { item="Base.RabbitLeather_Full",tags={"Resource.Material.Bio", "Rarity.Common"},  basePrice=50,  stockRange={min=2, max=8} }, -- Worth: 25.0

    -- =============================================================================
    -- 4. COMPONENTS & INDUSTRIAL TOOLS
    -- =============================================================================
    
    -- ADHESIVES (High Utility)
    { item="Base.DuctTape",          tags={"Resource.Material.Utility", "Rarity.Uncommon"}, basePrice=170, stockRange={min=1, max=5} }, -- Worth: 85.0
    { item="Base.Glue",              tags={"Resource.Material.Utility", "Rarity.Common"},   basePrice=70,  stockRange={min=2, max=8} }, -- Worth: 35.0
    { item="Base.Woodglue",          tags={"Resource.Material.Utility", "Rarity.Uncommon"}, basePrice=130, stockRange={min=1, max=5} }, -- Worth: 65.0
    { item="Base.Epoxy",             tags={"Resource.Material.Utility", "Rarity.Uncommon"}, basePrice=150, stockRange={min=1, max=4} }, -- Worth: 75.0
    
    -- CONSTRUCTION
    { item="Base.NailsBox",          tags={"Resource.Material.General", "Rarity.Uncommon"}, basePrice=360, stockRange={min=2, max=10} }, -- Worth: 180.0
    { item="Base.Nails",             tags={"Resource.Material.General", "Rarity.Common"},   basePrice=4,   stockRange={min=50, max=200} }, -- Worth: 2.0
    { item="Base.Wire",              tags={"Resource.Material.Utility", "Rarity.Common"},   basePrice=70,  stockRange={min=2, max=8} }, -- Worth: 35.0
    { item="Base.PropaneTank",       tags={"Resource.Fuel.Liquid", "Rarity.Rare"},          basePrice=500, stockRange={min=1, max=3} }, -- Worth: 250.0
    { item="Base.WeldingRods",       tags={"Resource.Material.Utility", "Rarity.Uncommon"}, basePrice=120, stockRange={min=2, max=10} }, -- Worth: 60.0
    { item="Base.GunPowder",         tags={"Resource.Material.Chemical", "Rarity.Rare"}, basePrice=10, stockRange={min=1, max=4} },
    { item="Base.Paper",             tags={"Resource.Material.Paper", "Rarity.Common"}, basePrice=2, stockRange={min=5, max=20} },

    -- TOOL HEADS
    { item="Base.SledgehammerHead",  tags={"Resource.Material.Metal", "Rarity.Rare"}, basePrice=700, stockRange={min=0, max=2} }, -- Worth: 350.0
    { item="Base.FireAxeHead",       tags={"Resource.Material.Metal", "Rarity.Uncommon"}, basePrice=220, stockRange={min=1, max=3} }, -- Worth: 110.0
    { item="Base.SpearHead",         tags={"Resource.Material.Metal", "Rarity.Common"},   basePrice=90,  stockRange={min=2, max=6} }, -- Worth: 45.0
    
    -- HEAVY ANVILS
{ item="Base.BlacksmithAnvilUntreated", tags={"Tool.Smithing.Anvil", "Quality.Standard", "Rarity.Rare"}, basePrice=1000, stockRange={min=0, max=1} },

})

print("[DynamicTrading] Materials Registry Complete \n.")
