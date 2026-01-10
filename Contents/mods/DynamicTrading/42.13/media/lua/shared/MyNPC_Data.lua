-- ==============================================================================
-- MyNPC_Data.lua
-- Shared Logic: Defines the Brain structure and Visual overrides.
-- FIXED: Removed strict validation on Hair/Beard styles to prevent B42 crashes.
-- ==============================================================================

MyNPC = MyNPC or {}

-- ==============================================================================
-- 1. BRAIN MANAGEMENT
-- ==============================================================================

function MyNPC.GetBrain(zombie)
    if not zombie then return nil end
    local modData = zombie:getModData()
    return modData.MyNPCBrain
end

function MyNPC.AttachBrain(zombie, brainData)
    local modData = zombie:getModData()
    modData.MyNPCBrain = brainData
    modData.IsMyNPC = true
end

-- ==============================================================================
-- 2. VISUALS (THE COSTUME)
-- ==============================================================================

function MyNPC.ApplyVisuals(zombie, brain)
    if not zombie then return end

    local humanVisual = zombie:getHumanVisual()
    if not humanVisual then return end 

    -- 1. Reset everything
    zombie:getItemVisuals():clear()
    zombie:getWornItems():clear()

    -- 2. Apply Skin
    local skinTexture = brain.isFemale and "FemaleBody01" or "MaleBody01"
    humanVisual:setSkinTextureName(skinTexture)
    
    -- 3. Apply Hair (Crash-Proof Version)
    local hairStyles = getAllHairStyles(brain.isFemale)
    if hairStyles and hairStyles:size() > 0 then
        -- Pick a random hair index
        local hairIndex = brain.hairStyle or ZombRand(hairStyles:size())
        local styleId = hairStyles:get(hairIndex)
        
        -- Directly set the model if ID is valid string
        if styleId and styleId ~= "" then
            humanVisual:setHairModel(styleId)
        end
    end

    -- 4. Apply Beard (Males only)
    if not brain.isFemale then
        local beardStyles = getAllBeardStyles()
        if beardStyles and beardStyles:size() > 0 then
            local beardIndex = brain.beardStyle or ZombRand(beardStyles:size())
            local styleId = beardStyles:get(beardIndex)
            
            if styleId and styleId ~= "" then
                humanVisual:setBeardModel(styleId)
            end
        end
    end

    -- 5. Set Hair/Beard Color
    local r = brain.hairColorR or 0.2
    local g = brain.hairColorG or 0.1
    local b = brain.hairColorB or 0.1
    
    -- Safety check for ImmutableColor
    if ImmutableColor then
        local color = ImmutableColor.new(r, g, b, 1)
        humanVisual:setHairColor(color)
        humanVisual:setBeardColor(color)
    end

    -- 6. Apply Clothing
    local itemVisuals = zombie:getItemVisuals()
    local outfit = brain.outfit or {
        "Base.Tshirt_White",
        "Base.Jeans_Black",
        "Base.Shoes_Sneakers"
    }

    for _, itemType in ipairs(outfit) do
        local itemVisual = ItemVisual.new()
        itemVisual:setItemType(itemType)
        itemVisual:setClothingItemName(itemType)
        itemVisuals:add(itemVisual)
    end

    -- 7. Clean up
    humanVisual:removeBlood()
    humanVisual:removeDirt()
    
    -- 8. Refresh Model
    zombie:resetModelNextFrame()
end

-- ==============================================================================
-- 3. UTILITIES
-- ==============================================================================

function MyNPC.GenerateName(isFemale)
    local maleNames = {"Bob", "Jim", "Mike", "Steve", "Alex", "Zed"}
    local femaleNames = {"Alice", "Jane", "Sarah", "Emily", "Kate"}
    
    local list = isFemale and femaleNames or maleNames
    return list[ZombRand(#list) + 1] .. " Survivor"
end