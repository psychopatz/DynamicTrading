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
    local activeItem = Helpers.createDisplayItem(activeWeapon, Helpers.getStoredWeaponCondition(npcData, activeWeapon))
    local primaryType = Helpers.getWeaponDisplayType(activeItem)
    local attachments = Internal.buildAttachmentMap(npcData, activeWeapon)
    local bagItem = EquipmentVisuals.GetDisplayBag(npcData)
    local signature = Internal.buildSignature(activeWeapon, primaryType, attachments, bagItem)
    local bagChanged = Helpers.syncBagVisual(zombie, modData, bagItem)

    if not options.force and modData.DTNPCEquipmentSignature == signature then
        if bagChanged then
            zombie:resetModelNextFrame()
        end
        modData.DTNPCDisplayBag = bagItem
        return bagChanged
    end

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
