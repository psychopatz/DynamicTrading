-- ==============================================================================
-- DTNPC_EquipmentVisuals.lua
-- Shared helpers for visible NPC equipment, held weapons, and attached gear.
-- Keeps display logic separate from behavior and wardrobe code.
-- ==============================================================================

DTNPCEquipmentVisuals = DTNPCEquipmentVisuals or {}

require "DT/V2/NPC/Sys/DTNPC_Protect"

local MANAGED_ATTACHMENT_TYPES = {
    HolsterRight = true,
    Back = true,
    SmallBeltLeft = true,
}

local MELEE_BUMP_TYPES = {
    onehanded = { "DTNPCAttack1H1", "DTNPCAttack1H2" },
    twohanded = { "DTNPCAttack2H1", "DTNPCAttack2H2" },
    knife = { "DTNPCAttackKnife" },
}

local RANGED_BUMP_TYPES = {
    handgun = { "DTNPCIdleToAimPistol", "DTNPCAimPistol" },
    rifle = { "DTNPCIdleToAimRifle", "DTNPCAimRifle" },
}

local function lower(value)
    if value == nil then
        return ""
    end
    return string.lower(tostring(value))
end

local function getScriptItemDefinition(fullType)
    if not fullType or fullType == "" or not getScriptManager then
        return nil
    end

    local manager = getScriptManager()
    if manager and manager.FindItem then
        return manager:FindItem(fullType)
    end

    return nil
end

local function createDisplayItem(itemType, itemCondition)
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

local function getStoredWeaponCondition(npcData, itemType)
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

local function getManagedAttachmentSlots()
    local slots = {}
    if not ISHotbarAttachDefinition then
        return slots
    end

    for _, def in pairs(ISHotbarAttachDefinition) do
        if def and MANAGED_ATTACHMENT_TYPES[def.type] and def.attachments then
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

local function clearManagedEquipment(zombie)
    if not zombie then return end

    if zombie:getPrimaryHandItem() then
        zombie:setPrimaryHandItem(nil)
    end
    if zombie:getSecondaryHandItem() then
        zombie:setSecondaryHandItem(nil)
    end

    local slots = getManagedAttachmentSlots()
    for i = 1, #slots do
        zombie:setAttachedItem(slots[i], nil)
    end

    if zombie.resetEquippedHandsModels then
        zombie:resetEquippedHandsModels()
    end
end

local function resolveAttachmentSlot(item)
    if not item or not ISHotbarAttachDefinition then
        return nil
    end

    local attachmentType = item.getAttachmentType and item:getAttachmentType() or nil
    if not attachmentType or attachmentType == "" then
        return nil
    end

    for _, def in pairs(ISHotbarAttachDefinition) do
        if def and MANAGED_ATTACHMENT_TYPES[def.type] and def.attachments then
            for attachKey, slot in pairs(def.attachments) do
                if attachKey == attachmentType then
                    return slot
                end
            end
        end
    end

    return nil
end

local function hasItemVisual(zombie, itemType)
    if not zombie or not itemType or itemType == "" then
        return false
    end

    local itemVisuals = zombie:getItemVisuals()
    if not itemVisuals then
        return false
    end

    for i = 0, itemVisuals:size() - 1 do
        local itemVisual = itemVisuals:get(i)
        if itemVisual and itemVisual.getItemType and itemVisual:getItemType() == itemType then
            return true
        end
    end

    return false
end

local function addBagVisual(zombie, itemType)
    if not zombie or not itemType or itemType == "" or hasItemVisual(zombie, itemType) then
        return false
    end

    local itemVisuals = zombie:getItemVisuals()
    if not itemVisuals then
        return false
    end

    local itemVisual = ItemVisual.new()
    itemVisual:setItemType(itemType)
    itemVisual:setClothingItemName(itemType)
    itemVisuals:add(itemVisual)
    return true
end

local function removeBagVisual(zombie, itemType)
    if not zombie or not itemType or itemType == "" then
        return false
    end

    local humanVisual = zombie:getHumanVisual()
    if humanVisual and humanVisual.removeBodyVisualFromItemType then
        humanVisual:removeBodyVisualFromItemType(itemType)
        return true
    end

    return false
end

