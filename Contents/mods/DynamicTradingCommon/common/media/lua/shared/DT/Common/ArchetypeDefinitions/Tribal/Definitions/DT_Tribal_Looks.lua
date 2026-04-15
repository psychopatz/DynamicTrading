require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}

DynamicTrading.ArchetypeLooks["Tribal"] = {
        Male = {
            { "Base.Hat_DeerHeadress", "Base.PonchoTarp", "Base.Shorts_Knees_DeerHide", "Base.Shoes_Twine" },
            { "Base.Hat_BoneMask", "Base.Cuirass_Bone", "Base.Trousers_DeerHide", "Base.Shoes_HideBoots" },
            { "Base.Hat_HideHat", "Base.Vest_DeerHide", "Base.Shorts_Knees_Hide", "Base.Shoes_CrudeLeatherFootwear" },
            { "Base.Necklace_Teeth", "Base.PonchoGarbageBag", "Base.Shorts_Knees_Garbage", "Base.Shoes_RagWrap" },
            { "Base.Hat_HockeyMask_Wood", "Base.Cuirass_Wood", "Base.Trousers_Crafted_Burlap", "Base.Shoes_BurlapWrap" },
        },
        Female = {
            { "Base.Hat_DeerHeadress", "Base.PonchoTarp", "Base.Skirt_Knees_DeerHide", "Base.Shoes_Twine" },
            { "Base.Hat_BoneMask", "Base.Cuirass_Bone", "Base.Skirt_Long_Hide", "Base.Shoes_HideBoots" },
            { "Base.Hat_HideHat", "Base.Vest_DeerHide", "Base.Skirt_Short_FaunHide", "Base.Shoes_CrudeLeatherFootwear" },
            { "Base.Necklace_Teeth", "Base.PonchoGarbageBag", "Base.Skirt_Knees_Garbage", "Base.Shoes_RagWrap" },
            { "Base.Hat_HockeyMask_Wood", "Base.Cuirass_Wood", "Base.Skirt_Long_Crafted_Burlap", "Base.Shoes_BurlapWrap" },
        }
}
