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
local BlockedAttachmentSlots = EquipmentVisuals.BlockedAttachmentSlots or {}
EquipmentVisuals.BlockedAttachmentSlots = BlockedAttachmentSlots

Constants.MANAGED_ATTACHMENT_TYPES = Constants.MANAGED_ATTACHMENT_TYPES or {
    HolsterRight = true,
    HolsterLeft = true,
    HolsterShoulder = true,
    Back = true,
    SmallBeltLeft = true,
    SmallBeltRight = true,
}

Constants.MANAGED_SLOT_TYPE_PRIORITY = Constants.MANAGED_SLOT_TYPE_PRIORITY or {
    HolsterRight = 1,
    HolsterLeft = 2,
    HolsterShoulder = 3,
    SmallBeltLeft = 4,
    SmallBeltRight = 5,
    Back = 6,
}

Constants.ATTACHMENT_TYPE_SLOT_PRIORITY = Constants.ATTACHMENT_TYPE_SLOT_PRIORITY or {
    Holster = { "HolsterRight", "HolsterLeft", "HolsterShoulder" },
    HolsterSmall = { "HolsterRight", "HolsterLeft", "HolsterShoulder" },
    Knife = { "SmallBeltLeft", "SmallBeltRight" },
    NotKnife = { "SmallBeltLeft", "SmallBeltRight" },
    Hammer = { "SmallBeltLeft", "SmallBeltRight" },
    HammerRotated = { "SmallBeltLeft", "SmallBeltRight" },
    Nightstick = { "SmallBeltLeft", "SmallBeltRight" },
    Screwdriver = { "SmallBeltLeft", "SmallBeltRight" },
    Wrench = { "SmallBeltLeft", "SmallBeltRight" },
    MeatCleaver = { "SmallBeltLeft", "SmallBeltRight" },
    Walkie = { "SmallBeltLeft", "SmallBeltRight" },
    BigWeapon = { "Back" },
    BigBlade = { "Back" },
    Racket = { "Back" },
    Shovel = { "Back" },
    Guitar = { "Back" },
    GuitarAcoustic = { "Back" },
    Pan = { "Back" },
    Saucepan = { "Back" },
    Rifle = { "Back" },
    Sword = { "Back", "SmallBeltLeft", "SmallBeltRight" },
}

Constants.DYNAMIC_SCAN_INTERVAL_MS = Constants.DYNAMIC_SCAN_INTERVAL_MS or 750
Constants.MAX_INVENTORY_SCAN_DEPTH = Constants.MAX_INVENTORY_SCAN_DEPTH or 3

Constants.MELEE_BUMP_TYPES = Constants.MELEE_BUMP_TYPES or {
    onehanded = { "DTNPCAttack1H1", "DTNPCAttack1H2" },
    twohanded = { "DTNPCAttack2H1", "DTNPCAttack2H2" },
    knife = { "DTNPCAttackKnife" },
}

Constants.RANGED_BUMP_TYPES = Constants.RANGED_BUMP_TYPES or {
    handgun = { "DTNPCIdleToAimPistol", "DTNPCAimPistol" },
    rifle = { "DTNPCIdleToAimRifle", "DTNPCAimRifle" },
}

Constants.RANGED_RELOAD_BUMP_TYPES = Constants.RANGED_RELOAD_BUMP_TYPES or {
    pistol = "DTNPCRackPistol",
    rifle = "DTNPCRackRifle",
    shotgun = "DTNPCRackShotgun",
    revolver = "DTNPCRackRevolver",
    dbshotgun = "DTNPCRackDBShotgun",
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

function Helpers.getNowMillis()
    if getTimeInMillis then
        local now = tonumber(getTimeInMillis())
        if now and now > 0 then
            return math.floor(now)
        end
    end

    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor((tonumber(gameTime:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
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
        Helpers.trySetAttachedItem(zombie, slots[i], nil)
    end

    if zombie.resetEquippedHandsModels then
        zombie:resetEquippedHandsModels()
    end
end

function Helpers.trySetAttachedItem(zombie, slot, item)
    if not zombie or not slot or slot == "" then
        return false
    end

    slot = tostring(slot)
    if BlockedAttachmentSlots[slot] then
        return false
    end

    local ok = pcall(function()
        zombie:setAttachedItem(slot, item)
    end)

    if not ok then
        BlockedAttachmentSlots[slot] = true
        if print then
            print("[DynamicTradingV2] Ignoring unsupported attachment slot: " .. slot)
        end
        return false
    end

    return true
end

function Helpers.getAttachmentSlotsByType(attachmentType)
    if not attachmentType or attachmentType == "" or not ISHotbarAttachDefinition then
        return {}
    end

    local preferredTypes = Constants.ATTACHMENT_TYPE_SLOT_PRIORITY[attachmentType] or {}
    local preferredLookup = {}
    for i = 1, #preferredTypes do
        preferredLookup[preferredTypes[i]] = i
    end

    local slotEntries = {}
    for _, def in pairs(ISHotbarAttachDefinition) do
        if def and Constants.MANAGED_ATTACHMENT_TYPES[def.type] and def.attachments then
            local slot = def.attachments[attachmentType]
            if slot and slot ~= "" then
                slotEntries[#slotEntries + 1] = {
                    slot = slot,
                    type = def.type,
                    preferred = preferredLookup[def.type] or 999,
                    fallback = Constants.MANAGED_SLOT_TYPE_PRIORITY[def.type] or 999,
                }
            end
        end
    end

    table.sort(slotEntries, function(left, right)
        if left.preferred ~= right.preferred then
            return left.preferred < right.preferred
        end
        if left.fallback ~= right.fallback then
            return left.fallback < right.fallback
        end
        return tostring(left.slot) < tostring(right.slot)
    end)

    local slots = {}
    local seen = {}
    for i = 1, #slotEntries do
        local slot = tostring(slotEntries[i].slot)
        if not seen[slot] and not BlockedAttachmentSlots[slot] then
            seen[slot] = true
            slots[#slots + 1] = slot
        end
    end

    return slots
end

function Helpers.getItemFullType(item)
    if not item then
        return nil
    end

    if item.getFullType then
        return item:getFullType()
    end
    if item.getType then
        return item:getType()
    end

    return nil
end

function Helpers.getItemCondition(item)
    if not item or not item.getCondition then
        return nil
    end
    return tonumber(item:getCondition())
end

function Helpers.resolveAttachmentSlot(item)
    local slots = Helpers.resolveAttachmentSlots(item)
    return slots[1]
end

function Helpers.resolveAttachmentSlots(item)
    if not item or not ISHotbarAttachDefinition then
        return {}
    end

    local attachmentType = item.getAttachmentType and item:getAttachmentType() or nil
    if not attachmentType or attachmentType == "" then
        return {}
    end

    return Helpers.getAttachmentSlotsByType(attachmentType)
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