local function syncBagVisual(zombie, modData, bagItem)
    if not zombie or not modData then
        return false
    end

    local changed = false
    local injectedBag = modData.DTNPCInjectedBag

    if injectedBag and injectedBag ~= "" and injectedBag ~= bagItem then
        changed = removeBagVisual(zombie, injectedBag) or changed
        modData.DTNPCInjectedBag = nil
    end

    if bagItem and bagItem ~= "" then
        if hasItemVisual(zombie, bagItem) then
            if modData.DTNPCInjectedBag == bagItem then
                modData.DTNPCInjectedBag = nil
            end
        else
            if addBagVisual(zombie, bagItem) then
                modData.DTNPCInjectedBag = bagItem
                changed = true
            end
        end
    end

    return changed
end

local function getWeaponDisplayType(item)
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

    local lowered = lower(item.getFullType and item:getFullType() or item.getType and item:getType() or "")
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

function DTNPCEquipmentVisuals.GetMeleeWeaponFamily(npcData)
    local loadout = npcData and npcData.loadout or nil
    local weapon = loadout and loadout.meleeWeapon or nil
    if not weapon or weapon == "" then
        return "onehanded"
    end

    local lowered = lower(weapon)
    local scriptItem = getScriptItemDefinition(weapon)
    local swingAnim = scriptItem and scriptItem.getSwingAnim and lower(scriptItem:getSwingAnim()) or ""
    local weaponItem = createDisplayItem(weapon, getStoredWeaponCondition(npcData, weapon))

    if lowered:find("knife", 1, true) or swingAnim:find("knife", 1, true) then
        return "knife"
    end

    if weaponItem and weaponItem.IsWeapon and weaponItem:IsWeapon() and WeaponType and WeaponType.getWeaponType then
        local weaponType = WeaponType.getWeaponType(weaponItem)
        if weaponType == WeaponType.ONE_HANDED then
            return "onehanded"
        end
        if weaponType == WeaponType.HEAVY
            or weaponType == WeaponType.SPEAR
            or weaponType == WeaponType.TWO_HANDED then
            return "twohanded"
        end
    end

    if lowered:find("spear", 1, true) or swingAnim:find("spear", 1, true) then
        return "twohanded"
    end

    if lowered:find("bat", 1, true)
        or lowered:find("axe", 1, true)
        or lowered:find("sledge", 1, true)
        or lowered:find("crowbar", 1, true)
        or lowered:find("pipe", 1, true)
        or lowered:find("bar", 1, true)
        or lowered:find("guitar", 1, true)
        or lowered:find("hammer", 1, true)
        or swingAnim:find("2h", 1, true)
        or swingAnim:find("heavy", 1, true)
        or swingAnim:find("bat", 1, true) then
        return "twohanded"
    end

    return "onehanded"
end

function DTNPCEquipmentVisuals.GetRangedWeaponFamily(npcData)
    local loadout = npcData and npcData.loadout or nil
    local weapon = loadout and loadout.rangedWeapon or nil
    if not weapon or weapon == "" then
        return "handgun"
    end

    local weaponItem = createDisplayItem(weapon, getStoredWeaponCondition(npcData, weapon))
    local displayType = getWeaponDisplayType(weaponItem)
    if displayType == "handgun" then
        return "handgun"
    end

    return "rifle"
end

function DTNPCEquipmentVisuals.GetDisplayBag(npcData)
    if not npcData then
        return nil
    end

    local loadout = type(npcData.loadout) == "table" and npcData.loadout or nil
    if loadout and loadout.bag and loadout.bag ~= "" then
        return loadout.bag
    end

    if npcData.displayBag and npcData.displayBag ~= "" then
        return npcData.displayBag
    end

    local outfit = type(npcData.outfit) == "table" and npcData.outfit or nil
    if not outfit and DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetOutfitBySeed then
        outfit = DT_NPC_Wardrobe.GetOutfitBySeed(
            npcData.archetypeID or "General",
            npcData.isFemale,
            npcData.identitySeed or 1
        )
    end

    if type(outfit) ~= "table" then
        return nil
    end

    for i = 1, #outfit do
        local itemType = outfit[i]
        if itemType and itemType ~= "" then
            local scriptItem = getScriptItemDefinition(itemType)
            local equipSlot = scriptItem and scriptItem.canBeEquipped and scriptItem:canBeEquipped() or nil
            local lowered = lower(itemType)

            if equipSlot == "Back"
                or lowered:find("bag_", 1, true)
                or lowered:find("backpack", 1, true)
                or lowered:find("satchel", 1, true)
                or lowered:find("duffel", 1, true)
                or lowered:find("slingbag", 1, true)
                or lowered:find("schoolbag", 1, true)
                or lowered:find("tote", 1, true) then
                return itemType
            end
        end
    end

    local status = tostring(npcData.status or "")
    local state = tostring(npcData.state or "")
    if status == "Trading"
        or state == "Trading"
        or state == "TradingDefenseMelee"
        or state == "TradingDefenseRanged" then
        return "Base.Bag_Schoolbag"
    end

    return nil
