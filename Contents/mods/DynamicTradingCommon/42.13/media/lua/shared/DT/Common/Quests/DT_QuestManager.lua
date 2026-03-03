DynamicTrading = DynamicTrading or {}
DynamicTrading.Quests = DynamicTrading.Quests or {}

local Quests = DynamicTrading.Quests

Quests.QuestItems = {
    { name = "Small Package", id = "DTQuest.PackageSmallQuest" },
    { name = "Medium Package", id = "DTQuest.PackageMediumQuest" },
    { name = "Large Package", id = "DTQuest.PackageLargeQuest" },
    { name = "Fragile Cargo", id = "DTQuest.PackageFragileQuest" },
    { name = "Medical Supplies", id = "DTQuest.PackageMedicalQuest" },
    { name = "Military Crate", id = "DTQuest.PackageMilitaryQuest" },
    { name = "Gift Item", id = "DTQuest.PackageGiftQuest" },
}

--- Requests a quest item spawn. Handles SP/MP modularity.
function Quests.RequestSpawnQuestItem(player, itemID, difficulty, questID)
    if not player or not itemID then return end
    questID = questID or ("Q_" .. ZombRand(100000, 999999))
    difficulty = difficulty or 1.0

    if isClient() then
        -- Send command to server in Multiplayer
        local args = { itemID = itemID, difficulty = difficulty, questID = questID }
        sendClientCommand(player, "DT_Quest", "spawnItem", args)
    else
        -- Direct call in Singleplayer
        Quests.CreateQuestItem(player, itemID, questID, difficulty)
    end
end

--- Creates a quest item for a player with unique ID and dynamic weight.
-- @param player (IsoPlayer) The player receiving the item.
-- @param itemFullType (String) The full type of the item (e.g. "DTQuest.PackageSmallQuest").
-- @param questID (String) A unique identifier for the quest instance.
-- @param difficulty (Number) Multiplier for weight calculation (default 1.0).
-- @return (InventoryItem) The created item object.
function Quests.CreateQuestItem(player, itemFullType, questID, difficulty)
    if not player or not itemFullType then return nil end
    difficulty = difficulty or 1.0
    
    local inventory = player:getInventory()
    if not inventory then return nil end

    -- Standard B42 string-based spawning
    local item = inventory:AddItem(itemFullType)
    
    if not item then
        print("[DynamicTrading] [ERROR] Failed to spawn item: " .. tostring(itemFullType))
        return nil
    end

    -- 1. DYNAMIC NAME
    local baseName = item:getName()
    item:setName(baseName .. " (" .. tostring(questID) .. ")")

    -- 2. DYNAMIC TOOLTIP
    local tooltip = "Courier Quest: " .. tostring(questID) .. "\n"
    tooltip = tooltip .. "Destination info will be provided by the quest giver."
    item:setTooltip(tooltip)

    -- 3. DYNAMIC WEIGHT
    local baseWeight = item:getActualWeight()
    local newWeight = baseWeight * difficulty
    -- Cap at 50.0 to prevent "bugged action" (ISInventoryTransferAction) when item exceeds container max capacity
    newWeight = math.max(0.1, math.min(50, newWeight))
    
    item:setActualWeight(newWeight)
    item:setCustomWeight(true)

    -- Synchronization for Multiplayer
    if isServer() or isClient() then
        if sendAddItemToContainer then
            sendAddItemToContainer(inventory, item)
        end
    end
    
    local modData = item:getModData()
    modData.QuestID = questID
    modData.Timestamp = getGameTime():getWorldAgeHours()
    modData.IsQuestItem = true
    
    if isDebugEnabled() then
        print("[DynamicTrading] Dynamic Quest Item Generated: " .. itemFullType)
        print("  - Name: " .. item:getName())
        print("  - Weight: " .. tostring(newWeight))
    end
    
    return item
end

--- Checks if the player is already carrying any quest-specific item.
-- Used to prevent "hoarding" multiple active courier quests.
-- @param player (IsoPlayer)
-- @return (Boolean)
function Quests.HasActiveQuestItem(player)
    if not player then return false end
    local inventory = player:getInventory()
    local items = inventory:getItems()
    
    for i=0, items:size()-1 do
        local item = items:get(i)
        if item:getModData().IsQuestItem then
            return true
        end
    end
    return false
end

--- Validates if an item is the correct one for a specific quest.
-- @param item (InventoryItem)
-- @param requiredQuestID (String)
-- @return (Boolean)
function Quests.ValidateDelivery(item, requiredQuestID)
    if not item then return false end
    local modData = item:getModData()
    
    if modData.IsQuestItem and modData.QuestID == requiredQuestID then
        return true
    end
    
    return false
end

print("[DynamicTrading] Quest Manager initialized.")
