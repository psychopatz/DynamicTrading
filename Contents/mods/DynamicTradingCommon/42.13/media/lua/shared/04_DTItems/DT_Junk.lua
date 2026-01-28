require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
-- =============================================================================
-- 1. SMOKING & TOBACCO (The Apocalyptic Currency)
-- =============================================================================
-- High demand, reduces stress.
{ item="Base.CigaretteSingle", basePrice=1, tags={"Tobacco", "Common"}, stockRange={min=10, max=50} },
{ item="Base.CigaretteRolled", basePrice=1, tags={"Tobacco", "Common"}, stockRange={min=10, max=50} },
{ item="Base.Cigarillo", basePrice=2, tags={"Tobacco", "Common"}, stockRange={min=5, max=20} },
{ item="Base.Cigar", basePrice=5, tags={"Tobacco", "Luxury"}, stockRange={min=1, max=10} }, -- The fancy stuff

-- Bulk
{ item="Base.CigarettePack",        basePrice=18,  tags={"Tobacco", "Common"}, stockRange={min=2, max=15} },
{ item="Base.CigaretteCarton",      basePrice=160, tags={"Tobacco", "Stockpile", "Rare"}, stockRange={min=1, max=3} },

-- Components
{ item="Base.TobaccoLoose",         basePrice=15,  tags={"Tobacco", "Material"}, stockRange={min=1, max=10} }, -- 50 units
{ item="Base.TobaccoChewing",       basePrice=10,  tags={"Tobacco", "Material"}, stockRange={min=1, max=5} },
{ item="Base.CigaretteRollingPapers",basePrice=5,  tags={"Tobacco", "Material"}, stockRange={min=2, max=10} },