end

local function chooseRequestedProtectWeapon(npcData, hasRanged, hasMelee)
    if not DTNPCProtect or not DTNPCProtect.GetRequestedProtectState then
        return nil
    end

    local requested = DTNPCProtect.GetRequestedProtectState(npcData)
    if requested == "ProtectRanged" then
        if hasRanged then
            return npcData.loadout.rangedWeapon
        end
        if hasMelee then
            return npcData.loadout.meleeWeapon
        end
    elseif requested == "ProtectMelee" then
        if hasMelee then
            return npcData.loadout.meleeWeapon
        end
        if hasRanged then
            return npcData.loadout.rangedWeapon
        end
    elseif requested == "ProtectAuto" then
        local resolved = DTNPCProtect and DTNPCProtect.GetAutoProtectState and DTNPCProtect.GetAutoProtectState(npcData) or nil
        if resolved == "ProtectMelee" and hasMelee then
            return npcData.loadout.meleeWeapon
        end
        if resolved == "ProtectRanged" and hasRanged then
            return npcData.loadout.rangedWeapon
        end
        if hasRanged then
            return npcData.loadout.rangedWeapon
        end
        if hasMelee then
            return npcData.loadout.meleeWeapon
        end
    end

    return nil
end

local function chooseActiveWeapon(npcData)
    if not npcData then
        return nil
    end

    if DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(npcData)
    end

    local loadout = npcData.loadout or {}
    local hasRanged = DTNPCProtect and DTNPCProtect.HasUsableRangedLoadout and DTNPCProtect.HasUsableRangedLoadout(npcData) or false
    local hasMelee = DTNPCProtect and DTNPCProtect.HasUsableMeleeLoadout and DTNPCProtect.HasUsableMeleeLoadout(npcData) or false
    local state = npcData.autoProtectActiveState or npcData.state or ""

    if state == "AttackRange" or state == "TradingDefenseRanged" or state == "ProtectRanged" then
        if hasRanged then
            return loadout.rangedWeapon
        end
        if hasMelee then
            return loadout.meleeWeapon
        end
    end

    if state == "Attack" or state == "TradingDefenseMelee" or state == "ProtectMelee" then
        if hasMelee then
            return loadout.meleeWeapon
        end
        if hasRanged then
            return loadout.rangedWeapon
        end
    end

    return chooseRequestedProtectWeapon(npcData, hasRanged, hasMelee)
end

local function buildAttachmentMap(npcData, activeWeapon)
    local attachments = {}
    local loadout = npcData and npcData.loadout or {}
    local allowRanged = DTNPCProtect and DTNPCProtect.HasUsableRangedLoadout and DTNPCProtect.HasUsableRangedLoadout(npcData) or false
    local allowMelee = DTNPCProtect and DTNPCProtect.HasUsableMeleeLoadout and DTNPCProtect.HasUsableMeleeLoadout(npcData) or false

    local function addWeapon(itemType)
        if not itemType or itemType == "" or itemType == activeWeapon then
            return
        end

        local item = createDisplayItem(itemType, getStoredWeaponCondition(npcData, itemType))
        local slot = resolveAttachmentSlot(item)
        if slot and not attachments[slot] then
            attachments[slot] = itemType
        end
    end

    if allowRanged then
        addWeapon(loadout.rangedWeapon)
    end
    if allowMelee then
        addWeapon(loadout.meleeWeapon)
    end

    return attachments
end

