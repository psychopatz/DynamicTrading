require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}

DynamicTrading.ArchetypeLooks["Welder"] = {
        Male = {
            { "Base.WeldingMask", "Base.Apron_Leather", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
            { "Base.Glasses_OldWeldingGoggles", "Base.Apron_Leather", "Base.Shirt_Workman", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.WeldingMask", "Base.Coveralls", "Base.Shoes_BlackBoots" },
            { "Base.Glasses_SafetyGoggles", "Base.Apron_Black", "Base.Tshirt_Black", "Base.Trousers_Black", "Base.Shoes_WorkBoots" },
            { "Base.Hat_Bandana", "Base.WeldingMask", "Base.Shirt_Denim", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.WeldingMask", "Base.Apron_Leather", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
            { "Base.Glasses_OldWeldingGoggles", "Base.Apron_Leather", "Base.Shirt_Workman", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.WeldingMask", "Base.Coveralls", "Base.Shoes_BlackBoots" },
            { "Base.Glasses_SafetyGoggles", "Base.Apron_Black", "Base.Tshirt_Black", "Base.Trousers_Black", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BandanaTied", "Base.WeldingMask", "Base.Shirt_Denim", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
        }
}
