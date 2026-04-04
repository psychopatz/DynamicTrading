-- ==============================================================================
-- DTNPC_EquipmentVisuals_Core.lua
-- Shared constants and low-level helpers for equipment visuals.
-- ==============================================================================

DTNPCEquipmentVisuals = DTNPCEquipmentVisuals or {}

local EquipmentVisuals = DTNPCEquipmentVisuals
EquipmentVisuals.Constants = EquipmentVisuals.Constants or {}
EquipmentVisuals.Helpers = EquipmentVisuals.Helpers or {}

local Constants = EquipmentVisuals.Constants
local Helpers = EquipmentVisuals.Helpers

Constants.MANAGED_ATTACHMENT_TYPES = Constants.MANAGED_ATTACHMENT_TYPES or {
    HolsterRight = true,
    Back = true,
    SmallBeltLeft = true,
}

Constants.MELEE_BUMP_TYPES = Constants.MELEE_BUMP_TYPES or {
    onehanded = { "DTNPCAttack1H1", "DTNPCAttack1H2" },
    twohanded = { "DTNPCAttack2H1", "DTNPCAttack2H2" },
    knife = { "DTNPCAttackKnife" },
}

Constants.RANGED_BUMP_TYPES = Constants.RANGED_BUMP_TYPES or {
    handgun = { "DTNPCIdleToAimPistol", "DTNPCAimPistol" },
    rifle = { "DTNPCIdleToAimRifle", "DTNPCAimRifle" },
}

function Helpers.lower(value)
    if value == nil then
        return ""
    end
    return string.lower(tostring(value))
end

function Helpers.getScriptItemDefinition(fullType)
    if not fullType or fullType == "" or not getScriptManager then
        return nil
    end

    local manager = getScriptManager()
    if manager and manager.FindItem then
        return manager:FindItem(fullType)
    end

    return nil
end

function Helpers.createDisplayItem(itemType, itemCondition)
    if not itemType or itemType == "" then
        return nil
    end

    local item = nil
    if instanceItem then
        item = instanceItem(itemType)
    elseif InventoryItemFactory and InventoryItemFactory.CreateItem then
        item = InventoryItemFactory.CreateItem(itemType)
    end

    if item and itemCondition ~= nil and item.getConditionMax and item.setCondition then
        local maxCondition = tonumber(item:getConditionMax()) or 0
        if maxCondition > 0 then
            local resolvedCondition = math.max(0, math.min(maxCondition, math.floor(tonumber(itemCondition) or maxCondition)))
            item:setCondition(resolvedCondition)
        end
    end

    return item
end

function Helpers.getStoredWeaponCondition(npcData, itemType)
    local loadout = npcData and npcData.loadout or nil
    if not loadout or not itemType or itemType == "" then
        return nil
    end

    if loadout.rangedWeapon == itemType then
        return loadout.rangedCondition
    end
    if loadout.meleeWeapon == itemType then
        return loadout.meleeCondition
    end

    return nil
end

function Helpers.getManagedAttachmentSlots()
    local slots = {}
    if not ISHotbarAttachDefinition then
        return slots
    end

    for _, def in pairs(ISHotbarAttachDefinition) do
        if def and Constants.MANAGED_ATTACHMENT_TYPES[def.type] and def.attachments then
            for _, slot in pairs(def.attachments) do
                slots[#slots + 1] = slot
            end
        end
    end

    table.sort(slots, function(a, b)
        return tostring(a) < tostring(b)
    end)

    return slots
end

function Helpers.clearManagedEquipment(zombie)
    if not zombie then
        return
    end

    if zombie:getPrimaryHandItem() then
        zombie:setPrimaryHandItem(nil)
    end
    if zombie:getSecondaryHandItem() then
        zombie:setSecondaryHandItem(nil)
    end

    local slots = Helpers.getManagedAttachmentSlots()
    for i = 1, #slots do
        zombie:setAttachedItem(slots[i], nil)
    end

    if zombie.resetEquippedHandsModels then
        zombie:resetEquippedHandsModels()
    end
end

function Helpers.resolveAttachmentSlot(item)
    if not item or not ISHotbarAttachDefinition then
        return nil
    end

    local attachmentType = item.getAttachmentType and item:getAttachmentType() or nil
    if not attachmentType or attachmentType == "" then
        return nil
    end

    for _, def in pairs(ISHotbarAttachDefinition) do
        if def and Constants.MANAGED_ATTACHMENT_TYPES[def.type] and def.attachments then
            for attachKey, slot in pairs(def.attachments) do
                if attachKey == attachmentType then
                    return slot
                end
            end
        end
    end

    return nil
end

function Helpers.getWeaponDisplayType(item)
    if not item then
        return ""
    end

    if item.IsWeapon and item:IsWeapon() and WeaponType and WeaponType.getWeaponType then
        local weaponType = WeaponType.getWeaponType(item)
        if weaponType == WeaponType.UNARMED then
            return "barehand"
        elseif weaponType == WeaponType.FIREARM then
            return "rifle"
        elseif weaponType == WeaponType.HANDGUN then
            return "handgun"
        elseif weaponType == WeaponType.HEAVY then
            return "twohanded"
        elseif weaponType == WeaponType.ONE_HANDED then
            return "onehanded"
        elseif weaponType == WeaponType.SPEAR then
            return "spear"
        elseif weaponType == WeaponType.TWO_HANDED then
            return "twohanded"
        elseif weaponType == WeaponType.THROWING then
            return "throwing"
        elseif weaponType == WeaponType.CHAINSAW then
            return "chainsaw"
        end
    end

    local lowered = Helpers.lower(item.getFullType and item:getFullType() or item.getType and item:getType() or "")
    if lowered:find("pistol", 1, true) or lowered:find("revolver", 1, true) then
        return "handgun"
    end
    if lowered:find("rifle", 1, true) or lowered:find("shotgun", 1, true) or lowered:find("smg", 1, true) then
        return "rifle"
    end
    if lowered:find("spear", 1, true) then
        return "spear"
    end

    return "item"
end
