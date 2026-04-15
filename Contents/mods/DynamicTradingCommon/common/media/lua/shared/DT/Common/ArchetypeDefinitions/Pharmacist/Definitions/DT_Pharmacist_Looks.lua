require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}

DynamicTrading.ArchetypeLooks["Pharmacist"] = {
        Male = {
            { "Base.Glasses_SafetyGoggles", "Base.JacketLong_Doctor", "Base.Shirt_FormalWhite", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Glasses_Prescription", "Base.JacketLong_Doctor", "Base.Shirt_FormalBlue", "Base.Trousers_Suit", "Base.Shoes_Brown" },
            { "Base.Hat_SurgicalMask", "Base.Shirt_Scrubs", "Base.Trousers_Scrubs", "Base.Shoes_BlueTrainers" },
            { "Base.Glasses_Reading", "Base.Cardigan_Beige", "Base.Trousers_SuitTEXTURE", "Base.Shoes_Black" },
            { "Base.Glasses_Normal", "Base.JacketLong_Doctor", "Base.Tie_Full", "Base.Trousers_Suit", "Base.Shoes_Black" },
        },
        Female = {
            { "Base.Glasses_SafetyGoggles", "Base.JacketLong_Doctor", "Base.Shirt_FormalWhite", "Base.Skirt_Knees", "Base.Shoes_Black" },
            { "Base.Glasses_Prescription", "Base.JacketLong_Doctor", "Base.Shirt_FormalBlue", "Base.Skirt_Long", "Base.Shoes_Brown" },
            { "Base.Hat_SurgicalMask", "Base.Shirt_Scrubs", "Base.Trousers_Scrubs", "Base.Shoes_BlueTrainers" },
            { "Base.Glasses_Reading", "Base.Cardigan_Beige", "Base.Skirt_Normal", "Base.Shoes_Black" },
            { "Base.Glasses_Normal", "Base.JacketLong_Doctor", "Base.Tie_Full", "Base.Trousers_Suit", "Base.Shoes_Black" },
        }
}
