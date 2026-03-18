-- ==============================================================================
-- DTNPC_Data.lua
-- Shared Logic: Defines the npcData structure, Wardrobe, and Visual overrides.
-- Works on both client and server.
-- ==============================================================================

DTNPC = DTNPC or {}


-- ==============================================================================
-- 1. DATA MANAGEMENT
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

function DTNPC.ApplyCharacterFlags(zombie, npcData)
    if not zombie then return end

    local state = npcData and npcData.state or nil
    local allowZombieMelee = state == "Attack"

    zombie:setNoTeeth(not allowZombieMelee)
    zombie:setVariable("NoLungeAttack", not allowZombieMelee)
    zombie:setVariable("NoLungeTarget", true)
    zombie:setVariable("ZombieHitReaction", "Chainsaw")

    local desc = zombie:getDescriptor()
    if desc then
        desc:setVoicePrefix("NotAZombie")
    end
end

-- ==============================================================================
-- 2. VISUALS (THE COSTUME)
-- ==============================================================================

function DTNPC.ApplyVisuals(zombie, npcData)
    if not zombie or not npcData then return end

    DTNPC.ApplyCharacterFlags(zombie, npcData)

    local humanVisual = zombie:getHumanVisual()
    if not humanVisual then return end 

    -- 1. Reset everything
    zombie:getItemVisuals():clear()
    zombie:getWornItems():clear()

    -- 2. Apply Skin
    local skinTexture = npcData.isFemale and "FemaleBody01" or "MaleBody01"
    humanVisual:setSkinTextureName(skinTexture)
    
    -- 3. Apply Hair
    -- Resolve from archetype + identitySeed, fallback to saved hairStyle (backward compat)
    local style = npcData.hairStyle
    if not style then
        -- New system: resolve deterministically from archetype + identitySeed
        style = DT_NPC_Wardrobe.GetHairStyleBySeed(
            npcData.archetypeID or "General",
            npcData.isFemale,
            npcData.identitySeed or 1
        )
    end
    
    if style then
        humanVisual:setHairModel(style)
    end

    -- Resolve from archetype + identitySeed, fallback to saved beard (backward compat)
    local beard = npcData.beardStyle
    if (not beard) and (not npcData.isFemale) then
        if not npcData.beardStyleResolved then -- Only if not explicitly clean-shaven
            -- New system: resolve deterministically from archetype + identitySeed
            beard = DT_NPC_Wardrobe.GetBeardStyleBySeed(
                npcData.archetypeID or "General",
                npcData.identitySeed or 1
            )
        end
    end

    if beard then
        humanVisual:setBeardModel(beard)
    elseif not npcData.isFemale then
        humanVisual:setBeardModel("")
    end

    -- Resolve from archetype + identitySeed, fallback to saved RGB (backward compat)
    local color = npcData.hairColor
    if not color then
        -- New system: resolve deterministically from archetype + identitySeed
        color = DT_NPC_Wardrobe.GetHairColorBySeed(
            npcData.archetypeID or "General",
            npcData.identitySeed or 1
        )
    end

    if color and ImmutableColor then
        local immutableColor = ImmutableColor.new(color.r or 0.2, color.g or 0.1, color.b or 0.1, 1)
        humanVisual:setHairColor(immutableColor)
        humanVisual:setBeardColor(immutableColor)
    end
    
    -- 4. Apply Clothing
    -- Prefer explicit outfit override (MVP/custom NPC), otherwise derive deterministic look from seed.
    local outfit = npcData.outfit
    if (not outfit or type(outfit) ~= "table") and DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetOutfitBySeed then
        outfit = DT_NPC_Wardrobe.GetOutfitBySeed(npcData.archetypeID or "General", npcData.isFemale, npcData.identitySeed or 1)
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
-- 3. UTILITIES
-- ==============================================================================

Events.OnGameStart.Add(function()
    DynamicTrading.Log("DTV2", "Init", "NPC", "NPC Data System Loaded")
end)



