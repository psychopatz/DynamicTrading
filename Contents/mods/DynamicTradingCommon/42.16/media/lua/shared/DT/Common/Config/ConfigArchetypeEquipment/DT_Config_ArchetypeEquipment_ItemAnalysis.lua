-- =============================================================================
-- ARCHETYPE EQUIPMENT: ITEM ANALYSIS
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeEquipmentInternal = DynamicTrading.ArchetypeEquipmentInternal or {}

local internal = DynamicTrading.ArchetypeEquipmentInternal

function internal.hasTag(itemData, targetTag)
    local tags = type(itemData) == "table" and itemData.tags or nil
    if type(tags) ~= "table" then
        return false
    end

    for _, tag in ipairs(tags) do
        if tag == targetTag then
            return true
        end
    end

    return false
end

function internal.hasTagPrefix(itemData, prefix)
    local tags = type(itemData) == "table" and itemData.tags or nil
    if type(tags) ~= "table" then
        return false
    end

    for _, tag in ipairs(tags) do
        if type(tag) == "string" and string.sub(tag, 1, #prefix) == prefix then
            return true
        end
    end

    return false
end

function internal.isRangedWeapon(fullType, scriptItem)
    if not fullType or fullType == "" then
        return false
    end

    if scriptItem then
        if scriptItem.isRanged and scriptItem:isRanged() then
            return true
        end
        if scriptItem.isAimedFirearm and scriptItem:isAimedFirearm() then
            return true
        end
        if scriptItem.getAmmoType and scriptItem:getAmmoType() and scriptItem:getAmmoType() ~= "" then
            return true
        end

        local displayCategory = scriptItem.getDisplayCategory and scriptItem:getDisplayCategory() or nil
        if internal.lower(displayCategory):find("firearm", 1, true) then
            return true
        end
    end

    local lowered = internal.lower(fullType)
    return lowered:find("pistol", 1, true) ~= nil
        or lowered:find("revolver", 1, true) ~= nil
        or lowered:find("shotgun", 1, true) ~= nil
        or lowered:find("rifle", 1, true) ~= nil
        or lowered:find("carbine", 1, true) ~= nil
        or lowered:find("smg", 1, true) ~= nil
        or lowered:find("firearm", 1, true) ~= nil
        or lowered:find("gun", 1, true) ~= nil
end

function internal.isMeleeWeapon(fullType, scriptItem)
    if not fullType or fullType == "" then
        return false
    end

    if internal.isRangedWeapon(fullType, scriptItem) then
        return false
    end

    if scriptItem then
        local swingAnim = scriptItem.getSwingAnim and scriptItem:getSwingAnim() or nil
        local displayCategory = scriptItem.getDisplayCategory and scriptItem:getDisplayCategory() or nil
        if swingAnim and internal.lower(swingAnim) ~= "" then
            return true
        end
        if internal.lower(displayCategory):find("melee", 1, true) then
            return true
        end
    end

    local lowered = internal.lower(fullType)
    return lowered:find("bat", 1, true) ~= nil
        or lowered:find("axe", 1, true) ~= nil
        or lowered:find("knife", 1, true) ~= nil
        or lowered:find("machete", 1, true) ~= nil
        or lowered:find("club", 1, true) ~= nil
        or lowered:find("hammer", 1, true) ~= nil
        or lowered:find("spear", 1, true) ~= nil
        or lowered:find("crowbar", 1, true) ~= nil
end

function internal.deriveWeight(itemData)
    local explicitWeight = math.floor(tonumber(itemData and itemData.loadoutWeight) or tonumber(itemData and itemData.weight) or 0)
    if explicitWeight > 0 then
        return explicitWeight
    end

    local stockRange = type(itemData) == "table" and itemData.stockRange or nil
    local stockMax = math.floor(tonumber(stockRange and stockRange.max) or 0)
    local weight = math.max(1, math.min(8, stockMax))

    if internal.hasTag(itemData, "Rarity.Common") then
        weight = weight + 2
    elseif internal.hasTag(itemData, "Rarity.Uncommon") then
        weight = weight + 1
    end

    if internal.hasTag(itemData, "Quality.Waste") then
        weight = math.max(1, weight - 1)
    end

    return math.max(1, weight)
end

function internal.deriveRangedAmmoWindow(fullType, scriptItem)
    local ammoType = nil
    if scriptItem and scriptItem.getAmmoType then
        ammoType = scriptItem:getAmmoType()
    end

    local clipSize = nil
    if scriptItem and scriptItem.getClipSize then
        clipSize = tonumber(scriptItem:getClipSize())
    end
    clipSize = math.max(1, math.floor(clipSize or 0))

    local lowered = internal.lower(fullType)
    if lowered:find("revolver", 1, true) then
        clipSize = math.max(clipSize, 6)
        return ammoType, clipSize, clipSize * 3
    end
    if lowered:find("shotgun", 1, true) then
        clipSize = math.max(clipSize, 6)
        return ammoType, clipSize + 2, clipSize * 4
    end
    if lowered:find("rifle", 1, true) or lowered:find("carbine", 1, true) then
        clipSize = math.max(clipSize, 5)
        return ammoType, clipSize * 2, clipSize * 5
    end

    clipSize = math.max(clipSize, 8)
    return ammoType, math.max(clipSize, math.floor(clipSize * 1.5)), clipSize * 4
end
