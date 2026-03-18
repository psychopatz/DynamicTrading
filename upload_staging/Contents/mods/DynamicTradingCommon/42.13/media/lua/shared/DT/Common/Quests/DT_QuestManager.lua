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
        DynamicTrading.Log("DTCommons", "Error", "Quest", "Failed to spawn item: " .. tostring(itemFullType))
        return nil
    end

    -- 1. DYNAMIC NAME
    local baseName = item:getName()
    item:setName(baseName .. " (" .. tostring(questID) .. ")")

    -- 2. DYNAMIC TOOLTIP
    local tooltip = "Courier Quest: " .. tostring(questID) .. "\n"
    tooltip = tooltip .. "Destination info will be provided by the quest giver.\n"
    tooltip = tooltip .. "Equip in hands to reduce weight by 70%."
    item:setTooltip(tooltip)

    -- 3. DYNAMIC WEIGHT INITIALIZATION
    local targetWeight = item:getActualWeight() * difficulty
    
    local modData = item:getModData()
    modData.QuestID = questID
    modData.Timestamp = getGameTime():getWorldAgeHours()
    modData.IsQuestItem = true
    modData.BaseWeight = targetWeight -- Store the "Full" weight

    -- Apply initial weight (30% reduction if on ground or just spawned to hands)
    -- Hard Engine Cap: Initial spawned weight MUST NOT exceed 50.0kg for "Grab" safety.
    local initialWeight = math.min(50.0, targetWeight * 0.3)
    item:setActualWeight(initialWeight)
    item:setCustomWeight(true)

    -- Synchronization for Multiplayer
    if isServer() or isClient() then
        if sendAddItemToContainer then
            sendAddItemToContainer(inventory, item)
        end
    end
    
    if isDebugEnabled() then
        DynamicTrading.Log("DTCommons", "Quest", "Logic", "Dynamic Heavy Quest Item Generated: " .. itemFullType)
        DynamicTrading.Log("DTCommons", "Quest", "Logic", "  - Base Weight: " .. tostring(targetWeight))
    end
    
    return item
end

--- Recursively finds all quest items in the player's inventory and equipped bags.
-- @param container (ItemContainer)
-- @param results (Table) Map of item -> true
-- @param visited (Table) Map of container -> true (to prevent infinite recursion)
function Quests.ScanContainerForQuestItems(container, results, visited)
    if not container or visited[container] then return end
    visited[container] = true
    
    local items = container:getItems()
    if not items then return end
    
    for i=0, items:size()-1 do
        local item = items:get(i)
        if item then
            local modData = item:getModData()
            if modData and modData.IsQuestItem then
                results[item] = true
            end
            
            -- Defensive check for container/bag logic in B42
            -- Clothes/Belts might not have IsInventoryContainer depending on the subclass/mod
            if item.IsInventoryContainer and item:IsInventoryContainer() then
                local subInv = item:getInventory()
                if subInv then
                    Quests.ScanContainerForQuestItems(subInv, results, visited)
                end
            end
        end
    end
end

--- Returns all quest items currently carried by the player (in hands or bags).
function Quests.GetAllQuestItemsOnPlayer(player)
    local results = {}
    if not player then return results end
    
    local visited = {}
    -- 1. Scan main inventory
    Quests.ScanContainerForQuestItems(player:getInventory(), results, visited)
    
    return results
end

--- Updates the weight of a specific quest item based on location/equip status.
function Quests.UpdateItemWeight(item, isOnPlayer)
    if not item then return end
    local modData = item:getModData()
    if not modData.IsQuestItem or not modData.BaseWeight then return end
    
    -- In B42, isEquipped might be case sensitive too depending on the build
    local isEquipped = false
    if item.isEquipped then
        isEquipped = item:isEquipped()
    end
    
    -- Multiplier 0.3 (70% reduction) if:
    -- 1. Equipped in hands (Primary or Secondary)
    -- 2. NOT on player (Ground/Crate)
    local multiplier = 1.0
    if isEquipped or not isOnPlayer then
        multiplier = 0.3
    end
    
    local targetWeight = modData.BaseWeight * multiplier
    
    -- Hard Engine Cap: The 30% REDUCED weight (Ground/Hands) MUST NOT exceed 50.0kg, 
    -- otherwise the "Grab" action or equipping will fail or bug the character.
    -- Stashed weight (in bags) remains un-capped for realistic difficulty impact.
    if multiplier < 1.0 and targetWeight > 50.0 then
        targetWeight = 50.0
    end
    
    if math.abs(item:getActualWeight() - targetWeight) > 0.01 then
        item:setActualWeight(targetWeight)
        item:setCustomWeight(true)
        if isDebugEnabled() then
            DynamicTrading.Log("DTCommons", "Quest", "Logic", "Weight Sync: " .. item:getName() .. " -> " .. tostring(targetWeight) .. " (Equipped: " .. tostring(isEquipped) .. ", Carried: " .. tostring(isOnPlayer) .. ")")
        end
    end
end

local weightUpdateTick = 0
local itemsInInventory = {} -- Persistent list of quest items in the player's possession for departure tracking

function Quests.OnPlayerUpdate(player)
    weightUpdateTick = weightUpdateTick + 1
    if weightUpdateTick < 30 then return end -- Run roughly every 0.5s @ 60fps
    weightUpdateTick = 0
    
    local currentItems = Quests.GetAllQuestItemsOnPlayer(player)
    
    -- Update weights for items currently carried
    for item, _ in pairs(currentItems) do
        Quests.UpdateItemWeight(item, true)
        itemsInInventory[item] = true -- Register/Keep Registered
    end
    
    -- Check for items that LEFT the player's possession
    for item, _ in pairs(itemsInInventory) do
        if not currentItems[item] then
            -- Item is gone! Revert its weight to ground weight (30%) so it can be picked up.
            Quests.UpdateItemWeight(item, false)
            itemsInInventory[item] = nil -- Unregister
        end
    end
end

--- Immediate weight update on equip.
function Quests.OnEquip(player, item)
    if item and item:getModData().IsQuestItem then
        Quests.UpdateItemWeight(item, true)
    end
end

if not isServer() then
    Events.OnPlayerUpdate.Add(Quests.OnPlayerUpdate)
    Events.OnEquipPrimary.Add(Quests.OnEquip)
    Events.OnEquipSecondary.Add(Quests.OnEquip)
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

DynamicTrading.Log("DTCommons", "Quest", "Logic", "Quest Manager initialized.")
