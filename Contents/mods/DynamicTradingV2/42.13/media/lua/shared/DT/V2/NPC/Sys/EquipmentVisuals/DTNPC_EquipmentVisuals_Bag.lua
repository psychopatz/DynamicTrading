-- ==============================================================================
-- DTNPC_EquipmentVisuals_Bag.lua
-- Bag visual helpers and display bag resolution.
-- ==============================================================================

DTNPCEquipmentVisuals = DTNPCEquipmentVisuals or {}

local EquipmentVisuals = DTNPCEquipmentVisuals
EquipmentVisuals.Helpers = EquipmentVisuals.Helpers or {}

local Helpers = EquipmentVisuals.Helpers

function Helpers.hasItemVisual(zombie, itemType)
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

function Helpers.addBagVisual(zombie, itemType)
    if not zombie or not itemType or itemType == "" or Helpers.hasItemVisual(zombie, itemType) then
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

function Helpers.removeBagVisual(zombie, itemType)
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

function Helpers.syncBagVisual(zombie, modData, bagItem)
    if not zombie or not modData then
        return false
    end

    local changed = false
    local injectedBag = modData.DTNPCInjectedBag

    if injectedBag and injectedBag ~= "" and injectedBag ~= bagItem then
        changed = Helpers.removeBagVisual(zombie, injectedBag) or changed
        modData.DTNPCInjectedBag = nil
    end

    if bagItem and bagItem ~= "" then
        if Helpers.hasItemVisual(zombie, bagItem) then
            if modData.DTNPCInjectedBag == bagItem then
                modData.DTNPCInjectedBag = nil
            end
        else
            if Helpers.addBagVisual(zombie, bagItem) then
                modData.DTNPCInjectedBag = bagItem
                changed = true
            end
        end
    end

    return changed
end

function EquipmentVisuals.GetDisplayBag(npcData)
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
            local scriptItem = Helpers.getScriptItemDefinition(itemType)
            local equipSlot = scriptItem and scriptItem.canBeEquipped and scriptItem:canBeEquipped() or nil
            local lowered = Helpers.lower(itemType)

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
