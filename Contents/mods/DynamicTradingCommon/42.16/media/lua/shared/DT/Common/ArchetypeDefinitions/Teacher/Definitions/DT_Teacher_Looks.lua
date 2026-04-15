require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}

DynamicTrading.ArchetypeLooks["Teacher"] = {
        Male = {
            { "Base.Glasses_Prescription", "Base.Jumper_DiamondPatternTINT", "Base.Shirt_FormalWhite", "Base.Trousers_SuitTEXTURE", "Base.Shoes_Brown" },
            { "Base.Glasses_Reading", "Base.Jacket_Suit", "Base.Shirt_FormalTINT", "Base.Trousers_Suit", "Base.Shoes_Black" },
            { "Base.Glasses_Normal", "Base.Jumper_VNeck", "Base.Tshirt_White", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_FlatCap", "Base.Cardigan_Beige", "Base.Trousers_Suit", "Base.Shoes_Brown" },
            { "Base.Glasses_Cosmetic_Normal", "Base.Shirt_FormalWhite_ShortSleeveTINT", "Base.Tie_Worn", "Base.Trousers_Black", "Base.Shoes_Black" },
        },
        Female = {
            { "Base.Glasses_Prescription", "Base.Jumper_DiamondPatternTINT", "Base.Shirt_FormalWhite", "Base.Skirt_Knees", "Base.Shoes_Brown" },
            { "Base.Glasses_Reading", "Base.Jacket_Suit", "Base.Shirt_FormalTINT", "Base.Trousers_Suit", "Base.Shoes_Black" },
            { "Base.Glasses_Normal", "Base.Jumper_VNeck", "Base.Tshirt_White", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_FlatCap", "Base.Cardigan_Beige", "Base.Skirt_Long", "Base.Shoes_Brown" },
            { "Base.Glasses_Cosmetic_Normal", "Base.Shirt_FormalWhite_ShortSleeveTINT", "Base.Tie_Worn", "Base.Skirt_Normal", "Base.Shoes_Black" },
        }
}
