-- ==============================================================================
-- DTNPC_Data.lua
-- Shared Logic: Defines the npcData structure, Wardrobe, and Visual overrides.
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
-- 2. DATA MANAGEMENT
-- ==============================================================================

function DTNPC.GetData(zombie)
    if not zombie then return nil end
    local modData = zombie:getModData()
    if not modData then return nil end
    
    -- Backward Compatibility: Migrate old "DTNPCBrain" to "DTNPC_Data"
    if modData.DTNPCBrain and not modData.DTNPC_Data then
        modData.DTNPC_Data = modData.DTNPCBrain
        modData.DTNPCBrain = nil
    end
    
    return modData.DTNPC_Data
end

-- Deprecated: Use DTNPC.GetData
function DTNPC.GetBrain(zombie)
    return DTNPC.GetData(zombie)
end

function DTNPC.AttachData(zombie, npcData)
    if not zombie or not npcData then return end
    local modData = zombie:getModData()
    if not modData then return end
    modData.DTNPC_Data = npcData
    modData.IsDTNPC = true
end

-- Deprecated: Use DTNPC.AttachData
function DTNPC.AttachBrain(zombie, npcData)
    DTNPC.AttachData(zombie, npcData)
end

function DTNPC.IsNPC(zombie)
    if not zombie then return false end
    local modData = zombie:getModData()
    return modData and modData.IsDTNPC == true
end

-- ==============================================================================
-- 3. VISUALS (THE COSTUME)
-- ==============================================================================

function DTNPC.ApplyVisuals(zombie, npcData)
    if not zombie or not npcData then return end

    local humanVisual = zombie:getHumanVisual()
    if not humanVisual then return end 

    -- 1. Reset everything
    zombie:getItemVisuals():clear()
    zombie:getWornItems():clear()

    -- 2. Apply Skin
    local skinTexture = npcData.isFemale and "FemaleBody01" or "MaleBody01"
    humanVisual:setSkinTextureName(skinTexture)
    
    -- 3. Apply Hair
    -- Resolve from archetype + lookSeed, fallback to saved hairStyle (backward compat)
    local hairModel = nil
    if npcData.hairStyle and type(npcData.hairStyle) == "string" then
        -- Backward compatibility: old npcDatas with explicit hairStyle
        hairModel = npcData.hairStyle
    elseif DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetHairStyleBySeed then
        -- New system: resolve deterministically from archetype + lookSeed
        hairModel = DT_NPC_Wardrobe.GetHairStyleBySeed(
            npcData.archetypeID or "General",
            npcData.isFemale,
            npcData.lookSeed or 1
        )
    end

    if hairModel and hairModel ~= "" then
        humanVisual:setHairModel(hairModel)
    end

    -- 4. Apply Beard (Males only)
    if not npcData.isFemale then
        local beardModel = nil
        if npcData.beardStyle and type(npcData.beardStyle) == "string" then
            -- Backward compatibility: old npcDatas with explicit beardStyle
            beardModel = npcData.beardStyle
        elseif DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetBeardStyleBySeed then
            -- New system: resolve deterministically from archetype + lookSeed
            beardModel = DT_NPC_Wardrobe.GetBeardStyleBySeed(
                npcData.archetypeID or "General",
                npcData.lookSeed or 1
            )
        end
        
        if beardModel and beardModel ~= "" then
            humanVisual:setBeardModel(beardModel)
        end
    end

    -- 5. Set Hair/Beard Color
    -- Resolve from archetype + lookSeed, fallback to saved RGB (backward compat)
    local r, g, b = 0.2, 0.1, 0.1
    if npcData.hairColorR and npcData.hairColorG and npcData.hairColorB then
        -- Backward compatibility: old npcDatas with explicit RGB
        r = npcData.hairColorR
        g = npcData.hairColorG
        b = npcData.hairColorB
    elseif DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetHairColorBySeed then
        -- New system: resolve deterministically from archetype + lookSeed
        local color = DT_NPC_Wardrobe.GetHairColorBySeed(
            npcData.archetypeID or "General",
            npcData.lookSeed or 1
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
    local outfit = npcData.outfit
    if (not outfit or type(outfit) ~= "table") and DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetOutfitBySeed then
        outfit = DT_NPC_Wardrobe.GetOutfitBySeed(npcData.archetypeID or "General", npcData.isFemale, npcData.lookSeed or 1)
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



