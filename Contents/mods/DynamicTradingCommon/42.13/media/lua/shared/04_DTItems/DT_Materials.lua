require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({

    -- =============================================================================
    -- 1. METALS (Smithing & Crafting)
    -- =============================================================================
    
    -- ALUMINUM & BRASS
    { item="Base.Aluminum",          tags={"Material", "Smithing", "Electronics"}, basePrice=15, stockRange={min=5, max=15} },
    { item="Base.AluminumScrap",     tags={"Material", "Smithing", "Junk"},        basePrice=5,  stockRange={min=5, max=15} },
    { item="Base.BrassIngot",        tags={"Material", "Smithing", "Uncommon"},    basePrice=80, stockRange={min=1, max=4} },
    { item="Base.BrassScrap",        tags={"Material", "Smithing", "Junk"},        basePrice=10, stockRange={min=5, max=20} },
    
    -- COPPER (Electronics & Plumbing)
    { item="Base.CopperIngot",       tags={"Material", "Smithing", "Electronics"}, basePrice=60, stockRange={min=2, max=6} },
    { item="Base.CopperOre",         tags={"Material", "Smithing", "Heavy"},       basePrice=30, stockRange={min=1, max=4} },
    { item="Base.CopperScrap",       tags={"Material", "Smithing", "Junk"},        basePrice=8,  stockRange={min=5, max=20} },
    { item="Base.CopperSheet",       tags={"Material", "Build", "Electronics"},    basePrice=45, stockRange={min=2, max=8} },
    
    -- IRON (Basic Construction)
    { item="Base.IronIngot",         tags={"Material", "Smithing", "Common"},      basePrice=70, stockRange={min=2, max=8} },
    { item="Base.IronBar",           tags={"Material", "Build", "Common"},         basePrice=45, stockRange={min=2, max=10} },
    { item="Base.IronOre",           tags={"Material", "Smithing", "Heavy"},       basePrice=35, stockRange={min=1, max=4} },
    { item="Base.IronScrap",         tags={"Material", "Smithing", "Junk"},        basePrice=12, stockRange={min=10, max=30} },
    { item="Base.IronBlock",         tags={"Material", "Smithing", "Heavy"},       basePrice=100,stockRange={min=1, max=4} },
    
    -- STEEL (High Tier)
    { item="Base.SteelIngot",        tags={"Material", "Smithing", "Rare"},        basePrice=120, stockRange={min=1, max=4} },
    { item="Base.SteelBar",          tags={"Material", "Build", "Uncommon"},       basePrice=90,  stockRange={min=2, max=6} },
    { item="Base.SteelScrap",        tags={"Material", "Smithing", "Common"},      basePrice=30,  stockRange={min=5, max=15} },
    { item="Base.SteelBlock",        tags={"Material", "Smithing", "Rare"},        basePrice=160, stockRange={min=1, max=4} },
    { item="Base.SteelSlug",         tags={"Material", "Ammo", "Smithing"},        basePrice=10,  stockRange={min=10, max=50} },

    -- PRECIOUS METALS (Currency / Luxury)
    -- Logic: Tagged 'Luxury' (3x multiplier). Base prices adjusted so they don't break the economy completely.
    { item="Base.GoldBar",           tags={"Material", "Luxury", "Rare"},          basePrice=500, stockRange={min=0, max=1} }, -- Real: 3000+
    { item="Base.SmallGoldBar",      tags={"Material", "Luxury", "Rare"},          basePrice=150, stockRange={min=0, max=2} },
    { item="Base.GoldScrap",         tags={"Material", "Luxury", "Common"},        basePrice=40,  stockRange={min=1, max=5} },
    { item="Base.SilverBar",         tags={"Material", "Luxury", "Rare"},          basePrice=250, stockRange={min=0, max=2} },
    { item="Base.SmallSilverBar",    tags={"Material", "Luxury", "Rare"},          basePrice=80,  stockRange={min=1, max=4} },
    { item="Base.SilverScrap",       tags={"Material", "Luxury", "Common"},        basePrice=20,  stockRange={min=2, max=10} },

    -- =============================================================================
    -- 2. CLAY, STONE & GLASS
    -- =============================================================================
    
    -- FUELS & ADDITIVES
    { item="Base.Charcoal",          tags={"Material", "Fuel", "Smithing"},        basePrice=15, stockRange={min=10, max=40} },
    { item="Base.Coke",              tags={"Material", "Fuel", "Smithing"},        basePrice=25, stockRange={min=5, max=20} },
    { item="Base.Limestone",         tags={"Material", "Smithing"},                basePrice=10, stockRange={min=10, max=30} },
    
    -- CLAY & MOLDS (Molds are Tools)
    { item="Base.Claybag",           tags={"Material", "Smithing", "Heavy"},       basePrice=60, stockRange={min=2, max=8} },
    { item="Base.ClayBrick",         tags={"Material", "Build", "Common"},         basePrice=15, stockRange={min=10, max=40} },
    { item="Base.CeramicCrucible",   tags={"Tool", "Smithing", "Uncommon"},        basePrice=150, stockRange={min=1, max=3} },
    { item="Base.IronIngotMold",     tags={"Tool", "Smithing", "Uncommon"},        basePrice=100, stockRange={min=1, max=2} }, -- Reusable
    { item="Base.SteelIngotMold",    tags={"Tool", "Smithing", "Uncommon"},        basePrice=120, stockRange={min=1, max=2} },

    -- GLASS & STONE
    { item="Base.GlassPanel",        tags={"Material", "Build", "Fragile"},        basePrice=45, stockRange={min=2, max=10} },
    { item="Base.GlassBlowingPipe",  tags={"Tool", "Smithing", "Rare"},            basePrice=130, stockRange={min=1, max=2} },
    { item="Base.StoneBlock",        tags={"Material", "Build", "Heavy"},          basePrice=20, stockRange={min=5, max=15} },
    { item="Base.StoneWheel",        tags={"Material", "Build", "Heavy"},          basePrice=150, stockRange={min=0, max=2} },
    { item="Base.SharpedStone",      tags={"Material", "Survivalist", "Common"},   basePrice=10, stockRange={min=5, max=15} },

    -- =============================================================================
    -- 3. TEXTILES & LEATHER
    -- =============================================================================
    
    -- FABRICS
    { item="Base.FabricRoll_Cotton", tags={"Material", "Textile", "Build"},        basePrice=120, stockRange={min=1, max=3} },
    { item="Base.Sheet",             tags={"Material", "Textile", "Common"},       basePrice=15,  stockRange={min=5, max=20} },
    { item="Base.RippedSheets",      tags={"Material", "Textile", "Junk"},         basePrice=2,   stockRange={min=20, max=100} },
    
    -- CORDAGE
    { item="Base.Rope",              tags={"Tool", "Survival", "Build"},           basePrice=35,  stockRange={min=2, max=10} },
    { item="Base.Twine",             tags={"Material", "Survival", "Common"},      basePrice=15,  stockRange={min=5, max=15} },
    { item="Base.Thread",            tags={"Material", "Textile", "Common"},       basePrice=12,  stockRange={min=5, max=20} },
    
    -- LEATHER (Crucial for Armor)
    { item="Base.LeatherStrips",     tags={"Material", "Textile", "Common"},       basePrice=5,   stockRange={min=10, max=50} },
    { item="Base.Leather_Crude_Large",tags={"Material", "Textile", "Survivalist"}, basePrice=60,  stockRange={min=1, max=4} },
    { item="Base.CowHide",           tags={"Material", "Textile", "Rare"},         basePrice=120, stockRange={min=1, max=3} },
    { item="Base.RabbitLeather_Full",tags={"Material", "Textile", "Common"},       basePrice=25,  stockRange={min=2, max=8} },

    -- =============================================================================
    -- 4. COMPONENTS & INDUSTRIAL TOOLS
    -- =============================================================================
    
    -- ADHESIVES (High Utility)
    { item="Base.DuctTape",          tags={"Material", "Repair", "Mechanic"},      basePrice=85,  stockRange={min=1, max=5} },
    { item="Base.Glue",              tags={"Material", "Repair", "Common"},        basePrice=35,  stockRange={min=2, max=8} },
    { item="Base.Woodglue",          tags={"Material", "Repair", "Carpenter"},     basePrice=65,  stockRange={min=1, max=5} },
    { item="Base.Epoxy",             tags={"Material", "Repair", "Mechanic"},      basePrice=75,  stockRange={min=1, max=4} },
    
    -- CONSTRUCTION
    { item="Base.NailsBox",          tags={"Material", "Build", "Carpenter"},      basePrice=180, stockRange={min=2, max=10} },
    { item="Base.Nails",             tags={"Material", "Build", "Common"},         basePrice=2,   stockRange={min=50, max=200} },
    { item="Base.Wire",              tags={"Material", "Build", "Electronics"},    basePrice=35,  stockRange={min=2, max=8} },
    { item="Base.PropaneTank",       tags={"Fuel", "Mechanic", "Heavy"},           basePrice=250, stockRange={min=1, max=3} },
    { item="Base.WeldingRods",       tags={"Material", "Mechanic", "Uncommon"},    basePrice=60,  stockRange={min=2, max=10} },
    { item="Base.GunPowder",         tags={"Material", "Ammo", "Military"},        basePrice=5, stockRange={min=1, max=4} },

    -- TOOL HEADS (The "Holy Grail" of scavenging)
    { item="Base.SledgehammerHead",  tags={"Tool", "Smithing", "Heavy", "Rare"},   basePrice=350, stockRange={min=0, max=2} },
    { item="Base.Katana_Blade",      tags={"Weapon", "Smithing", "Legendary"},     basePrice=500, stockRange={min=0, max=1} }, -- Real: 2500
    { item="Base.MacheteBlade",      tags={"Weapon", "Smithing", "Rare"},          basePrice=220, stockRange={min=0, max=2} },
    { item="Base.FireAxeHead",       tags={"Tool", "Smithing", "Uncommon"},        basePrice=110, stockRange={min=1, max=3} },
    { item="Base.SpearHead",         tags={"Weapon", "Smithing", "Common"},        basePrice=45,  stockRange={min=2, max=6} },
    
    -- HEAVY ANVILS
    { item="Base.BlacksmithAnvilUntreated", tags={"Tool", "Smithing", "Heavy", "Rare"}, basePrice=1000, stockRange={min=0, max=1} },

})

print("[DynamicTrading] Materials Registry Complete.")