-- Paraphernalia
{ item="Base.CanPipe",              basePrice=1,   tags={"Tobacco", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.CanPipe_Tobacco",      basePrice=2,   tags={"Tobacco", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.SmokingPipe_Tobacco",  basePrice=5,   tags={"Tobacco", "Luxury"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 2. HYGIENE & GROOMING (Health & Morale)
-- =============================================================================
{ item="Base.ToiletPaper",          basePrice=15,  tags={"Hygiene", "Luxury", "Common"}, stockRange={min=2, max=10} }, -- Gold dust
{ item="Base.Toothbrush",           basePrice=5,   tags={"Hygiene", "Common"}, stockRange={min=1, max=5} },
{ item="Base.Toothpaste",           basePrice=5,   tags={"Hygiene", "Common"}, stockRange={min=1, max=5} },
{ item="Base.Comb",                 basePrice=2,   tags={"Hygiene", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.PaperNapkins2",        basePrice=2,   tags={"Hygiene", "Junk", "Fuel"}, stockRange={min=5, max=20} },

-- Luxuries
{ item="Base.Perfume",              basePrice=25,  tags={"Hygiene", "Luxury", "Rare"}, stockRange={min=1, max=3} },
{ item="Base.Cologne",              basePrice=25,  tags={"Hygiene", "Luxury", "Rare"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 3. ENTERTAINMENT & HOBBIES (Stress Reduction)
-- =============================================================================
{ item="Base.CardDeck",             basePrice=5,   tags={"Fun", "Common"}, stockRange={min=1, max=5} },
{ item="Base.Dice",                 basePrice=1,   tags={"Fun", "Junk"}, stockRange={min=1, max=10} },
{ item="Base.Dice_Bone",            basePrice=2,   tags={"Fun", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.Dice_Wood",            basePrice=1,   tags={"Fun", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.Crayons",              basePrice=3,   tags={"Fun", "Common"}, stockRange={min=1, max=5} },

-- Board Games (Complete sets valued higher)
{ item="Base.ChessWhite",           basePrice=2,   tags={"Fun", "Junk"}, stockRange={min=1, max=10} },
{ item="Base.ChessBlack",           basePrice=2,   tags={"Fun", "Junk"}, stockRange={min=1, max=10} },
{ item="Base.CheckerBoard",         basePrice=10,  tags={"Fun", "Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.BackgammonBoard",      basePrice=10,  tags={"Fun", "Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.GamePieceBlack",       basePrice=0.5, tags={"Fun", "Junk"}, stockRange={min=5, max=10} },
{ item="Base.GamePieceRed",         basePrice=0.5, tags={"Fun", "Junk"}, stockRange={min=5, max=10} },
{ item="Base.GamePieceWhite",       basePrice=0.5, tags={"Fun", "Junk"}, stockRange={min=5, max=10} },

-- Photography
{ item="Base.Camera",               basePrice=30,  tags={"Fun", "Electronics", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.CameraDisposable",     basePrice=10,  tags={"Fun", "Electronics"}, stockRange={min=0, max=2} },
{ item="Base.CameraFilm",           basePrice=5,   tags={"Fun", "Material"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 4. PRE-WAR RELICS & VALUABLES
-- =============================================================================
-- Useless functionality, but high RP trade value.
{ item="Base.StockCertificate",     basePrice=5,   tags={"Luxury", "Paper", "Junk"}, stockRange={min=0, max=5} }, -- Gambler's item
{ item="Base.CreditCard",           basePrice=0.5, tags={"Junk", "Plastic"}, stockRange={min=1, max=10} },
{ item="Base.CreditCard_Stolen",    basePrice=0.5, tags={"Junk", "Plastic"}, stockRange={min=1, max=10} },
{ item="Base.DogTag_Pet_Blank",     basePrice=1,   tags={"Junk", "Metal"}, stockRange={min=1, max=5} },

-- Decor / Shiny
{ item="Base.Bell",                 basePrice=5,   tags={"Luxury", "Metal"}, stockRange={min=0, max=2} },
{ item="Base.BrassNameplate",       basePrice=5,   tags={"Luxury", "Metal"}, stockRange={min=0, max=2} },
{ item="Base.Pinecone",             basePrice=0.5, tags={"Decor", "Fuel"}, stockRange={min=5, max=20} },
{ item="Base.Glitter",              basePrice=2,   tags={"Decor", "Junk"}, stockRange={min=1, max=3} },
{ item="Base.Book_Prop",            basePrice=5,   tags={"Decor", "Fuel"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_Prop",       basePrice=10,  tags={"Decor", "Luxury"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 5. TRUE JUNK & SCRAP MATERIALS
-- =============================================================================
-- Used for specific crafting or just fuel.

-- Metal/Plastic Scrap
{ item="Base.UnusableMetal",        basePrice=1,   tags={"Material", "Metal", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.SpadeHead",            basePrice=2,   tags={"Material", "Metal"}, stockRange={min=1, max=3} },
{ item="Base.TableLeg",             basePrice=1,   tags={"Material", "Wood", "Fuel"}, stockRange={min=1, max=5} },
{ item="Base.ChairLeg",             basePrice=1,   tags={"Material", "Wood", "Fuel"}, stockRange={min=1, max=5} },
{ item="Base.UnusableWood",         basePrice=0.5, tags={"Material", "Wood", "Fuel"}, stockRange={min=5, max=20} },
{ item="Base.TwigsBundle",          basePrice=0.5, tags={"Fuel", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.Splinters",            basePrice=0.1, tags={"Fuel", "Trash"}, stockRange={min=5, max=20} },
{ item="Base.Straw2",               basePrice=0.5, tags={"Material", "Fuel"}, stockRange={min=5, max=20} },

-- Containers
{ item="Base.PopEmpty",             basePrice=0.2, tags={"Junk", "Metal"}, stockRange={min=5, max=20} },
{ item="Base.Pop2Empty",            basePrice=0.2, tags={"Junk", "Metal"}, stockRange={min=5, max=20} },
{ item="Base.Pop3Empty",            basePrice=0.2, tags={"Junk", "Metal"}, stockRange={min=5, max=20} },
{ item="Base.TinCanEmpty",          basePrice=0.2, tags={"Junk", "Metal"}, stockRange={min=5, max=20} },
{ item="Base.WaterRationCanEmpty",  basePrice=0.5, tags={"Junk", "Metal"}, stockRange={min=1, max=5} }, -- Good water container
{ item="Base.PlasticTray",          basePrice=1,   tags={"Junk", "Plastic"}, stockRange={min=1, max=5} },
{ item="Base.ClayPlate",            basePrice=1,   tags={"Junk", "Ceramic"}, stockRange={min=1, max=5} },

-- Office Supplies / Trash
{ item="Base.Stapler",              basePrice=3,   tags={"Tool", "Office"}, stockRange={min=1, max=3} },
{ item="Base.Staples",              basePrice=1,   tags={"Material", "Office"}, stockRange={min=2, max=10} },
{ item="Base.HolePuncher",          basePrice=3,   tags={"Tool", "Office"}, stockRange={min=1, max=3} },
{ item="Base.RubberBand",           basePrice=0.1, tags={"Material", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.Cork",                 basePrice=0.1, tags={"Material", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.DryerLint",            basePrice=0.1, tags={"Fuel", "Trash"}, stockRange={min=5, max=20} }, -- Great tinder
{ item="Base.ScratchTicket",        basePrice=0.1, tags={"Trash"}, stockRange={min=5, max=20} },

-- Fur Tufts (Tailoring scraps)
{ item="Base.FurTuft_Black",        basePrice=0.5, tags={"Material", "Textile"}, stockRange={min=1, max=10} },
{ item="Base.FurTuft_White",        basePrice=0.5, tags={"Material", "Textile"}, stockRange={min=1, max=10} },
{ item="Base.FurTuft_Grey",         basePrice=0.5, tags={"Material", "Textile"}, stockRange={min=1, max=10} },
{ item="Base.FurTuft_Browndark",    basePrice=0.5, tags={"Material", "Textile"}, stockRange={min=1, max=10} },
{ item="Base.FurTuft_Brownlight",   basePrice=0.5, tags={"Material", "Textile"}, stockRange={min=1, max=10} },

-- Tools
{ item="Base.Tsquare",              basePrice=5,   tags={"Tool", "Woodwork"}, stockRange={min=1, max=3} },
{ item="Base.Frame",                basePrice=2,   tags={"Material", "Junk"}, stockRange={min=1, max=5} },

})

print("[DynamicTrading] Junk Registry Complete.")
