-- ==============================================================================
-- DTNPC_Data_Visuals.lua
-- NPC wardrobe and human visual application.
-- ==============================================================================

DTNPC = DTNPC or {}

function DTNPC.ApplyVisuals(zombie, npcData)
    if not zombie or not npcData then return end

    if DTNPCProtect and DTNPCProtect.AssignRandomWorldLoadout then
        DTNPCProtect.AssignRandomWorldLoadout(npcData)
    end
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
        if not npcData.beardStyleResolved then
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
        outfit = DT_NPC_Wardrobe.GetOutfitBySeed(
            npcData.archetypeID or "General",
            npcData.isFemale,
            npcData.identitySeed or 1
        )
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

    DTNPC.SyncEquipmentVisuals(zombie, npcData, { force = true })

    -- 8. Refresh Model
    zombie:resetModelNextFrame()
end
