require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}

DynamicTrading.ArchetypeLooks["Office"] = {
        Male = {
            { "Base.Glasses_Normal", "Base.Suit_Jacket", "Base.Shirt_FormalWhite", "Base.Tie_Full", "Base.Trousers_Suit", "Base.Shoes_Black" },
            { "Base.Glasses_Prescription", "Base.Shirt_FormalBlue", "Base.Tie_Worn", "Base.Trousers_Suit", "Base.Shoes_Brown" },
            { "Base.Hat_Trilby", "Base.Vest_Waistcoat", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Glasses_Reading", "Base.Jumper_DiamondPatternTINT", "Base.Shirt_FormalWhite", "Base.Trousers_SuitTEXTURE", "Base.Shoes_Fancy" },
            { "Base.Suit_JacketTINT", "Base.Shirt_FormalTINT", "Base.Trousers_Suit", "Base.Shoes_Black" },
        },
        Female = {
            { "Base.Glasses_Normal", "Base.Suit_Jacket", "Base.Shirt_FormalWhite", "Base.Tie_Full", "Base.Skirt_Knees", "Base.Shoes_Black" },
            { "Base.Glasses_Prescription", "Base.Shirt_FormalBlue", "Base.Tie_Worn", "Base.Skirt_Normal", "Base.Shoes_Brown" },
            { "Base.Hat_Trilby", "Base.Vest_Waistcoat", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Glasses_Reading", "Base.Jumper_DiamondPatternTINT", "Base.Shirt_FormalWhite", "Base.Trousers_SuitTEXTURE", "Base.Shoes_Fancy" },
            { "Base.Suit_JacketTINT", "Base.Shirt_FormalTINT", "Base.Skirt_Long", "Base.Shoes_Black" },
        }
}
