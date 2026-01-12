-- ==============================================================================
-- DTNPC_Data.lua
-- Shared Logic: Defines the Brain structure, Wardrobe, and Visual overrides.
-- Build 42 Compatible. Works on both client and server.
-- ==============================================================================

DTNPC = DTNPC or {}

-- ==============================================================================
-- 1. WARDROBE DATABASE (The Dress System)
-- ==============================================================================

DTNPC.Wardrobe = {
    Casual = {
        Male = {
            { "Base.Tshirt_White", "Base.Jeans_Black", "Base.Shoes_Sneakers" },
            { "Base.Shirt_Flannel", "Base.Trousers_Denim", "Base.Shoes_Black" },
            { "Base.Tshirt_Rock", "Base.Shorts_CamoGreenLong", "Base.Shoes_ArmyBoots" },
            { "Base.Hoodie_Grey", "Base.Trousers_Padded", "Base.Shoes_Trainer" },
        },
        Female = {
            { "Base.Tshirt_White", "Base.Jeans_Black", "Base.Shoes_Sneakers" },
            { "Base.Dress_Normal", "Base.Shoes_Black" },
            { "Base.Shirt_HawaiianRed", "Base.Shorts_ShortDenim", "Base.Shoes_FlipFlops" },
            { "Base.Top_SpaghettiStrap_White", "Base.Skirt_Knees_Denim", "Base.Shoes_Trainer" },
        }
    },
}

-- Default walking speeds
DTNPC.DefaultWalkSpeed = 0.06
DTNPC.DefaultRunSpeed = 0.09

function DTNPC.GetOutfit(isFemale, category)
    local genderKey = isFemale and "Female" or "Male"
    local cat = category or "Casual"
    
    local pool = DTNPC.Wardrobe[cat] and DTNPC.Wardrobe[cat][genderKey]
    
    if pool and #pool > 0 then
        return pool[ZombRand(#pool) + 1]
    else
        print("[DTNPC] Warning: No outfit found for " .. cat .. "/" .. genderKey)
        return { "Base.Tshirt_White", "Base.Jeans_Black" }
    end
end

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
    local hairStyles = getAllHairStyles(brain.isFemale)
    if hairStyles and hairStyles:size() > 0 then
        local hairIndex = brain.hairStyle or ZombRand(hairStyles:size())
        local styleId = hairStyles:get(hairIndex)
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
    
    if ImmutableColor then
        local color = ImmutableColor.new(r, g, b, 1)
        humanVisual:setHairColor(color)
        humanVisual:setBeardColor(color)
    end

    -- 6. Apply Clothing
    local outfit = brain.outfit
    if outfit then
        local itemVisuals = zombie:getItemVisuals()
        for _, itemType in ipairs(outfit) do
            local itemVisual = ItemVisual.new()
            itemVisual:setItemType(itemType)
            itemVisual:setClothingItemName(itemType)
            itemVisuals:add(itemVisual)
        end
    end

    -- 7. Clean up
    humanVisual:removeBlood()
    humanVisual:removeDirt()
    
    -- 8. Refresh Model
    zombie:resetModelNextFrame()
end

-- ==============================================================================
-- 4. DIALOGUE SYSTEM
-- ==============================================================================

-- Color definitions for dialogue
DTNPC.Colors = {
    white = "<RGB:1,1,1>",
    red = "<RGB:1,0.2,0.2>",
    green = "<RGB:0.2,1,0.2>",
    blue = "<RGB:0.4,0.6,1>",
    gray = "<RGB:0.6,0.6,0.6>",
    yellow = "<RGB:1,1,0.2>",
    orange = "<RGB:1,0.6,0.2>",
    purple = "<RGB:0.8,0.4,1>",
}

-- Make NPC say something with optional color
-- Usage: DTNPC.Say(zombie, "Hello!", "green")
function DTNPC.Say(zombie, text, colorName)
    if not zombie or not text then return end
    
    local brain = DTNPC.GetBrain(zombie)
    local prefix = ""
    
    -- Add NPC name as prefix if available
    if brain and brain.name then
        prefix = "[" .. brain.name .. "] "
    end
    
    -- Apply color if specified
    local colorTag = ""
    if colorName and DTNPC.Colors[colorName] then
        colorTag = DTNPC.Colors[colorName]
    end
    
    local fullText = colorTag .. prefix .. text
    
    pcall(function()
        zombie:Say(fullText)
    end)
end

-- Make NPC say something with custom RGB color
-- Usage: DTNPC.SayRGB(zombie, "Hello!", 1, 0.5, 0)
function DTNPC.SayRGB(zombie, text, r, g, b)
    if not zombie or not text then return end
    
    local brain = DTNPC.GetBrain(zombie)
    local prefix = ""
    
    if brain and brain.name then
        prefix = "[" .. brain.name .. "] "
    end
    
    r = r or 1
    g = g or 1
    b = b or 1
    
    local colorTag = string.format("<RGB:%s,%s,%s>", r, g, b)
    local fullText = colorTag .. prefix .. text
    
    pcall(function()
        zombie:Say(fullText)
    end)
end

-- Announce NPC name overhead (call periodically to show name)
function DTNPC.AnnounceName(zombie)
    if not zombie then return end
    
    local brain = DTNPC.GetBrain(zombie)
    if not brain or not brain.name then return end
    
    DTNPC.Say(zombie, brain.name, "white")
end

-- ==============================================================================
-- 5. UTILITIES
-- ==============================================================================

function DTNPC.GenerateName(isFemale)
    local maleNames = {"Bob", "Jim", "Mike", "Steve", "Alex", "Zed", "Arthur", "John"}
    local femaleNames = {"Alice", "Jane", "Sarah", "Emily", "Kate", "Rose", "Anna"}
    
    local list = isFemale and femaleNames or maleNames
    return list[ZombRand(#list) + 1] .. " Survivor"
end