local function buildSignature(activeWeapon, primaryType, attachments, bagItem)
    local parts = {
        "active=" .. tostring(activeWeapon or ""),
        "type=" .. tostring(primaryType or ""),
        "bag=" .. tostring(bagItem or ""),
    }

    local slots = {}
    for slot in pairs(attachments) do
        slots[#slots + 1] = slot
    end
    table.sort(slots, function(a, b)
        return tostring(a) < tostring(b)
    end)

    for i = 1, #slots do
        local slot = slots[i]
        parts[#parts + 1] = tostring(slot) .. "=" .. tostring(attachments[slot] or "")
    end

    return table.concat(parts, "|")
end

function DTNPCEquipmentVisuals.Apply(zombie, npcData, options)
    if not zombie or not npcData then
        return false
    end

    options = options or {}

    local modData = zombie:getModData()
    if not modData then
        return false
    end

    local activeWeapon = chooseActiveWeapon(npcData)
    local activeItem = createDisplayItem(activeWeapon, getStoredWeaponCondition(npcData, activeWeapon))
    local primaryType = getWeaponDisplayType(activeItem)
    local attachments = buildAttachmentMap(npcData, activeWeapon)
    local bagItem = DTNPCEquipmentVisuals.GetDisplayBag(npcData)
    local signature = buildSignature(activeWeapon, primaryType, attachments, bagItem)
    local bagChanged = syncBagVisual(zombie, modData, bagItem)

    if not options.force and modData.DTNPCEquipmentSignature == signature then
        if bagChanged then
            zombie:resetModelNextFrame()
        end
        modData.DTNPCDisplayBag = bagItem
        return bagChanged
    end

    clearManagedEquipment(zombie)

    zombie:setVariable("DTNPCPrimary", activeWeapon or "")
    zombie:setVariable("DTNPCPrimaryType", primaryType or "")

    if activeItem then
        zombie:setPrimaryHandItem(activeItem)
    end

    for slot, itemType in pairs(attachments) do
        local item = createDisplayItem(itemType, getStoredWeaponCondition(npcData, itemType))
        if item then
            zombie:setAttachedItem(slot, item)
        end
    end

    if zombie.resetEquippedHandsModels then
        zombie:resetEquippedHandsModels()
    end

    modData.DTNPCEquipmentSignature = signature
    modData.DTNPCDisplayBag = bagItem
    if bagChanged then
        zombie:resetModelNextFrame()
    end
    return true
end

function DTNPCEquipmentVisuals.Clear(zombie)
    if not zombie then
        return false
    end

    local modData = zombie:getModData()
    clearManagedEquipment(zombie)
    zombie:setVariable("DTNPCPrimary", "")
    zombie:setVariable("DTNPCPrimaryType", "")
    if modData then
        modData.DTNPCEquipmentSignature = nil
        modData.DTNPCDisplayBag = nil
        if modData.DTNPCInjectedBag and modData.DTNPCInjectedBag ~= "" then
            if removeBagVisual(zombie, modData.DTNPCInjectedBag) then
                zombie:resetModelNextFrame()
            end
        end
        modData.DTNPCInjectedBag = nil
    end
    return true
end

function DTNPCEquipmentVisuals.SetMeleeCombatIdleState(zombie, npcData)
    if not zombie then return end

    if DTNPCEquipmentVisuals.GetMeleeWeaponFamily(npcData) == "twohanded" then
        zombie:setVariable("DTIdleState", "10")
        return
    end

    zombie:setVariable("DTIdleState", "0")
end

function DTNPCEquipmentVisuals.SetRangedCombatIdleState(zombie, npcData)
    if not zombie then return end

    local showSightIdle = npcData and npcData.enableRangedSightAnim == true
    local family = DTNPCEquipmentVisuals.GetRangedWeaponFamily(npcData)
    if showSightIdle and family == "handgun" then
        zombie:setVariable("DTIdleState", "2")
        return
    end

    zombie:setVariable("DTIdleState", "0")
end

function DTNPCEquipmentVisuals.TriggerMeleeCombatAnim(zombie, npcData)
    if not zombie then return end

    local family = DTNPCEquipmentVisuals.GetMeleeWeaponFamily(npcData)
    local options = MELEE_BUMP_TYPES[family] or MELEE_BUMP_TYPES.onehanded
    if not options or #options == 0 then
        return
    end

    local index = ZombRand(#options) + 1
    zombie:setBumpType(options[index])
end

function DTNPCEquipmentVisuals.TriggerRangedCombatAnim(zombie, npcData)
    if not zombie then return end

    local family = DTNPCEquipmentVisuals.GetRangedWeaponFamily(npcData)
    local options = RANGED_BUMP_TYPES[family] or RANGED_BUMP_TYPES.handgun
    if not options or #options == 0 then
        return
    end

    local index = ZombRand(#options) + 1
    zombie:setBumpType(options[index])
end
