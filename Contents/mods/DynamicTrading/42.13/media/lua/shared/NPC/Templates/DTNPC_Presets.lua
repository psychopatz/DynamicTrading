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
