-- ==============================================================================
-- DTNPC_EquipmentVisuals_Apply.lua
-- Visual application and cleanup for managed equipment.
-- ==============================================================================

DTNPCEquipmentVisuals = DTNPCEquipmentVisuals or {}

local EquipmentVisuals = DTNPCEquipmentVisuals
EquipmentVisuals.Helpers = EquipmentVisuals.Helpers or {}
EquipmentVisuals.Internal = EquipmentVisuals.Internal or {}

local Helpers = EquipmentVisuals.Helpers
local Internal = EquipmentVisuals.Internal

local function buildEquipmentStateKey(npcData, activeWeapon, bagItem)
    local loadout = npcData and npcData.loadout or {}
    local parts = {
        tostring(npcData and npcData.state or ""),
        tostring(npcData and npcData.autoProtectActiveState or ""),
        tostring(npcData and npcData.combatOrder or ""),
        tostring(activeWeapon or ""),
        tostring(loadout.rangedWeapon or ""),
        tostring(loadout.rangedCondition or ""),
        tostring(loadout.ammoCount or ""),
        tostring(loadout.meleeWeapon or ""),
        tostring(loadout.meleeCondition or ""),
        tostring(bagItem or ""),
    }
    return table.concat(parts, "|")
end

function EquipmentVisuals.Apply(zombie, npcData, options)
    if not zombie or not npcData then
        return false
    end

    options = options or {}

    local modData = zombie:getModData()
    if not modData then
        return false
    end

    local activeWeapon = Internal.chooseActiveWeapon(npcData)
    local bagItem = EquipmentVisuals.GetDisplayBag(npcData)
    local stateKey = buildEquipmentStateKey(npcData, activeWeapon, bagItem)

    if not options.force and modData.DTNPCEquipmentStateKey == stateKey then
        return false
    end

    local bagChanged = Helpers.syncBagVisual(zombie, modData, bagItem)
    local activeItem = Helpers.createDisplayItem(activeWeapon, Helpers.getStoredWeaponCondition(npcData, activeWeapon))
    local primaryType = Helpers.getWeaponDisplayType(activeItem)
    local attachments = Internal.buildAttachmentMap(npcData, activeWeapon)
    local signature = Internal.buildSignature(activeWeapon, primaryType, attachments, bagItem)

    Helpers.clearManagedEquipment(zombie)

    zombie:setVariable("DTNPCPrimary", activeWeapon or "")
    zombie:setVariable("DTNPCPrimaryType", primaryType or "")

    if activeItem then
        zombie:setPrimaryHandItem(activeItem)
    end

    for slot, itemType in pairs(attachments) do
        local item = Helpers.createDisplayItem(itemType, Helpers.getStoredWeaponCondition(npcData, itemType))
        if item then
            zombie:setAttachedItem(slot, item)
        end
    end

    if zombie.resetEquippedHandsModels then
        zombie:resetEquippedHandsModels()
    end

    modData.DTNPCEquipmentSignature = signature
    modData.DTNPCEquipmentStateKey = stateKey
    modData.DTNPCDisplayBag = bagItem
    if bagChanged then
        zombie:resetModelNextFrame()
    end
    return true
end

function EquipmentVisuals.Clear(zombie)
    if not zombie then
        return false
    end

    local modData = zombie:getModData()
    Helpers.clearManagedEquipment(zombie)
    zombie:setVariable("DTNPCPrimary", "")
    zombie:setVariable("DTNPCPrimaryType", "")
    if modData then
        modData.DTNPCEquipmentSignature = nil
        modData.DTNPCEquipmentStateKey = nil
        modData.DTNPCDisplayBag = nil
        if modData.DTNPCInjectedBag and modData.DTNPCInjectedBag ~= "" then
            if Helpers.removeBagVisual(zombie, modData.DTNPCInjectedBag) then
                zombie:resetModelNextFrame()
            end
        end
        modData.DTNPCInjectedBag = nil
    end
    return true
end
