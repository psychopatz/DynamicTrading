-- ==============================================================================
-- MyNPC_Data.lua
-- Shared Logic: Defines the Brain structure, Wardrobe, and Visual overrides.
-- UPDATED: Added Wardrobe Framework for easy clothing management.
-- ==============================================================================

MyNPC = MyNPC or {}

-- ==============================================================================
-- 1. WARDROBE DATABASE (The Dress System)
-- ==============================================================================

-- Define your outfits here. You can add as many categories and sets as you want.
-- Item names must match the "Base.ItemName" format from the game files.
MyNPC.Wardrobe = {
    
    -- CASUAL OUTFITS
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

    -- EXAMPLE: You can add a "Police" category later
    -- Police = { Male = { ... }, Female = { ... } }
}

-- Helper to pick a random outfit based on Gender and Category
function MyNPC.GetOutfit(isFemale, category)
    local genderKey = isFemale and "Female" or "Male"
    local cat = category or "Casual" -- Default to Casual
    
    local pool = MyNPC.Wardrobe[cat] and MyNPC.Wardrobe[cat][genderKey]
    
    if pool and #pool > 0 then
        -- Return a random set from the list
        return pool[ZombRand(#pool) + 1]
    else
        -- Fallback if typo or empty
        print("[MyNPC] Warning: No outfit found for " .. cat .. "/" .. genderKey)
        return { "Base.Tshirt_White", "Base.Jeans_Black" }
    end
end

-- ==============================================================================
-- 2. BRAIN MANAGEMENT
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
-- 3. VISUALS (THE COSTUME)
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

    -- 6. APPLY CLOTHING FROM BRAIN
    -- The brain should now contain a list of items (brain.outfit)
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
-- 4. UTILITIES
-- ==============================================================================

function MyNPC.GenerateName(isFemale)
    local maleNames = {"Bob", "Jim", "Mike", "Steve", "Alex", "Zed", "Arthur", "John"}
    local femaleNames = {"Alice", "Jane", "Sarah", "Emily", "Kate", "Rose", "Anna"}
    
    local list = isFemale and femaleNames or maleNames
    return list[ZombRand(#list) + 1] .. " Survivor"
end