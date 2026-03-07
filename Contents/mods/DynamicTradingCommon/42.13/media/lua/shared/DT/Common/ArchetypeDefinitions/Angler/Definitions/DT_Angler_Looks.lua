require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}

DynamicTrading.ArchetypeLooks["Angler"] = {
        Male = {
            { "Base.Hat_BucketHatFishing", "Base.Vest_Hunting_Orange", "Base.Tshirt_White", "Base.Shorts_CamoGreenLong", "Base.Shoes_Wellies" },
            { "Base.Hat_BucketHat", "Base.Shirt_HawaiianTINT", "Base.Shorts_LongDenim", "Base.Shoes_FlipFlop" },
            { "Base.Hat_FishermanRainHat", "Base.Jacket_Padded", "Base.Trousers_Padded", "Base.Shoes_Wellies" },
            { "Base.Hat_BaseballCap", "Base.Vest_Hunting_Khaki", "Base.Shirt_Lumberjack", "Base.Trousers_JeanBaggy", "Base.Shoes_HikingBoots" },
            { "Base.Hat_Beany", "Base.Jumper_RoundNeck", "Base.Trousers_Crafted_Cotton", "Base.Shoes_Wellies" },
        },
        Female = {
            { "Base.Hat_BucketHatFishing", "Base.Vest_Hunting_Orange", "Base.Tshirt_White", "Base.Shorts_CamoGreenLong", "Base.Shoes_Wellies" },
            { "Base.Hat_BucketHat", "Base.Shirt_HawaiianTINT", "Base.Shorts_LongDenim", "Base.Shoes_FlipFlop" },
            { "Base.Hat_FishermanRainHat", "Base.Jacket_Padded", "Base.Trousers_Padded", "Base.Shoes_Wellies" },
            { "Base.Hat_BaseballCap", "Base.Vest_Hunting_Khaki", "Base.Shirt_Lumberjack", "Base.Trousers_JeanBaggy", "Base.Shoes_HikingBoots" },
            { "Base.Hat_Beany", "Base.Jumper_RoundNeck", "Base.Trousers_Crafted_Cotton", "Base.Shoes_Wellies" },
        }
}

-- Hair styles pool for Angler archetype
DynamicTrading.ArchetypeLooks["Angler"].HairStyles = {
    Male = {
        "Messy", "Short", "ShortHair", "Bald", "Balding", "Recede", 
        "CrewCut", "FlatTop", "Bob"
    },
    Female = {
        "Long", "LongHair", "PonyTail", "Bob", "Messy", "Short", 
        "ShortHair", "BunnyTail", "Pigtails"
    }
}

-- Beard styles pool for Angler archetype (male only)
DynamicTrading.ArchetypeLooks["Angler"].BeardStyles = {
    "Long", "Full", "Goatee", "Chops", "Moustache", nil, nil -- nils for clean-shaven variety
}

-- Hair colors pool for Angler archetype (RGB values)
DynamicTrading.ArchetypeLooks["Angler"].HairColors = {
    { r = 0.2, g = 0.1, b = 0.1 },   -- Dark brown
    { r = 0.4, g = 0.3, b = 0.2 },   -- Brown
    { r = 0.6, g = 0.5, b = 0.3 },   -- Light brown
    { r = 0.1, g = 0.1, b = 0.1 },   -- Black
    { r = 0.5, g = 0.5, b = 0.5 },   -- Gray
    { r = 0.8, g = 0.7, b = 0.4 },   -- Blonde
    { r = 0.6, g = 0.3, b = 0.2 },   -- Auburn
}
