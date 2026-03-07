-- ==============================================================================
-- DTNPC_Data.lua
-- Shared Logic: Defines the Brain structure, Wardrobe, and Visual overrides.
-- Works on both client and server.
-- ==============================================================================

DTNPC = DTNPC or {}

-- ==============================================================================
-- 1. WARDROBE DATABASE (Deprecated / Moved to DTNPC_Presets.lua)
-- ==============================================================================

-- Default walking speeds
DTNPC.DefaultWalkSpeed = 0.06
DTNPC.DefaultRunSpeed = 0.09


-- ==============================================================================
-- 2. BRAIN MANAGEMENT
-- ==============================================================================

function DTNPC.GetBrain(zombie)
    if not zombie then return nil end
    local modData = zombie:getModData()
    if not modData then return nil end
    return modData.DTNPCBrain
end

function DTNPC.AttachBrain(zombie, brainData)
    if not zombie or not brainData then return end
    local modData = zombie:getModData()
    if not modData then return end
    modData.DTNPCBrain = brainData
    modData.IsDTNPC = true
end

function DTNPC.IsNPC(zombie)
    if not zombie then return false end
    local modData = zombie:getModData()
    return modData and modData.IsDTNPC == true
end

-- ==============================================================================
-- 3. VISUALS (THE COSTUME)
-- ==============================================================================

function DTNPC.ApplyVisuals(zombie, brain)
    if not zombie or not brain then return end

    local humanVisual = zombie:getHumanVisual()
    if not humanVisual then return end 

    -- 1. Reset everything
    zombie:getItemVisuals():clear()
    zombie:getWornItems():clear()

    -- 2. Apply Skin
    local skinTexture = brain.isFemale and "FemaleBody01" or "MaleBody01"
    humanVisual:setSkinTextureName(skinTexture)
    
    -- 3. Apply Hair
    -- Resolve from archetype + lookSeed, fallback to saved hairStyle (backward compat)
    local hairModel = nil
    if brain.hairStyle and type(brain.hairStyle) == "string" then
        -- Backward compatibility: old brains with explicit hairStyle
        hairModel = brain.hairStyle
    elseif DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetHairStyleBySeed then
        -- New system: resolve deterministically from archetype + lookSeed
        hairModel = DT_NPC_Wardrobe.GetHairStyleBySeed(
            brain.archetypeID or "General",
            brain.isFemale,
            brain.lookSeed or 1
        )
    end

    if hairModel and hairModel ~= "" then
        humanVisual:setHairModel(hairModel)
    end

    -- 4. Apply Beard (Males only)
    if not brain.isFemale then
        local beardModel = nil
        if brain.beardStyle and type(brain.beardStyle) == "string" then
            -- Backward compatibility: old brains with explicit beardStyle
            beardModel = brain.beardStyle
        elseif DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetBeardStyleBySeed then
            -- New system: resolve deterministically from archetype + lookSeed
            beardModel = DT_NPC_Wardrobe.GetBeardStyleBySeed(
                brain.archetypeID or "General",
                brain.lookSeed or 1
            )
        end
        
        if beardModel and beardModel ~= "" then
            humanVisual:setBeardModel(beardModel)
        end
    end

    -- 5. Set Hair/Beard Color
    -- Resolve from archetype + lookSeed, fallback to saved RGB (backward compat)
    local r, g, b = 0.2, 0.1, 0.1
    if brain.hairColorR and brain.hairColorG and brain.hairColorB then
        -- Backward compatibility: old brains with explicit RGB
        r = brain.hairColorR
        g = brain.hairColorG
        b = brain.hairColorB
    elseif DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetHairColorBySeed then
        -- New system: resolve deterministically from archetype + lookSeed
        local color = DT_NPC_Wardrobe.GetHairColorBySeed(
            brain.archetypeID or "General",
            brain.lookSeed or 1
        )
        if color then
            r = color.r or 0.2
            g = color.g or 0.1
            b = color.b or 0.1
        end
    end
    
    if ImmutableColor then
        local color = ImmutableColor.new(r, g, b, 1)
        humanVisual:setHairColor(color)
        humanVisual:setBeardColor(color)
    end

    -- 6. Apply Clothing
    -- Prefer explicit outfit override (MVP/custom NPC), otherwise derive deterministic look from seed.
    local outfit = brain.outfit
    if (not outfit or type(outfit) ~= "table") and DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetOutfitBySeed then
        outfit = DT_NPC_Wardrobe.GetOutfitBySeed(brain.archetypeID or "General", brain.isFemale, brain.lookSeed or 1)
    end

    if outfit and type(outfit) == "table" then
        local itemVisuals = zombie:getItemVisuals()
        for _, itemType in ipairs(outfit) do
            if itemType and type(itemType) == "string" then
                local itemVisual = ItemVisual.new()
                itemVisual:setItemType(itemType)
                itemVisual:setClothingItemName(itemType)
                itemVisuals:add(itemVisual)
            end
        end
    end

    -- 7. Clean up
    humanVisual:removeBlood()
    humanVisual:removeDirt()
    
    -- 8. Refresh Model
    zombie:resetModelNextFrame()
end

-- ==============================================================================
-- 4. UTILITIES
-- ==============================================================================



