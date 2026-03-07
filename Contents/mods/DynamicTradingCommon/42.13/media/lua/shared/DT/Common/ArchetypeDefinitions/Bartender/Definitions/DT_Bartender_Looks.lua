require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}

DynamicTrading.ArchetypeLooks["Bartender"] = {
        Male = {
            { "Base.Hat_Fedora_Delmonte", "Base.Vest_Waistcoat", "Base.Shirt_FormalWhite", "Base.Tie_BowTieFull", "Base.Trousers_Suit", "Base.Shoes_Black" },
            { "Base.Hat_Bowler", "Base.Shirt_FormalWhite", "Base.Tie_Full", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Glasses_Cosmetic_Normal", "Base.Shirt_FormalTINT", "Base.Apron_Black", "Base.Trousers_SuitTEXTURE", "Base.Shoes_Fancy" },
            { "Base.Hat_VisorBlack", "Base.Tshirt_PoloTINT", "Base.Apron_White", "Base.Trousers_Black", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_FlatCap", "Base.Vest_WaistcoatTINT", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Trousers_Suit", "Base.Shoes_Black" },
        },
        Female = {
            { "Base.Hat_Fedora_Delmonte", "Base.Vest_Waistcoat", "Base.Shirt_FormalWhite", "Base.Tie_BowTieFull", "Base.Trousers_Suit", "Base.Shoes_Black" },
            { "Base.Hat_Bowler", "Base.Shirt_FormalWhite", "Base.Tie_Full", "Base.Skirt_Knees", "Base.Shoes_Black" },
            { "Base.Glasses_Cosmetic_Normal", "Base.Shirt_FormalTINT", "Base.Apron_Black", "Base.Skirt_Normal", "Base.Shoes_Fancy" },
            { "Base.Hat_VisorBlack", "Base.Tshirt_PoloTINT", "Base.Apron_White", "Base.Trousers_Black", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_FlatCap", "Base.Vest_WaistcoatTINT", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Skirt_Long", "Base.Shoes_Black" },
        }
}
