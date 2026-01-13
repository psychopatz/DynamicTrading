-- ==============================================================================
-- DTNPC_Presets.lua
-- Clothing Wardrobe for NPCs.
-- Contains valid Build 42 clothing items to ensure NPCs do not spawn naked.
-- ==============================================================================

DTNPCPresets = DTNPCPresets or {}

DTNPCPresets.Wardrobe = {
    -- 1. General (Casual Survivor)
    General = {
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
    },

    -- 2. Farmer
    Farmer = {
        Male = {
            { "Base.Hat_StrawHat", "Base.Dungarees", "Base.Shirt_Lumberjack", "Base.Shoes_Wellies" },
            { "Base.Hat_Cowboy", "Base.Shirt_Denim", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap", "Base.Tshirt_WhiteTINT", "Base.Dungarees", "Base.Shoes_Wellies" },
            { "Base.Hat_StrawHat", "Base.Shirt_Lumberjack_Green", "Base.Trousers_JeanBaggy", "Base.Shoes_HikingBoots" },
            { "Base.Hat_Cowboy_Brown", "Base.Vest_DefaultTEXTURE_TINT", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_StrawHat", "Base.Dungarees", "Base.Shirt_Lumberjack", "Base.Shoes_Wellies" },
            { "Base.Hat_Cowboy", "Base.Shirt_Denim", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BandanaTied", "Base.Tshirt_WhiteTINT", "Base.Dungarees", "Base.Shoes_Wellies" },
            { "Base.Hat_StrawHat", "Base.Shirt_Lumberjack_Green", "Base.Trousers_JeanBaggy", "Base.Shoes_HikingBoots" },
            { "Base.Hat_Cowboy_Brown", "Base.Shirt_CropTopTINT", "Base.Shorts_ShortDenim", "Base.Shoes_WorkBoots" },
        }
    },

    -- 3. Butcher
    Butcher = {
        Male = {
            { "Base.Hat_ChefHat", "Base.Apron_White", "Base.Tshirt_WhiteTINT", "Base.Trousers_Black", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BaseballCap", "Base.Apron_Black", "Base.Shirt_Workman", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Apron_WhiteTEXTURE", "Base.Shirt_FormalWhite", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Apron_BBQ", "Base.Tshirt_DefaultTEXTURE", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_PaperHat", "Base.Apron_White", "Base.Shirt_Lumberjack", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_ChefHat", "Base.Apron_White", "Base.Tshirt_WhiteTINT", "Base.Trousers_Black", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BaseballCap", "Base.Apron_Black", "Base.Shirt_Workman", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Apron_WhiteTEXTURE", "Base.Shirt_FormalWhite", "Base.Skirt_Knees", "Base.Shoes_Black" },
            { "Base.Apron_BBQ", "Base.Tshirt_DefaultTEXTURE", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_Bandana", "Base.Apron_White", "Base.Shirt_Lumberjack", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
        }
    },

    -- 4. Doctor
    Doctor = {
        Male = {
            { "Base.Hat_SurgicalMask", "Base.JacketLong_Doctor", "Base.Shirt_FormalWhite", "Base.Trousers_Suit", "Base.Shoes_Black" },
            { "Base.Hat_SurgicalCap", "Base.Shirt_Scrubs", "Base.Trousers_Scrubs", "Base.Shoes_BlueTrainers" },
            { "Base.Hat_HeadMirrorUP", "Base.JacketLong_Doctor", "Base.Shirt_FormalBlue", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Glasses_Reading", "Base.Tshirt_Scrubs", "Base.Trousers_Scrubs", "Base.Shoes_BlueTrainers" },
            { "Base.Hat_SurgicalMask", "Base.JacketLong_Doctor", "Base.Tie_Full", "Base.Trousers_SuitTEXTURE", "Base.Shoes_Black" },
        },
        Female = {
            { "Base.Hat_SurgicalMask", "Base.JacketLong_Doctor", "Base.Shirt_FormalWhite", "Base.Skirt_Knees", "Base.Shoes_Black" },
            { "Base.Hat_SurgicalCap", "Base.Shirt_Scrubs", "Base.Trousers_Scrubs", "Base.Shoes_BlueTrainers" },
            { "Base.Hat_HeadMirrorUP", "Base.JacketLong_Doctor", "Base.Shirt_FormalBlue", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Glasses_Reading", "Base.Tshirt_Scrubs", "Base.Trousers_Scrubs", "Base.Shoes_BlueTrainers" },
            { "Base.Hat_SurgicalMask", "Base.JacketLong_Doctor", "Base.Skirt_Long", "Base.Trousers_SuitTEXTURE", "Base.Shoes_Black" },
        }
    },

    -- 5. Mechanic
    Mechanic = {
        Male = {
            { "Base.Hat_BaseballCap_AmericanTire", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
            { "Base.Hat_Bandana", "Base.Shirt_Workman", "Base.Dungarees", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_Gas2Go", "Base.Tshirt_Gas2Go", "Base.Trousers_JeanBaggy", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BaseballCap_Fossoil", "Base.Tshirt_Fossoil", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_ThunderGas", "Base.Boilersuit_BlueRed", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_BaseballCap_AmericanTire", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BandanaTied", "Base.Shirt_Workman", "Base.Dungarees", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_Gas2Go", "Base.Tshirt_Gas2Go", "Base.Trousers_JeanBaggy", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BaseballCap_Fossoil", "Base.Tshirt_Fossoil", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_ThunderGas", "Base.Boilersuit_BlueRed", "Base.Shoes_WorkBoots" },
        }
    },

    -- 6. Survivalist
    Survivalist = {
        Male = {
            { "Base.Hat_BonnieHat_CamoGreen", "Base.PonchoGreen", "Base.Trousers_CamoGreen", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_BandanaMask_Green", "Base.Vest_Hunting_CamoGreen", "Base.Shirt_CamoGreen", "Base.Trousers_CamoGreen", "Base.Shoes_HikingBoots" },
            { "Base.Hat_Beany", "Base.Hoodie_HuntingCamo_UP", "Base.Vest_Hunting_Orange", "Base.Trousers_Padded_HuntingCamo", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_BicycleHelmet", "Base.Ghillie_Top", "Base.Ghillie_Trousers", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_ShemaghFull_Green", "Base.Jacket_ArmyCamoGreen", "Base.Trousers_ArmyService", "Base.Shoes_ArmyBoots" },
        },
        Female = {
            { "Base.Hat_BonnieHat_CamoGreen", "Base.PonchoGreen", "Base.Trousers_CamoGreen", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_BandanaMask_Green", "Base.Vest_Hunting_CamoGreen", "Base.Shirt_CamoGreen", "Base.Trousers_CamoGreen", "Base.Shoes_HikingBoots" },
            { "Base.Hat_Beany", "Base.Hoodie_HuntingCamo_UP", "Base.Vest_Hunting_Orange", "Base.Trousers_Padded_HuntingCamo", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_BicycleHelmet", "Base.Ghillie_Top", "Base.Ghillie_Trousers", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_ShemaghFull_Green", "Base.Jacket_ArmyCamoGreen", "Base.Trousers_ArmyService", "Base.Shoes_ArmyBoots" },
        }
    },

    -- 7. Gunrunner
    Gunrunner = {
        Male = {
            { "Base.Hat_Beret", "Base.Glasses_Aviators", "Base.Jacket_LeatherBlack", "Base.Trousers_Black", "Base.HolsterDouble", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BaseballCap_Black", "Base.Vest_BulletCivilian", "Base.Shirt_FormalWhite", "Base.Trousers_Suit", "Base.Shoes_Black" },
            { "Base.Glasses_Sun", "Base.Jacket_Leather", "Base.Trousers_DenimBlack", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Cowboy_Black", "Base.Coat_Leather", "Base.Trousers_Black", "Base.Shoes_CowboyBoots_Black" },
            { "Base.Hat_BandanaMask", "Base.Vest_Waistcoat", "Base.Shirt_Black", "Base.Trousers_Black", "Base.Shoes_BlackBoots" },
        },
        Female = {
            { "Base.Hat_Beret", "Base.Glasses_Aviators", "Base.Jacket_LeatherBlack", "Base.Trousers_Black", "Base.HolsterDouble", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BaseballCap_Black", "Base.Vest_BulletCivilian", "Base.Shirt_FormalWhite", "Base.Trousers_Suit", "Base.Shoes_Black" },
            { "Base.Glasses_Sun", "Base.Jacket_Leather", "Base.Trousers_DenimBlack", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Cowboy_Black", "Base.Coat_Leather", "Base.Skirt_Knees_Leather", "Base.Shoes_CowboyBoots_Black" },
            { "Base.Hat_BandanaMask", "Base.Vest_Waistcoat", "Base.Shirt_Black", "Base.Trousers_Black", "Base.Shoes_BlackBoots" },
        }
    },

    -- 8. Foreman
    Foreman = {
        Male = {
            { "Base.Hat_HardHat", "Base.Vest_Foreman", "Base.Shirt_Workman", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Hat_HardHat", "Base.Vest_HighViz", "Base.Tshirt_White", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_AmericanEats", "Base.Shirt_Lumberjack", "Base.Vest_HighViz", "Base.Trousers_Black", "Base.Shoes_WorkBoots" },
            { "Base.Hat_HardHat_Miner", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
            { "Base.Hat_EarMuff_Protectors", "Base.Shirt_Denim", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_HardHat", "Base.Vest_Foreman", "Base.Shirt_Workman", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Hat_HardHat", "Base.Vest_HighViz", "Base.Tshirt_White", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_AmericanEats", "Base.Shirt_Lumberjack", "Base.Vest_HighViz", "Base.Trousers_Black", "Base.Shoes_WorkBoots" },
            { "Base.Hat_HardHat_Miner", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
            { "Base.Hat_EarMuff_Protectors", "Base.Shirt_Denim", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
        }
    },

    -- 9. Scavenger
    Scavenger = {
        Male = {
            { "Base.Hat_Beany", "Base.PonchoGarbageBag", "Base.Trousers_JeanBaggy", "Base.Shoes_Slippers" },
            { "Base.Hat_GasMask", "Base.HoodieDOWN_WhiteTINT", "Base.Trousers_Crafted_Burlap", "Base.Shoes_Random" },
            { "Base.Hat_TinFoilHat", "Base.Tshirt_Rock", "Base.Shorts_LongDenim", "Base.Shoes_Sandals" },
            { "Base.Hat_BalaclavaFace", "Base.Jacket_PaddedDOWN", "Base.Trousers_Padded", "Base.Shoes_BlackBoots" },
            { "Base.Hat_HeadSack_Burlap", "Base.Shirt_Crafted_DenimRandom", "Base.Trousers_Crafted_DenimRandom", "Base.Shoes_TrainerTINT" },
        },
        Female = {
            { "Base.Hat_Beany", "Base.PonchoGarbageBag", "Base.Trousers_JeanBaggy", "Base.Shoes_Slippers" },
            { "Base.Hat_GasMask", "Base.HoodieDOWN_WhiteTINT", "Base.Skirt_Long_Crafted_Burlap", "Base.Shoes_Random" },
            { "Base.Hat_TinFoilHat", "Base.Tshirt_Rock", "Base.Shorts_LongDenim", "Base.Shoes_Sandals" },
            { "Base.Hat_BalaclavaFace", "Base.Jacket_PaddedDOWN", "Base.Trousers_Padded", "Base.Shoes_BlackBoots" },
            { "Base.Hat_HeadSack_Burlap", "Base.Dress_Knees_Crafted_DenimRandom", "Base.Shoes_TrainerTINT" },
        }
    },

    -- 10. Tailor
    Tailor = {
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
    },

    -- 11. Electrician
    Electrician = {
        Male = {
            { "Base.Hat_BaseballCap_AmeriglobeCom", "Base.Shirt_Workman", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_HardHat", "Base.Vest_HighViz", "Base.Jumper_RoundNeck", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Hat_EarMuffs", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
            { "Base.Glasses_SafetyGoggles", "Base.Shirt_Denim", "Base.Trousers_Black", "Base.Shoes_WorkBoots" },
            { "Base.Hat_Beany", "Base.Vest_Foreman", "Base.Tshirt_White", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_BaseballCap_AmeriglobeCom", "Base.Shirt_Workman", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_HardHat", "Base.Vest_HighViz", "Base.Jumper_RoundNeck", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Hat_EarMuffs", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
            { "Base.Glasses_SafetyGoggles", "Base.Shirt_Denim", "Base.Trousers_Black", "Base.Shoes_WorkBoots" },
            { "Base.Hat_Beany", "Base.Vest_Foreman", "Base.Tshirt_White", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
        }
    },

    -- 12. Welder
    Welder = {
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
    },

    -- 13. Chef
    Chef = {
        Male = {
            { "Base.Hat_ChefHat", "Base.Jacket_Chef", "Base.Trousers_Chef", "Base.Shoes_Black" },
            { "Base.Hat_BaseballCap_Spiffos", "Base.Apron_Spiffos", "Base.Tshirt_BusinessSpiffo", "Base.Trousers_Black", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_BaseballCap_PizzaWhirled", "Base.Apron_PizzaWhirled", "Base.Tshirt_PizzaWhirled", "Base.Trousers_JeanBaggy", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_FastFood_IceCream", "Base.Apron_IceCream", "Base.Tshirt_WhiteTINT", "Base.Trousers_WhiteTINT", "Base.Shoes_White" },
            { "Base.Hat_BaseballCap_JaysChicken", "Base.Apron_Jay", "Base.Tshirt_Red", "Base.Trousers_Black", "Base.Shoes_Black" },
        },
        Female = {
            { "Base.Hat_ChefHat", "Base.Jacket_Chef", "Base.Trousers_Chef", "Base.Shoes_Black" },
            { "Base.Hat_BaseballCap_Spiffos", "Base.Apron_Spiffos", "Base.Tshirt_BusinessSpiffo", "Base.Trousers_Black", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_BaseballCap_PizzaWhirled", "Base.Apron_PizzaWhirled", "Base.Tshirt_PizzaWhirled", "Base.Skirt_Knees", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_FastFood_IceCream", "Base.Apron_IceCream", "Base.Tshirt_WhiteTINT", "Base.Skirt_Short", "Base.Shoes_White" },
            { "Base.Hat_BaseballCap_JaysChicken", "Base.Apron_Jay", "Base.Tshirt_Red", "Base.Skirt_Normal", "Base.Shoes_Black" },
        }
    },

    -- 14. Herbalist
    Herbalist = {
        Male = {
            { "Base.Hat_SummerHat", "Base.Shirt_Lumberjack_Green", "Base.Shorts_CamoGreenLong", "Base.Shoes_HikingBoots" },
            { "Base.Hat_BucketHatFishing", "Base.Vest_Hunting_CamoGreen", "Base.Tshirt_CamoGreen", "Base.Trousers_CamoGreen", "Base.Shoes_Wellies" },
            { "Base.Hat_Bandana_Green", "Base.PonchoGreen", "Base.Shorts_LongDenim", "Base.Shoes_Sandals" },
            { "Base.Hat_StrawHat", "Base.Shirt_HawaiianGreen", "Base.Shorts_ShortDenim", "Base.Shoes_FlipFlop" },
            { "Base.Hat_Ranger", "Base.Shirt_Ranger", "Base.Trousers_Ranger", "Base.Shoes_HikingBoots" },
        },
        Female = {
            { "Base.Hat_SummerFlowerHat", "Base.Shirt_Lumberjack_Green", "Base.Shorts_CamoGreenLong", "Base.Shoes_HikingBoots" },
            { "Base.Hat_BucketHatFishing", "Base.Vest_Hunting_CamoGreen", "Base.Tshirt_CamoGreen", "Base.Skirt_Knees_Crafted_Cotton", "Base.Shoes_Wellies" },
            { "Base.Hat_Bandana_Green", "Base.PonchoGreen", "Base.Shorts_LongDenim", "Base.Shoes_Sandals" },
            { "Base.Hat_StrawHat", "Base.Dress_Long_Crafted_Cotton", "Base.Shoes_FlipFlop" },
            { "Base.Hat_Ranger", "Base.Shirt_Ranger", "Base.Trousers_Ranger", "Base.Shoes_HikingBoots" },
        }
    },

    -- 15. Smuggler
    Smuggler = {
        Male = {
            { "Base.Hat_Fedora", "Base.Glasses_Aviators", "Base.Shirt_HawaiianRed", "Base.Trousers_SuitWhite", "Base.Shoes_Fancy" },
            { "Base.Glasses_SunCheap", "Base.Jacket_LeatherBrown", "Base.Trousers_Denim", "Base.Shoes_Brown" },
            { "Base.Hat_Panama", "Base.Shirt_FormalWhite_ShortSleeveTINT", "Base.Trousers_Suit", "Base.Shoes_Fancy" },
            { "Base.Glasses_Macho", "Base.Vest_Waistcoat", "Base.Shirt_FormalWhite", "Base.Trousers_Black", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Beret", "Base.JacketLong_Black", "Base.Trousers_Suit", "Base.Shoes_Black" },
        },
        Female = {
            { "Base.Hat_Fedora", "Base.Glasses_Aviators", "Base.Shirt_HawaiianRed", "Base.Trousers_SuitWhite", "Base.Shoes_Fancy" },
            { "Base.Glasses_SunCheap", "Base.Jacket_LeatherBrown", "Base.Trousers_Denim", "Base.Shoes_Brown" },
            { "Base.Hat_Panama", "Base.Shirt_FormalWhite_ShortSleeveTINT", "Base.Skirt_Knees", "Base.Shoes_Fancy" },
            { "Base.Glasses_Macho", "Base.Vest_Waistcoat", "Base.Shirt_FormalWhite", "Base.Skirt_Long", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Beret", "Base.JacketLong_Black", "Base.Trousers_Suit", "Base.Shoes_Black" },
        }
    },

    -- 16. Librarian
    Librarian = {
        Male = {
            { "Base.Glasses_Reading", "Base.Jumper_VNeck", "Base.Shirt_FormalWhite", "Base.Trousers_Suit", "Base.Shoes_Brown" },
            { "Base.Glasses_HalfMoon", "Base.Cardigan_Beige", "Base.Trousers_SuitTEXTURE", "Base.Shoes_Slippers" },
            { "Base.Glasses_Normal_HornRimmed", "Base.Vest_WaistcoatTINT", "Base.Shirt_FormalTINT", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Glasses_Prescription", "Base.Jumper_DiamondPatternTINT", "Base.Trousers_Suit", "Base.Shoes_Fancy" },
            { "Base.Glasses_Round_Normal", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Tie_BowTieFull", "Base.Trousers_Suit", "Base.Shoes_Black" },
        },
        Female = {
            { "Base.Glasses_Reading", "Base.Jumper_VNeck", "Base.Shirt_FormalWhite", "Base.Skirt_Long", "Base.Shoes_Brown" },
            { "Base.Glasses_HalfMoon", "Base.Cardigan_Beige", "Base.Skirt_Normal", "Base.Shoes_Slippers" },
            { "Base.Glasses_Normal_HornRimmed", "Base.Vest_WaistcoatTINT", "Base.Shirt_FormalTINT", "Base.Skirt_Knees", "Base.Shoes_Black" },
            { "Base.Glasses_Prescription", "Base.Jumper_DiamondPatternTINT", "Base.Trousers_Suit", "Base.Shoes_Fancy" },
            { "Base.Glasses_Round_Normal", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Skirt_Long", "Base.Shoes_Black" },
        }
    },

    -- 17. Angler
    Angler = {
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
    },

    -- 18. Sheriff
    Sheriff = {
        Male = {
            { "Base.Hat_Sheriff", "Base.Jacket_Sheriff", "Base.Shirt_Sheriff", "Base.Trousers_Sheriff", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BaseballCap_Sheriff", "Base.Shirt_Sheriff", "Base.Trousers_Sheriff", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Sheriff", "Base.Tshirt_Sheriff", "Base.Trousers_Sheriff", "Base.Shoes_Black" },
            { "Base.Hat_Stetson", "Base.Shirt_Sheriff", "Base.Tie_Full", "Base.Trousers_Sheriff", "Base.Shoes_CowboyBoots_Black" },
            { "Base.Hat_Sheriff", "Base.Vest_BulletPolice", "Base.Shirt_Sheriff", "Base.Trousers_Sheriff", "Base.Shoes_BlackBoots" },
        },
        Female = {
            { "Base.Hat_Sheriff", "Base.Jacket_Sheriff", "Base.Shirt_Sheriff", "Base.Trousers_Sheriff", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BaseballCap_Sheriff", "Base.Shirt_Sheriff", "Base.Trousers_Sheriff", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Sheriff", "Base.Tshirt_Sheriff", "Base.Trousers_Sheriff", "Base.Shoes_Black" },
            { "Base.Hat_Stetson", "Base.Shirt_Sheriff", "Base.Tie_Full", "Base.Trousers_Sheriff", "Base.Shoes_CowboyBoots_Black" },
            { "Base.Hat_Sheriff", "Base.Vest_BulletPolice", "Base.Shirt_Sheriff", "Base.Trousers_Sheriff", "Base.Shoes_BlackBoots" },
        }
    },

    -- 19. Bartender
    Bartender = {
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
    },

    -- 20. Teacher
    Teacher = {
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
    },

    -- 21. Hunter
    Hunter = {
        Male = {
            { "Base.Hat_BaseballCap_HuntingCamo", "Base.Jacket_HuntingCamo", "Base.Trousers_HuntingCamo", "Base.Shoes_HikingBoots" },
            { "Base.Hat_Beany", "Base.Vest_Hunting_Orange", "Base.Shirt_Lumberjack", "Base.Trousers_Padded_HuntingCamo", "Base.Shoes_Wellies" },
            { "Base.Hat_BoonieHat_CamoGreen", "Base.Hoodie_HuntingCamo_DOWN", "Base.Trousers_CamoGreen", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_BandanaMask_Green", "Base.PonchoGreen", "Base.Vest_Hunting_Camo", "Base.Trousers_HuntingCamo", "Base.Shoes_HikingBoots" },
            { "Base.Hat_WinterHat", "Base.Jacket_Padded_HuntingCamo", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_BaseballCap_HuntingCamo", "Base.Jacket_HuntingCamo", "Base.Trousers_HuntingCamo", "Base.Shoes_HikingBoots" },
            { "Base.Hat_Beany", "Base.Vest_Hunting_Orange", "Base.Shirt_Lumberjack", "Base.Trousers_Padded_HuntingCamo", "Base.Shoes_Wellies" },
            { "Base.Hat_BoonieHat_CamoGreen", "Base.Hoodie_HuntingCamo_DOWN", "Base.Trousers_CamoGreen", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_BandanaMask_Green", "Base.PonchoGreen", "Base.Vest_Hunting_Camo", "Base.Trousers_HuntingCamo", "Base.Shoes_HikingBoots" },
            { "Base.Hat_WinterHat", "Base.Jacket_Padded_HuntingCamo", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
        }
    },

    -- 22. Quartermaster
    Quartermaster = {
        Male = {
            { "Base.Hat_BeretArmy", "Base.Shirt_Green", "Base.Trousers_ArmyService", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_BaseballCapArmy", "Base.Tshirt_ArmyGreen", "Base.Trousers_CamoGreen", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_PeakedCapArmy", "Base.Jacket_ArmyOliveDrab", "Base.Trousers_OliveDrab", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BaseballCap_Green", "Base.Vest_Hunting_Khaki", "Base.Tshirt_OliveDrab", "Base.Shorts_OliveDrabLong", "Base.Shoes_WorkBoots" },
            { "Base.Hat_Army", "Base.Jumper_RoundNeck", "Base.Trousers_ArmyService", "Base.Shoes_BlackBoots" },
        },
        Female = {
            { "Base.Hat_BeretArmy", "Base.Shirt_Green", "Base.Trousers_ArmyService", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_BaseballCapArmy", "Base.Tshirt_ArmyGreen", "Base.Trousers_CamoGreen", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_PeakedCapArmy", "Base.Jacket_ArmyOliveDrab", "Base.Trousers_OliveDrab", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BaseballCap_Green", "Base.Vest_Hunting_Khaki", "Base.Tshirt_OliveDrab", "Base.Shorts_OliveDrabLong", "Base.Shoes_WorkBoots" },
            { "Base.Hat_Army", "Base.Jumper_RoundNeck", "Base.Trousers_ArmyService", "Base.Shoes_BlackBoots" },
        }
    },

    -- 23. Musician
    Musician = {
        Male = {
            { "Base.Glasses_Sun", "Base.Jacket_Leather_Punk", "Base.Tshirt_Rock", "Base.Trousers_Denim_Punk", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Bandana", "Base.Tshirt_Metal", "Base.Shorts_LongDenim_Punk", "Base.Shoes_Black" },
            { "Base.Hat_Fedora", "Base.Tshirt_BluesCountry", "Base.Vest_Waistcoat", "Base.Trousers_JeanBaggy", "Base.Shoes_CowboyBoots_Brown" },
            { "Base.Glasses_Aviators", "Base.Jacket_Varsity", "Base.Tshirt_Indie", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_Beany", "Base.Tshirt_Punk", "Base.Trousers_LeatherBlack", "Base.Shoes_BlackBoots" },
        },
        Female = {
            { "Base.Glasses_Sun", "Base.Jacket_Leather_Punk", "Base.Tshirt_Rock", "Base.Skirt_Mini_Denim", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BandanaTied", "Base.Tshirt_Metal", "Base.Shorts_LongDenim_Punk", "Base.Shoes_Black" },
            { "Base.Hat_Fedora", "Base.Tshirt_BluesCountry", "Base.Vest_Waistcoat", "Base.Skirt_Knees", "Base.Shoes_CowboyBoots_Brown" },
            { "Base.Glasses_Aviators", "Base.Jacket_Varsity", "Base.Tshirt_Indie", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_Beany", "Base.Tshirt_Punk", "Base.Trousers_LeatherBlack", "Base.Shoes_BlackBoots" },
        }
    },

    -- 24. Janitor
    Janitor = {
        Male = {
            { "Base.Hat_BaseballCap", "Base.Boilersuit_BlueRed", "Base.Shoes_WorkBoots" },
            { "Base.Hat_Bandana", "Base.Apron_Blue", "Base.Tshirt_White", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_Beany", "Base.Shirt_Workman", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_Blue", "Base.Vest_HighViz", "Base.Tshirt_Blue", "Base.Trousers_NavyBlue", "Base.Shoes_Black" },
            { "Base.Hat_KnitHat", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_BaseballCap", "Base.Boilersuit_BlueRed", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BandanaTied", "Base.Apron_Blue", "Base.Tshirt_White", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_Beany", "Base.Shirt_Workman", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_Blue", "Base.Vest_HighViz", "Base.Tshirt_Blue", "Base.Trousers_NavyBlue", "Base.Shoes_Black" },
            { "Base.Hat_KnitHat", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
        }
    },

    -- 25. Carpenter
    Carpenter = {
        Male = {
            { "Base.Hat_HardHat", "Base.Shirt_Lumberjack", "Base.Apron_Leather", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Hat_DustMask", "Base.Shirt_Workman", "Base.Dungarees", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_BodyChisel", "Base.Tshirt_White", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_EarMuff_Protectors", "Base.Shirt_Lumberjack_TINT", "Base.Trousers_Padded", "Base.Shoes_HikingBoots" },
            { "Base.Hat_HardHat", "Base.Vest_Foreman", "Base.Tshirt_White", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_HardHat", "Base.Shirt_Lumberjack", "Base.Apron_Leather", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Hat_DustMask", "Base.Shirt_Workman", "Base.Dungarees", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_BodyChisel", "Base.Tshirt_White", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_EarMuff_Protectors", "Base.Shirt_Lumberjack_TINT", "Base.Trousers_Padded", "Base.Shoes_HikingBoots" },
            { "Base.Hat_HardHat", "Base.Vest_Foreman", "Base.Tshirt_White", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
        }
    },

    -- 26. Pawnbroker
    Pawnbroker = {
        Male = {
            { "Base.Hat_Fedora", "Base.Glasses_Macho", "Base.Vest_WaistcoatTINT", "Base.Shirt_FormalTINT", "Base.Trousers_Suit", "Base.Shoes_Fancy" },
            { "Base.Glasses_SunCheap", "Base.Shirt_HawaiianTINT", "Base.Trousers_Black", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Visor_WhiteTINT", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Trousers_SuitTEXTURE", "Base.Shoes_TrainerTINT" },
            { "Base.Necklace_Gold", "Base.Tshirt_Sport", "Base.Jacket_Shellsuit_Black", "Base.Trousers_Shellsuit_Black", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_Trilby", "Base.Vest_Waistcoat", "Base.Shirt_FormalWhite", "Base.Trousers_Black", "Base.Shoes_Black" },
        },
        Female = {
            { "Base.Hat_Fedora", "Base.Glasses_Macho", "Base.Vest_WaistcoatTINT", "Base.Shirt_FormalTINT", "Base.Skirt_Knees", "Base.Shoes_Fancy" },
            { "Base.Glasses_SunCheap", "Base.Shirt_HawaiianTINT", "Base.Trousers_Black", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Visor_WhiteTINT", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Skirt_Long", "Base.Shoes_TrainerTINT" },
            { "Base.Necklace_Gold", "Base.Tshirt_Sport", "Base.Jacket_Shellsuit_Black", "Base.Trousers_Shellsuit_Black", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_Trilby", "Base.Vest_Waistcoat", "Base.Shirt_FormalWhite", "Base.Trousers_Black", "Base.Shoes_Black" },
        }
    },

    -- 27. Pyro
    Pyro = {
        Male = {
            { "Base.Hat_Fireman", "Base.Jacket_Fireman", "Base.Trousers_Fireman", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_BaseballCap_FireDept", "Base.Tshirt_Profession_FiremanRed", "Base.Trousers_Fireman", "Base.Shoes_BlackBoots" },
            { "Base.Hat_GasMask", "Base.Boilersuit_Yellow", "Base.Shoes_Wellies" },
            { "Base.Hat_BandanaMask", "Base.Hoodie_HuntingCamo_UP", "Base.Vest_HighViz", "Base.Trousers_Padded", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Fireman", "Base.Tshirt_Profession_FiremanBlue", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_Fireman", "Base.Jacket_Fireman", "Base.Trousers_Fireman", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_BaseballCap_FireDept", "Base.Tshirt_Profession_FiremanRed", "Base.Trousers_Fireman", "Base.Shoes_BlackBoots" },
            { "Base.Hat_GasMask", "Base.Boilersuit_Yellow", "Base.Shoes_Wellies" },
            { "Base.Hat_BandanaMask", "Base.Hoodie_HuntingCamo_UP", "Base.Vest_HighViz", "Base.Trousers_Padded", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Fireman", "Base.Tshirt_Profession_FiremanBlue", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
        }
    },

    -- 28. Athlete
    Athlete = {
        Male = {
            { "Base.Hat_Sweatband", "Base.Tshirt_Sport", "Base.Shorts_ShortSport", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_BaseballCap_LouisvilleBruiser", "Base.Jacket_Varsity", "Base.Trousers_Denim", "Base.Shoes_Sneakers" },
            { "Base.Hat_FootballHelmet", "Base.Football_Jersey_Blue", "Base.Shorts_FootballPants", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_BaseballCap", "Base.Hoodie_WhiteTINT", "Base.Shorts_LongSport", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_VisorRed", "Base.Vest_DefaultTEXTURE_TINT", "Base.Shorts_ShortSport", "Base.Shoes_TrainerTINT" },
        },
        Female = {
            { "Base.Hat_Sweatband", "Base.Tshirt_Sport", "Base.Shorts_ShortSport", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_BaseballCap_LouisvilleBruiser", "Base.Jacket_Varsity", "Base.Trousers_Denim", "Base.Shoes_Sneakers" },
            { "Base.Hat_FootballHelmet", "Base.Football_Jersey_Blue", "Base.Shorts_FootballPants", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_BaseballCap", "Base.Hoodie_WhiteTINT", "Base.Shorts_LongSport", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_VisorRed", "Base.Vest_DefaultTEXTURE_TINT", "Base.Shorts_ShortSport", "Base.Shoes_TrainerTINT" },
        }
    },

    -- 29. Pharmacist
    Pharmacist = {
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
    },

    -- 30. Hiker
    Hiker = {
        Male = {
            { "Base.Hat_Visor_WhiteTINT", "Base.Shirt_Lumberjack", "Base.Shorts_CamoGreenLong", "Base.Shoes_HikingBoots" },
            { "Base.Hat_Beany", "Base.Vest_Hunting_Orange", "Base.Hoodie_HuntingCamo_DOWN", "Base.Trousers_Padded", "Base.Shoes_HikingBoots" },
            { "Base.Hat_BoonieHat_CamoGreen", "Base.PonchoGreen", "Base.Trousers_CamoGreen", "Base.Shoes_HikingBoots" },
            { "Base.Glasses_Sun", "Base.Tshirt_CamoGreen", "Base.Shorts_LongDenim", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_WinterHat", "Base.Jacket_Padded", "Base.Trousers_JeanBaggy", "Base.Shoes_HikingBoots" },
        },
        Female = {
            { "Base.Hat_Visor_WhiteTINT", "Base.Shirt_Lumberjack", "Base.Shorts_CamoGreenLong", "Base.Shoes_HikingBoots" },
            { "Base.Hat_Beany", "Base.Vest_Hunting_Orange", "Base.Hoodie_HuntingCamo_DOWN", "Base.Trousers_Padded", "Base.Shoes_HikingBoots" },
            { "Base.Hat_BoonieHat_CamoGreen", "Base.PonchoGreen", "Base.Trousers_CamoGreen", "Base.Shoes_HikingBoots" },
            { "Base.Glasses_Sun", "Base.Tshirt_CamoGreen", "Base.Shorts_LongDenim", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_WinterHat", "Base.Jacket_Padded", "Base.Trousers_JeanBaggy", "Base.Shoes_HikingBoots" },
        }
    },

    -- 31. Burglar
    Burglar = {
        Male = {
            { "Base.Hat_BalaclavaFace", "Base.HoodieUP_WhiteTINT", "Base.Trousers_Black", "Base.Gloves_LeatherGlovesBlack", "Base.Shoes_Sneakers" },
            { "Base.Hat_Beany", "Base.Jacket_LeatherBlack", "Base.Trousers_DenimBlack", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BandanaMask", "Base.HoodieDOWN_WhiteTINT", "Base.Trousers_JeanBaggy", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_BaseballCap_Black", "Base.Jumper_RoundNeck", "Base.Trousers_Black", "Base.Gloves_FingerlessLeatherGloves_Black", "Base.Shoes_Sneakers" },
            { "Base.Hat_WoolyHat", "Base.PonchoGarbageBag", "Base.Trousers_DenimBlack", "Base.Shoes_BlackBoots" },
        },
        Female = {
            { "Base.Hat_BalaclavaFace", "Base.HoodieUP_WhiteTINT", "Base.Trousers_Black", "Base.Gloves_LeatherGlovesBlack", "Base.Shoes_Sneakers" },
            { "Base.Hat_Beany", "Base.Jacket_LeatherBlack", "Base.Trousers_DenimBlack", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BandanaMask", "Base.HoodieDOWN_WhiteTINT", "Base.Trousers_JeanBaggy", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_BaseballCap_Black", "Base.Jumper_RoundNeck", "Base.Trousers_Black", "Base.Gloves_FingerlessLeatherGloves_Black", "Base.Shoes_Sneakers" },
            { "Base.Hat_WoolyHat", "Base.PonchoGarbageBag", "Base.Trousers_DenimBlack", "Base.Shoes_BlackBoots" },
        }
    },

    -- 32. Blacksmith
    Blacksmith = {
        Male = {
            { "Base.WeldingMask", "Base.Apron_Leather", "Base.Tshirt_WhiteTINT", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Glasses_OldWeldingGoggles", "Base.Gloves_LeatherGloves", "Base.Shirt_Workman", "Base.Dungarees", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Bandana", "Base.Vest_Leather", "Base.Trousers_LeatherCrafted", "Base.Shoes_WorkBoots" },
            { "Base.Hat_HardHat", "Base.Apron_Black", "Base.Tshirt_Black", "Base.Trousers_Denim", "Base.Shoes_BlackBoots" },
            { "Base.Glasses_SafetyGoggles", "Base.Boilersuit", "Base.Apron_Leather", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.WeldingMask", "Base.Apron_Leather", "Base.Tshirt_WhiteTINT", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Glasses_OldWeldingGoggles", "Base.Gloves_LeatherGloves", "Base.Shirt_Workman", "Base.Dungarees", "Base.Shoes_BlackBoots" },
            { "Base.Hat_BandanaTied", "Base.Vest_Leather", "Base.Trousers_LeatherCrafted", "Base.Shoes_WorkBoots" },
            { "Base.Hat_HardHat", "Base.Apron_Black", "Base.Tshirt_Black", "Base.Trousers_Denim", "Base.Shoes_BlackBoots" },
            { "Base.Glasses_SafetyGoggles", "Base.Boilersuit", "Base.Apron_Leather", "Base.Shoes_WorkBoots" },
        }
    },

    -- 33. Tribal
    Tribal = {
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
    },

    -- 34. Painter
    Painter = {
        Male = {
            { "Base.Hat_NewspaperHat", "Base.Boilersuit_White", "Base.Shoes_Sneakers" },
            { "Base.Hat_DustMask", "Base.Apron_WhiteTEXTURE", "Base.Tshirt_WhiteTINT", "Base.Trousers_WhiteTEXTURE", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_BaseballCap", "Base.Shirt_Workman", "Base.Dungarees", "Base.Shoes_WorkBoots" },
            { "Base.Hat_Beany", "Base.Vest_HighViz", "Base.Tshirt_DefaultTEXTURE", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Hat_Bandana", "Base.Shirt_Lumberjack", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
        },
        Female = {
            { "Base.Hat_NewspaperHat", "Base.Boilersuit_White", "Base.Shoes_Sneakers" },
            { "Base.Hat_DustMask", "Base.Apron_WhiteTEXTURE", "Base.Tshirt_WhiteTINT", "Base.Trousers_WhiteTEXTURE", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_BaseballCap", "Base.Shirt_Workman", "Base.Dungarees", "Base.Shoes_WorkBoots" },
            { "Base.Hat_Beany", "Base.Vest_HighViz", "Base.Tshirt_DefaultTEXTURE", "Base.Trousers_JeanBaggy", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BandanaTied", "Base.Shirt_Lumberjack", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
        }
    },

    -- 35. RoadWarrior
    RoadWarrior = {
        Male = {
            { "Base.Hat_CrashHelmetFULL_Spiked", "Base.Shoulderpads_FootballOnTop_Spiked", "Base.Jacket_Leather_Punk", "Base.Trousers_Denim_Punk", "Base.Shoes_BlackBoots" },
            { "Base.Hat_HockeyMask", "Base.Vest_Leather_Biker", "Base.Trousers_LeatherBlack", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_RiotHelmet", "Base.Vest_BulletPolice", "Base.Boilersuit_Prisoner", "Base.Shoes_BlackBoots" },
            { "Base.Hat_HockeyHelmet", "Base.Shoulderpads_IceHockeyOnTop", "Base.Tshirt_Rock", "Base.Trousers_JeanBaggy_Punk", "Base.Shoes_BlackBoots" },
            { "Base.Hat_FootballHelmet", "Base.Shoulderpads_Football", "Base.Vest_Leather", "Base.Trousers_Padded", "Base.Shoes_BlackBoots" },
        },
        Female = {
            { "Base.Hat_CrashHelmetFULL_Spiked", "Base.Shoulderpads_FootballOnTop_Spiked", "Base.Jacket_Leather_Punk", "Base.Trousers_Denim_Punk", "Base.Shoes_BlackBoots" },
            { "Base.Hat_HockeyMask", "Base.Vest_Leather_Biker", "Base.Trousers_LeatherBlack", "Base.Shoes_ArmyBoots" },
            { "Base.Hat_RiotHelmet", "Base.Vest_BulletPolice", "Base.Boilersuit_Prisoner", "Base.Shoes_BlackBoots" },
            { "Base.Hat_HockeyHelmet", "Base.Shoulderpads_IceHockeyOnTop", "Base.Tshirt_Rock", "Base.Skirt_Mini_Denim", "Base.Shoes_BlackBoots" },
            { "Base.Hat_FootballHelmet", "Base.Shoulderpads_Football", "Base.Vest_Leather", "Base.Trousers_Padded", "Base.Shoes_BlackBoots" },
        }
    },

    -- 36. Designer
    Designer = {
        Male = {
            { "Base.Hat_Beret", "Base.Glasses_JackieO", "Base.Jumper_PoloNeck", "Base.Trousers_SuitTEXTURE", "Base.Shoes_Fancy" },
            { "Base.Glasses_Cosmetic_Normal_HornRimmed", "Base.Scarf_White", "Base.Shirt_FormalBlack", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Hat_Fedora", "Base.Vest_WaistcoatTINT", "Base.Shirt_FormalTINT", "Base.Trousers_Suit", "Base.Shoes_Fancy" },
            { "Base.Glasses_Sun", "Base.JacketLong_Black", "Base.Tshirt_White", "Base.Trousers_DenimBlack", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Panama", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Trousers_SuitWhite", "Base.Shoes_Fancy" },
        },
        Female = {
            { "Base.Hat_Beret", "Base.Glasses_JackieO", "Base.Jumper_PoloNeck", "Base.Skirt_Long", "Base.Shoes_Fancy" },
            { "Base.Glasses_Cosmetic_Normal_HornRimmed", "Base.Scarf_White", "Base.Shirt_FormalBlack", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Hat_Fedora", "Base.Vest_WaistcoatTINT", "Base.Shirt_FormalTINT", "Base.Skirt_Knees", "Base.Shoes_Fancy" },
            { "Base.Glasses_Sun", "Base.JacketLong_Black", "Base.Tshirt_White", "Base.Trousers_DenimBlack", "Base.Shoes_BlackBoots" },
            { "Base.Hat_Panama", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Trousers_SuitWhite", "Base.Shoes_Fancy" },
        }
    },

    -- 37. Office
    Office = {
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
    },

    -- 38. Geek
    Geek = {
        Male = {
            { "Base.Glasses_Normal_HornRimmed", "Base.Tshirt_SpiffoDECAL", "Base.Shorts_LongDenim", "Base.Shoes_Sneakers" },
            { "Base.Glasses_Cosmetic_Normal", "Base.Tshirt_IndieStoneDECAL", "Base.Trousers_JeanBaggy", "Base.Shoes_TrainerTINT" },
            { "Base.Glasses_Reading", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Tie_BowTieFull", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Hat_Beany", "Base.Tshirt_Rock", "Base.HoodieUP_WhiteTINT", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
            { "Base.Glasses_Prescription", "Base.Tshirt_SuperColor", "Base.Shorts_LongSport", "Base.Shoes_Sandals" },
        },
        Female = {
            { "Base.Glasses_Normal_HornRimmed", "Base.Tshirt_SpiffoDECAL", "Base.Shorts_LongDenim", "Base.Shoes_Sneakers" },
            { "Base.Glasses_Cosmetic_Normal", "Base.Tshirt_IndieStoneDECAL", "Base.Trousers_JeanBaggy", "Base.Shoes_TrainerTINT" },
            { "Base.Glasses_Reading", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Tie_BowTieFull", "Base.Skirt_Knees", "Base.Shoes_Black" },
            { "Base.Hat_Beany", "Base.Tshirt_Rock", "Base.HoodieUP_WhiteTINT", "Base.Trousers_Denim", "Base.Shoes_TrainerTINT" },
            { "Base.Glasses_Prescription", "Base.Tshirt_SuperColor", "Base.Shorts_LongSport", "Base.Shoes_Sandals" },
        }
    },

    -- 39. Brewer
    Brewer = {
        Male = {
            { "Base.Hat_BaseballCap_BoxpopBrewery", "Base.Apron_Black", "Base.Tshirt_Black", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_KnoxDistillery", "Base.Shirt_Lumberjack", "Base.Dungarees", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_ScarletOakDistillery", "Base.Tshirt_WhiteTINT", "Base.Trousers_JeanBaggy", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_VisorBlack", "Base.Apron_White", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Trousers_Black", "Base.Shoes_Black" },
            { "Base.Hat_Bandana", "Base.Vest_Foreman", "Base.Shirt_Workman", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_BaseballCap_BoxpopBrewery", "Base.Apron_Black", "Base.Tshirt_Black", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_KnoxDistillery", "Base.Shirt_Lumberjack", "Base.Dungarees", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_ScarletOakDistillery", "Base.Tshirt_WhiteTINT", "Base.Trousers_JeanBaggy", "Base.Shoes_TrainerTINT" },
            { "Base.Hat_VisorBlack", "Base.Apron_White", "Base.Shirt_FormalWhite_ShortSleeve", "Base.Skirt_Knees", "Base.Shoes_Black" },
            { "Base.Hat_BandanaTied", "Base.Vest_Foreman", "Base.Shirt_Workman", "Base.Trousers_Denim", "Base.Shoes_WorkBoots" },
        }
    },

    -- 40. Demo (Demolition/Construction)
    Demo = {
        Male = {
            { "Base.Hat_HardHat", "Base.Vest_HighViz", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
            { "Base.Hat_EarMuffs", "Base.Vest_Foreman", "Base.Shirt_Denim", "Base.Dungarees", "Base.Shoes_WorkBoots" },
            { "Base.Hat_SafetyGoggles", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_BodyChisel", "Base.Tshirt_White", "Base.Trousers_JeanBaggy", "Base.Shoes_BlackBoots" },
            { "Base.Hat_DustMask", "Base.Vest_HighViz", "Base.Shirt_Lumberjack", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
        },
        Female = {
            { "Base.Hat_HardHat", "Base.Vest_HighViz", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
            { "Base.Hat_EarMuffs", "Base.Vest_Foreman", "Base.Shirt_Denim", "Base.Dungarees", "Base.Shoes_WorkBoots" },
            { "Base.Hat_SafetyGoggles", "Base.Boilersuit", "Base.Shoes_WorkBoots" },
            { "Base.Hat_BaseballCap_BodyChisel", "Base.Tshirt_White", "Base.Trousers_JeanBaggy", "Base.Shoes_BlackBoots" },
            { "Base.Hat_DustMask", "Base.Vest_HighViz", "Base.Shirt_Lumberjack", "Base.Trousers_Padded", "Base.Shoes_WorkBoots" },
        }
    }
}

function DTNPCPresets.GetRandomOutfit(category, isFemale)
    local cat = category or "General"
    local gender = isFemale and "Female" or "Male"
    
    local pool = DTNPCPresets.Wardrobe[cat] and DTNPCPresets.Wardrobe[cat][gender]
    
    if not pool or #pool == 0 then
        -- Fallback to General if category missing
        pool = DTNPCPresets.Wardrobe["General"] and DTNPCPresets.Wardrobe["General"][gender]
        print("[DTNPC] Error: No valid outfit found for category " .. cat .. " and gender " .. gender .. ". Fallback to General.")
    end
    
    if pool and #pool > 0 then
        return pool[ZombRand(#pool) + 1]
    end
     -- Ultimate fallback
    print("[DTNPC]Error: No valid outfit found for category ")
    return { "Base.Tshirt_DefaultTEXTURE", "Base.Trousers_Denim", "Base.Shoes_Random" }
end
