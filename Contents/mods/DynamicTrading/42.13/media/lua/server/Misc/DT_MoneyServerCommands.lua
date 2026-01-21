-- [DYNAMIC TRADING] Money Server Commands
-- Handles currency conversion (Bundling/Unbundling) securely on the Server.
-- Compatible with Singleplayer (Internal Server) and Multiplayer.

local Commands = {}

-- =============================================================================
-- 1. LOCAL HELPERS (Network Sync)
-- =============================================================================

local function ShouldSendNetworkPackets()
    -- in SP, isServer() is false, so we don't send packets (correct behavior).
    -- in MP, isServer() is true, so we sync changes to clients.
    return isServer()
end

-- Helper to remove a specific item instance and sync it
local function ServerRemoveItem(container, item)
    if not container or not item then return end
    
    container:DoRemoveItem(item)
    
    if ShouldSendNetworkPackets() then
        sendRemoveItemFromContainer(container, item)
    end
end

-- Helper to add items by type and sync them
local function ServerAddItem(container, fullType, count)
    if not container or not fullType then return end
    local qty = count or 1
    
    -- AddItems returns an ArrayList of the created items
    local items = container:AddItems(fullType, qty)
    
    if ShouldSendNetworkPackets() and items then
        for i=0, items:size()-1 do
            local item = items:get(i)
            sendAddItemToContainer(container, item)
        end
    end
end

-- =============================================================================
-- 2. COMMAND LOGIC
-- =============================================================================

-- COMMAND: CompressMoney
-- Description: Converts loose "Base.Money" into "Base.MoneyBundle" (100:1 ratio)
function Commands.CompressMoney(player, args)
    local inv = player:getInventory()
    
    -- 1. Get all loose money items in Main Inventory
    local moneyList = inv:getItemsFromType("Base.Money")
    if not moneyList or moneyList:isEmpty() then 
        return 
    end

    -- 2. Snapshot items (Important: Copy to table to avoid list modification errors)
    local itemsToProcess = {}
    for i=0, moneyList:size()-1 do
        table.insert(itemsToProcess, moneyList:get(i))
    end

    local totalMoney = #itemsToProcess
    local bundlesToMake = math.floor(totalMoney / 100)
    
    if bundlesToMake > 0 then
        local countToRemove = bundlesToMake * 100
        
        -- Remove exact amount
        for i = 1, countToRemove do
            ServerRemoveItem(inv, itemsToProcess[i])
        end
        
        -- Add bundles
        ServerAddItem(inv, "Base.MoneyBundle", bundlesToMake)
        
        player:setHaloNote("Bundled $" .. countToRemove .. " into " .. bundlesToMake .. " Rolls", 0, 255, 0, 300)
        print("[DT-Money] Player " .. tostring(player:getUsername()) .. " compressed " .. countToRemove .. " cash.")
    else
        player:setHaloNote("Not enough cash to bundle (Need 100)", 255, 0, 0, 300)
    end
end

-- COMMAND: UncompressMoney
-- Description: Converts "Base.MoneyBundle" back into "Base.Money" (1:100 ratio)
function Commands.UncompressMoney(player, args)
    local inv = player:getInventory()
    
    -- 1. Get all bundles
    local bundleList = inv:getItemsFromType("Base.MoneyBundle")
    if not bundleList or bundleList:isEmpty() then
        return
    end

    -- 2. Snapshot items
    local itemsToProcess = {}
    for i=0, bundleList:size()-1 do
        table.insert(itemsToProcess, bundleList:get(i))
    end

    local bundleCount = #itemsToProcess
    
    if bundleCount > 0 then
        -- 3. Remove all bundles
        for _, item in ipairs(itemsToProcess) do
            ServerRemoveItem(inv, item)
        end

        -- 4. Add loose money (100 per bundle)
        local cashToAdd = bundleCount * 100
        ServerAddItem(inv, "Base.Money", cashToAdd)

        player:setHaloNote("Unwrapped " .. bundleCount .. " Rolls into $" .. cashToAdd, 0, 255, 0, 300)
        print("[DT-Money] Player " .. tostring(player:getUsername()) .. " uncompressed " .. bundleCount .. " bundles.")
    end
end

-- =============================================================================
-- 3. EVENT LISTENER
-- =============================================================================

local function OnClientCommand(module, command, player, args)
    -- This event fires in SP (Internal Server) and MP (Dedicated/Host).
    if module == "DT_Money" and Commands[command] then
        Commands[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)