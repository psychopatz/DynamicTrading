require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. SMOKING & TOBACCO
-- =============================================================================
{ item="Base.CigaretteSingle", basePrice=4, tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=10, max=50} },
{ item="Base.CigaretteRolled", basePrice=3, tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=10, max=50} },
{ item="Base.Cigarillo", basePrice=15, tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=5, max=15} },
{ item="Base.Cigar", basePrice=50, tags={"Medical.Tobacco", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=1, max=5} },

{ item="Base.CigarettePack",        basePrice=80,  tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.CigaretteCarton",      basePrice=1500, tags={"Medical.Tobacco", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=1} },

{ item="Base.TobaccoLoose",         basePrice=85,  tags={"Medical.Tobacco", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.TobaccoChewing",       basePrice=45,  tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.CigaretteRollingPapers",basePrice=15, tags={"Medical.Tobacco", "Rarity.Common"}, stockRange={min=2, max=10} },

{ item="Base.CanPipe",              basePrice=5,   tags={"Medical.Tobacco", "Quality.Waste"}, stockRange={min=1, max=5} },
{ item="Base.CanPipe_Tobacco",      basePrice=10,  tags={"Medical.Tobacco", "Quality.Waste"}, stockRange={min=0, max=5} },
{ item="Base.SmokingPipe_Tobacco",  basePrice=65,  tags={"Medical.Tobacco", "Quality.Basic", "Rarity.Uncommon"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 2. HYGIENE & GROOMING
-- =============================================================================
{ item="Base.ToiletPaper",          basePrice=60,  tags={"Misc.Hygiene", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.Toothbrush",           basePrice=15,  tags={"Misc.Hygiene", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Toothpaste",           basePrice=25,  tags={"Misc.Hygiene", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Comb",                 basePrice=5,   tags={"Misc.Hygiene", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.PaperNapkins2",        basePrice=5,   tags={"Resource.Material.Paper", "Misc.Hygiene", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.Perfume",              basePrice=350,  tags={"Misc.Hygiene", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
{ item="Base.Cologne",              basePrice=350,  tags={"Misc.Hygiene", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 3. LEISURE & GAMES
-- =============================================================================
{ item="Base.CardDeck",             basePrice=25,  tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Dice",                 basePrice=5,   tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.Dice_Bone",            basePrice=15,  tags={"Misc.General", "Theme.Leisure", "Origin.Nomad", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.Dice_Wood",            basePrice=10,  tags={"Misc.General", "Theme.Leisure", "Origin.Nomad", "Rarity.Common"}, stockRange={min=1, max=3} },

{ item="Base.ChessWhite",           basePrice=15,  tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.ChessBlack",           basePrice=15,  tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.CheckerBoard",         basePrice=85,  tags={"Misc.General", "Theme.Leisure", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.BackgammonBoard",      basePrice=85,  tags={"Misc.General", "Theme.Leisure", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.GamePieceBlack",       basePrice=2,   tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=5, max=10} },
{ item="Base.GamePieceRed",         basePrice=2,   tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=5, max=10} },
{ item="Base.GamePieceWhite",       basePrice=2,   tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, stockRange={min=5, max=10} },

-- Photography
{ item="Base.Camera",               basePrice=120, tags={"Electronics.Component.Digital", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.CameraDisposable",     basePrice=35,  tags={"Electronics.Component.Digital", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.CameraFilm",           basePrice=20,  tags={"Resource.Material.Chemical", "Rarity.Uncommon"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 4. RELICS & ARTIFACTS
-- =============================================================================
{ item="Base.StockCertificate",     basePrice=150,  tags={"Misc.Artifact", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.CreditCard",           basePrice=5,    tags={"Misc.Artifact", "Quality.Waste"}, stockRange={min=1, max=5} },
{ item="Base.CreditCard_Stolen",    basePrice=5,    tags={"Misc.Artifact", "Quality.Waste"}, stockRange={min=1, max=5} },
{ item="Base.DogTag_Pet_Blank",     basePrice=15,   tags={"Misc.Artifact", "Rarity.Uncommon"}, stockRange={min=0, max=2} },

-- Decor
{ item="Base.Bell",                 basePrice=5,   tags={"Misc.Decor", "Resource.Material.Metal", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.BrassNameplate",       basePrice=10,  tags={"Misc.Decor", "Resource.Material.Metal", "Rarity.Rare"}, stockRange={min=0, max=2} },
{ item="Base.Book_Prop",            basePrice=5,   tags={"Misc.Decor", "Resource.Material.Wood", "Rarity.Common"}, stockRange={min=0, max=2} },
{ item="Base.BookFancy_Prop",       basePrice=15,  tags={"Misc.Decor", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.Frame",                basePrice=15,  tags={"Misc.Decor", "Resource.Material.Wood", "Rarity.Common"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 5. JEWELRY & COSMETICS
-- =============================================================================
{ item="Base.Necklace_Pearl",                  tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Legendary"}, basePrice=1500, stockRange={min=0, max=1} },
{ item="Base.Necklace_GoldDiamond",            tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Legendary"}, basePrice=1200, stockRange={min=0, max=1} },
{ item="Base.NecklaceLong_GoldDiamond",        tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Legendary"}, basePrice=1200, stockRange={min=0, max=1} },
{ item="Base.Necklace_GoldRuby",               tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=900, stockRange={min=0, max=1} },
{ item="Base.Necklace_SilverDiamond",          tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=800, stockRange={min=0, max=1} },
{ item="Base.NecklaceLong_SilverDiamond",      tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=800, stockRange={min=0, max=1} },

{ item="Base.Ring_Left_RingFinger_GoldDiamond",  tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=750, stockRange={min=0, max=1} },
{ item="Base.Ring_Right_RingFinger_GoldDiamond", tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=750, stockRange={min=0, max=1} },
{ item="Base.Ring_Left_RingFinger_GoldRuby",     tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=650, stockRange={min=0, max=1} },

{ item="Base.Earring_Dangly_Diamond",          tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=500, stockRange={min=0, max=2} },
{ item="Base.Earring_Dangly_Ruby",             tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=450, stockRange={min=0, max=2} },

-- Standard Jewelry
{ item="Base.Necklace_Gold",                   tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=350, stockRange={min=1, max=2} },
{ item="Base.Ring_Left_RingFinger_Gold",       tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=250, stockRange={min=1, max=3} },
{ item="Base.Necklace_SilverSapphire",         tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=300, stockRange={min=1, max=2} },
{ item="Base.Ring_Left_RingFinger_SilverDiamond", tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=220, stockRange={min=1, max=2} },

-- Functional Gadgets (Watches)
{ item="Base.WristWatch_Left_Expensive",       tags={"Electronics.Gadget.Wristwatch", "Quality.Luxury", "Rarity.Rare"},     basePrice=150, stockRange={min=0, max=1} },
{ item="Base.WristWatch_Left_ClassicGold",     tags={"Electronics.Gadget.Wristwatch", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=85,  stockRange={min=0, max=2} },
{ item="Base.WristWatch_Left_ClassicMilitary", tags={"Electronics.Gadget.Wristwatch", "Origin.Militia", "Rarity.Uncommon"}, basePrice=45, stockRange={min=1, max=3} },
{ item="Base.WristWatch_Left_DigitalBlack",    tags={"Electronics.Gadget.Wristwatch", "Rarity.Common"},    basePrice=15,  stockRange={min=3, max=10} },

-- Survivalist Jewelry
{ item="Base.Necklace_SkullMammal_Multi",      tags={"Misc.Cosmetic", "Origin.Nomad", "Rarity.Common"}, basePrice=25,  stockRange={min=1, max=3} },
{ item="Base.Necklace_BoarTusk_Multi",         tags={"Misc.Cosmetic", "Origin.Nomad", "Rarity.Common"}, basePrice=20,  stockRange={min=1, max=3} },

-- =============================================================================
-- 6. DISCARDED WASTE & RECYCLABLES
-- =============================================================================
{ item="Base.UnusableMetal",        basePrice=5,   tags={"Resource.Material.Metal", "Quality.Waste"}, stockRange={min=5, max=20} },
{ item="Base.UnusableWood",         basePrice=2,   tags={"Resource.Material.Wood", "Quality.Waste"}, stockRange={min=5, max=20} },
{ item="Base.SpadeHead",            basePrice=25,  tags={"Resource.Material.Metal", "Quality.Waste"}, stockRange={min=1, max=3} },
{ item="Base.PopEmpty",             basePrice=2,   tags={"Resource.Material.Metal", "Quality.Waste"}, stockRange={min=5, max=20} },
{ item="Base.TinCanEmpty",          basePrice=2,   tags={"Resource.Material.Metal", "Quality.Waste"}, stockRange={min=5, max=20} },
{ item="Base.PlasticTray",          basePrice=5,   tags={"Resource.Material.Plastic", "Quality.Waste"}, stockRange={min=1, max=5} },
{ item="Base.RubberBand",           basePrice=2,   tags={"Resource.Material.Plastic", "Quality.Waste"}, stockRange={min=5, max=20} },
{ item="Base.ScratchTicket",        basePrice=2,   tags={"Misc.General", "Quality.Waste"}, stockRange={min=5, max=20} },
})

print("[DynamicTrading] Misc Registry Complete \n.")
