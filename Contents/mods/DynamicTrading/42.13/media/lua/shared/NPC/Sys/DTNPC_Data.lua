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
    local hairModel = nil
    if brain.hairStyle and type(brain.hairStyle) == "string" then
        hairModel = brain.hairStyle
    else
        local hairStyles = getAllHairStyles(brain.isFemale)
        if hairStyles and hairStyles:size() > 0 then
            local hairIndex = brain.hairStyle or ZombRand(hairStyles:size()) -- brain.hairStyle here should be number if used
            if type(hairIndex) == "number" then
                hairModel = hairStyles:get(hairIndex)
            end
        end
    end

    if hairModel and hairModel ~= "" then
        humanVisual:setHairModel(hairModel)
    end

    -- 4. Apply Beard (Males only)
    if not brain.isFemale then
        local beardModel = nil
        if brain.beardStyle and type(brain.beardStyle) == "string" then
            beardModel = brain.beardStyle
        else
            local beardStyles = getAllBeardStyles()
            if beardStyles and beardStyles:size() > 0 then
                local beardIndex = brain.beardStyle or ZombRand(beardStyles:size())
                if type(beardIndex) == "number" then
                    beardModel = beardStyles:get(beardIndex)
                end
            end
        end
        
        if beardModel and beardModel ~= "" then
            humanVisual:setBeardModel(beardModel)
        end
    end

    -- 5. Set Hair/Beard Color
    local r = brain.hairColorR or 0.2
    local g = brain.hairColorG or 0.1
    local b = brain.hairColorB or 0.1
    
    if ImmutableColor then
        local color = ImmutableColor.new(r, g, b, 1)
        humanVisual:setHairColor(color)
        humanVisual:setBeardColor(color)
    end

    -- 6. Apply Clothing
    local outfit = brain.outfit
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



