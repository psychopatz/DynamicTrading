require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}

DynamicTrading.ArchetypeLooks["Tailor"] = {
        Male = {
            { "Base.Glasses_Reading", "Base.Apron_WhiteTEXTURE", "Base.Shirt_FormalWhite", "Base.Trousers_SuitTEXTURE", "Base.Shoes_Black" },
            { "Base.Glasses_HalfMoon", "Base.Vest_WaistcoatTINT", "Base.Shirt_FormalTINT", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Glasses_Cosmetic_Normal", "Base.Jumper_VNeck", "Base.Trousers_Suit", "Base.Shoes_Brown" },
            { "Base.Hat_Beret", "Base.Shirt_FormalWhite_ShortSleeveTINT", "Base.Trousers_Suit", "Base.Shoes_Fancy" },
            { "Base.Glasses_Normal", "Base.Cardigan_Beige", "Base.Trousers_SuitTEXTURE", "Base.Shoes_Black" },
        },
        Female = {
            { "Base.Glasses_Reading", "Base.Apron_WhiteTEXTURE", "Base.Shirt_FormalWhite", "Base.Skirt_Knees", "Base.Shoes_Black" },
            { "Base.Glasses_HalfMoon", "Base.Vest_WaistcoatTINT", "Base.Shirt_FormalTINT", "Base.Skirt_Long", "Base.Shoes_Black" },
            { "Base.Glasses_Cosmetic_Normal", "Base.Jumper_VNeck", "Base.Trousers_Suit", "Base.Shoes_Brown" },
            { "Base.Hat_Beret", "Base.Dress_Long_Straps", "Base.Shoes_Fancy" },
            { "Base.Glasses_Normal", "Base.Cardigan_Beige", "Base.Skirt_Normal", "Base.Shoes_Black" },
        }
}
