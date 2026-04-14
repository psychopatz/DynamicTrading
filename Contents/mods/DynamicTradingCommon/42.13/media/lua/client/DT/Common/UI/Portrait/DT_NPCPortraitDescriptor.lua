-- =============================================================================
-- DYNAMIC TRADING: SHARED PORTRAIT DESCRIPTOR BUILDER
-- =============================================================================
-- Builds deterministic SurvivorDesc data for UIs that need a portrait without a
-- live in-world NPC reference.
-- =============================================================================

require "DT/Common/NPC/DT_NPC_Wardrobe"

DT_NPCPortraitDescriptor = DT_NPCPortraitDescriptor or {}

local function createPortraitItem(itemType)
    if not itemType or itemType == "" then
        return nil
    end

    if instanceItem then
        local ok, item = pcall(instanceItem, itemType)
        if ok and item then
            return item
        end
    end

    if InventoryItemFactory and InventoryItemFactory.CreateItem then
        local ok, item = pcall(InventoryItemFactory.CreateItem, itemType)
        if ok and item then
            return item
        end
    end

    return nil
end

local function createPortraitSurvivorDesc()
    if not SurvivorFactory or not SurvivorFactory.CreateSurvivor then
        return nil
    end

    if SurvivorType and SurvivorType.Neutral then
        local ok, desc = pcall(SurvivorFactory.CreateSurvivor, SurvivorType.Neutral, false)
        if ok and desc then
            return desc
        end
    end

    local ok, desc = pcall(SurvivorFactory.CreateSurvivor)
    if ok and desc then
        return desc
    end

    return nil
end

local function resolveIsFemale(targetData)
    if not targetData then
        return false
    end

    if targetData.isFemale ~= nil then
        return targetData.isFemale == true
    end

    return targetData.gender == "Female"
end

local function resolveArchetype(targetData)
    if not targetData then
        return "General"
    end

    return targetData.archetypeID or targetData.archetype or targetData.role or "General"
end

function DT_NPCPortraitDescriptor.Build(targetData)
    if not targetData then
        return nil
    end

    local desc = createPortraitSurvivorDesc()
    if not desc then
        return nil
    end

    local isFemale = resolveIsFemale(targetData)
    local archetypeID = resolveArchetype(targetData)
    local identitySeed = targetData.identitySeed or 1

    desc:setFemale(isFemale)

    local humanVisual = desc:getHumanVisual()
    if not humanVisual then
        return nil
    end

    humanVisual:setSkinTextureName(isFemale and "FemaleBody01" or "MaleBody01")

    local hairStyle = targetData.hairStyle
    if not hairStyle and DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetHairStyleBySeed then
        hairStyle = DT_NPC_Wardrobe.GetHairStyleBySeed(archetypeID, isFemale, identitySeed)
    end
    if hairStyle then
        humanVisual:setHairModel(hairStyle)
    end

    local beardStyle = targetData.beardStyle
    if (not beardStyle) and (not isFemale) and DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetBeardStyleBySeed then
        beardStyle = DT_NPC_Wardrobe.GetBeardStyleBySeed(archetypeID, identitySeed)
    end
    if beardStyle then
        humanVisual:setBeardModel(beardStyle)
    elseif not isFemale then
        humanVisual:setBeardModel("")
    end

    local hairColor = targetData.hairColor
    if (not hairColor) and DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetHairColorBySeed then
        hairColor = DT_NPC_Wardrobe.GetHairColorBySeed(archetypeID, identitySeed)
    end
    if hairColor and ImmutableColor then
        local immutableColor = ImmutableColor.new(hairColor.r or 0.2, hairColor.g or 0.1, hairColor.b or 0.1, 1)
        humanVisual:setHairColor(immutableColor)
        humanVisual:setBeardColor(immutableColor)
    end

    desc:getWornItems():clear()

    local outfit = targetData.outfit
    if (not outfit or type(outfit) ~= "table") and DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetOutfitBySeed then
        outfit = DT_NPC_Wardrobe.GetOutfitBySeed(archetypeID, isFemale, identitySeed)
    end

    if outfit and type(outfit) == "table" then
        local wornItems = desc:getWornItems()
        for _, itemType in ipairs(outfit) do
            if type(itemType) == "string" then
                local item = createPortraitItem(itemType)
                if item then
                    local bodyLocation = item:getBodyLocation()
                    if bodyLocation and bodyLocation ~= "" then
                        wornItems:setItem(bodyLocation, item)
                    end
                end
            end
        end
    end

    humanVisual:removeBlood()
    humanVisual:removeDirt()

    if desc.resetModel then
        pcall(function()
            desc:resetModel()
        end)
    end

    return desc
end

return DT_NPCPortraitDescriptor
