require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. SMOKING & TOBACCO (The Apocalyptic Currency)
-- =============================================================================
-- High demand, reduces stress.
{ item="Base.CigaretteSingle", basePrice=4, tags={"Junk.Tobacco", "Rarity.Common"}, stockRange={min=10, max=50} },
{ item="Base.CigaretteRolled", basePrice=3, tags={"Junk.Tobacco", "Rarity.Common"}, stockRange={min=10, max=50} },
{ item="Base.Cigarillo", basePrice=15, tags={"Junk.Tobacco", "Rarity.Common"}, stockRange={min=5, max=15} },
{ item="Base.Cigar", basePrice=50, tags={"Junk.Tobacco", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=1, max=5} },

-- Bulk
{ item="Base.CigarettePack",        basePrice=80,  tags={"Junk.Tobacco", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.CigaretteCarton",      basePrice=1500, tags={"Junk.Tobacco", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=1} },

-- Components
{ item="Base.TobaccoLoose",         basePrice=85,  tags={"Resource.Material.Tobacco", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.TobaccoChewing",       basePrice=45,  tags={"Resource.Material.Tobacco", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.CigaretteRollingPapers",basePrice=15, tags={"Resource.Material.Tobacco", "Rarity.Common"}, stockRange={min=2, max=10} },

-- Paraphernalia
{ item="Base.CanPipe",              basePrice=5,   tags={"Junk.Tobacco.Tool", "Quality.Junk"}, stockRange={min=1, max=5} },
{ item="Base.CanPipe_Tobacco",      basePrice=10,  tags={"Junk.Tobacco.Tool", "Quality.Junk"}, stockRange={min=0, max=5} },
{ item="Base.SmokingPipe_Tobacco",  basePrice=65,  tags={"Junk.Tobacco.Tool", "Quality.Standard", "Rarity.Uncommon"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 2. HYGIENE & GROOMING (Health & Morale)
-- =============================================================================
{ item="Base.ToiletPaper",          basePrice=60,  tags={"Junk.Hygiene", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.Toothbrush",           basePrice=15,  tags={"Junk.Hygiene", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Toothpaste",           basePrice=25,  tags={"Junk.Hygiene", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Comb",                 basePrice=5,   tags={"Junk.Hygiene", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.PaperNapkins2",        basePrice=5,   tags={"Junk.Hygiene", "Rarity.Common"}, stockRange={min=2, max=10} },

-- Luxuries
{ item="Base.Perfume",              basePrice=350,  tags={"Junk.Hygiene", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
{ item="Base.Cologne",              basePrice=350,  tags={"Junk.Hygiene", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 3. ENTERTAINMENT & HOBBIES (Stress Reduction)
-- =============================================================================
{ item="Base.CardDeck",             basePrice=25,  tags={"Junk.Fun.Game", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Dice",                 basePrice=5,   tags={"Junk.Fun.Game", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.Dice_Bone",            basePrice=15,  tags={"Junk.Fun.Game", "Quality.Primitive", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.Dice_Wood",            basePrice=10,  tags={"Junk.Fun.Game", "Quality.Primitive", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Crayons",              basePrice=15,  tags={"Junk.Fun.Art", "Rarity.Common"}, stockRange={min=1, max=3} },

-- Board Games (Complete sets valued higher)
{ item="Base.ChessWhite",           basePrice=15,  tags={"Junk.Fun.Game", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.ChessBlack",           basePrice=15,  tags={"Junk.Fun.Game", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.CheckerBoard",         basePrice=85,  tags={"Junk.Fun.Game", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.BackgammonBoard",      basePrice=85,  tags={"Junk.Fun.Game", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.GamePieceBlack",       basePrice=2,   tags={"Junk.Fun.Game", "Rarity.Common"}, stockRange={min=5, max=10} },
{ item="Base.GamePieceRed",         basePrice=2,   tags={"Junk.Fun.Game", "Rarity.Common"}, stockRange={min=5, max=10} },
{ item="Base.GamePieceWhite",       basePrice=2,   tags={"Junk.Fun.Game", "Rarity.Common"}, stockRange={min=5, max=10} },

-- Photography
{ item="Base.Camera",               basePrice=120, tags={"Electronics.Utility", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.CameraDisposable",     basePrice=35,  tags={"Electronics.Utility", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.CameraFilm",           basePrice=20,  tags={"Resource.Material.Industrial", "Rarity.Uncommon"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 4. PRE-WAR RELICS & VALUABLES
-- =============================================================================
-- Useless functionality, but high RP trade value.
{ item="Base.StockCertificate",     basePrice=150,  tags={"Quality.Luxury", "Theme.Social", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.CreditCard",           basePrice=5,    tags={"Junk.Trash.Relict", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.CreditCard_Stolen",    basePrice=5,    tags={"Junk.Trash.Relict", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.DogTag_Pet_Blank",     basePrice=15,   tags={"Junk.Trash.Relict", "Rarity.Uncommon"}, stockRange={min=0, max=2} },

-- Decor / Shiny
{ item="Base.Bell",                 basePrice=5,   tags={"Quality.Luxury", "Resource.Material.Metal", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.BrassNameplate",       basePrice=10,  tags={"Quality.Luxury", "Resource.Material.Metal", "Rarity.Rare"}, stockRange={min=0, max=2} },
{ item="Base.Pinecone",             basePrice=1,   tags={"Resource.Fuel.Organic", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Book_Prop",            basePrice=5,   tags={"Junk.Decor.Paper", "Resource.Fuel.Organic", "Rarity.Common"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_Prop",       basePrice=15,  tags={"Junk.Decor.Paper", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 5. TRUE JUNK & SCRAP MATERIALS
-- =============================================================================
-- Used for specific crafting or just fuel.

-- Metal/Plastic Scrap
{ item="Base.UnusableMetal",        basePrice=5,   tags={"Junk.Waste.Metal", "Resource.Material.Metal", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.SpadeHead",            basePrice=25,  tags={"Resource.Material.Metal", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.TableLeg",             basePrice=10,  tags={"Resource.Material.Wood", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.ChairLeg",             basePrice=10,  tags={"Resource.Material.Wood", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.UnusableWood",         basePrice=2,   tags={"Junk.Waste.Wood", "Resource.Material.Wood", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.TwigsBundle",          basePrice=5,   tags={"Junk.Waste.Wood", "Resource.Material.Wood", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Splinters",            basePrice=1,   tags={"Junk.Waste.Wood", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Straw2",               basePrice=5,   tags={"Resource.Material.Organic", "Rarity.Common"}, stockRange={min=5, max=20} },

-- Containers
{ item="Base.PopEmpty",             basePrice=2,   tags={"Junk.Waste.Metal", "Resource.Material.Metal", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Pop2Empty",            basePrice=2,   tags={"Junk.Waste.Metal", "Resource.Material.Metal", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Pop3Empty",            basePrice=2,   tags={"Junk.Waste.Metal", "Resource.Material.Metal", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.TinCanEmpty",          basePrice=2,   tags={"Junk.Waste.Metal", "Resource.Material.Metal", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.WaterRationCanEmpty",  basePrice=15,  tags={"Container.Fluid", "Origin.Military", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
{ item="Base.PlasticTray",          basePrice=5,   tags={"Junk.Waste.Plastic", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.ClayPlate",            basePrice=10,  tags={"Container.Cooking.Serving", "Origin.Primitive", "Rarity.Common"}, stockRange={min=1, max=5} },

-- Office Supplies / Trash
{ item="Base.Stapler",              basePrice=45,  tags={"Tool.Household", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.Staples",              basePrice=15,  tags={"Resource.Material.Metal", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.HolePuncher",          basePrice=45,  tags={"Tool.Household", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.RubberBand",           basePrice=2,   tags={"Junk.Waste.Plastic", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Cork",                 basePrice=2,   tags={"Resource.Material.Organic", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.DryerLint",            basePrice=2,   tags={"Resource.Material.Tinder", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.ScratchTicket",        basePrice=2,   tags={"Junk.Waste.Paper", "Rarity.Common"}, stockRange={min=5, max=20} },

-- Fur Tufts
{ item="Base.FurTuft_Black",        basePrice=15,  tags={"Resource.Material.Textile", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.FurTuft_White",        basePrice=15,  tags={"Resource.Material.Textile", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.FurTuft_Grey",         basePrice=15,  tags={"Resource.Material.Textile", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.FurTuft_Browndark",    basePrice=15,  tags={"Resource.Material.Textile", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.FurTuft_Brownlight",   basePrice=15,  tags={"Resource.Material.Textile", "Rarity.Common"}, stockRange={min=1, max=5} },

-- Tools
{ item="Base.Tsquare",              basePrice=65,  tags={"Tool.Household", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.Frame",                basePrice=15,  tags={"Junk.Decor.Wood", "Resource.Material.Wood", "Rarity.Common"}, stockRange={min=1, max=5} },

})

print("[DynamicTrading] Junk Registry Complete \n.")
