require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}

DynamicTrading.ArchetypeLooks["General"] = {
        Male = {
            { "Base.Hat_BaseballCap", "Base.Tshirt_DefaultTEXTURE_TINT", "Base.Trousers_Denim", "Base.Shoes_Random" },
            { "Base.Hat_Beany", "Base.HoodieUP_WhiteTINT", "Base.Trousers_JeanBaggy", "Base.Shoes_TrainerTINT" },
            { "Base.Glasses_Aviators", "Base.Shirt_Lumberjack", "Base.Trousers_Black", "Base.Shoes_BlackBoots" },
            { "Base.Hat_VisorBlack", "Base.Vest_DefaultTEXTURE_TINT", "Base.Shorts_LongDenim", "Base.Shoes_Sandals" },
            { "Base.Hat_Cowboy", "Base.Tshirt_Rock", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_BaseballCap", "Base.Tshirt_DefaultTEXTURE_TINT", "Base.Trousers_Denim", "Base.Shoes_Random" },
            { "Base.Hat_Beany", "Base.HoodieDOWN_WhiteTINT", "Base.Skirt_Knees", "Base.Shoes_TrainerTINT" },
            { "Base.Glasses_Aviators", "Base.Shirt_Lumberjack", "Base.Trousers_Black", "Base.Shoes_BlackBoots" },
            { "Base.Dress_Normal", "Base.Hat_SummerHat", "Base.Shoes_Sandals" },
            { "Base.Shirt_CropTopTINT", "Base.Shorts_ShortDenim", "Base.Shoes_Random" },
        }
}

-- Hair styles pool for General archetype (diverse, balanced representation)
DynamicTrading.ArchetypeLooks["General"].HairStyles = {
    Male = {
        "Messy", "Short", "ShortHair", "Bald", "Balding", "Recede", 
        "CrewCut", "FlatTop", "Bob", "Long", "PonyTail", "Afro"
    },
    Female = {
        "Long", "LongHair", "PonyTail", "Bob", "Messy", "Short", 
        "ShortHair", "BunnyTail", "Pigtails", "Afro", "Rachel", "Bun"
    }
}

-- Beard styles pool for General archetype (male only, includes nil for clean-shaven)
DynamicTrading.ArchetypeLooks["General"].BeardStyles = {
    "Long", "Full", "Goatee", "Chops", "Moustache", "BeardOnly", 
    nil, nil, nil -- More clean-shaven for variety
}

-- Hair colors pool for General archetype (diverse, natural colors)
DynamicTrading.ArchetypeLooks["General"].HairColors = {
    { r = 0.1, g = 0.1, b = 0.1 },   -- Black
    { r = 0.2, g = 0.1, b = 0.1 },   -- Dark brown
    { r = 0.4, g = 0.3, b = 0.2 },   -- Brown
    { r = 0.6, g = 0.5, b = 0.3 },   -- Light brown
    { r = 0.8, g = 0.7, b = 0.4 },   -- Blonde
    { r = 0.6, g = 0.3, b = 0.2 },   -- Auburn/Ginger
    { r = 0.5, g = 0.5, b = 0.5 },   -- Gray
    { r = 0.7, g = 0.7, b = 0.7 },   -- Light gray/white
}
