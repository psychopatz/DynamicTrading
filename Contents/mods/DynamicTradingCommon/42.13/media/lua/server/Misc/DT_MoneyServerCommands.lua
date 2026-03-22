-- [DYNAMIC TRADING] Money Server Commands
-- Handles currency conversion (Bundling/Unbundling) securely on the Server.
-- Compatible with Singleplayer (Internal Server) and Multiplayer.

require "DT/Common/ServerHelpers/ServerHelpers"

local Commands = {}
local Helpers = DynamicTrading.ServerHelpers

-- =============================================================================
-- 1. COMMAND LOGIC
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
    for i = 0, moneyList:size() - 1 do
        table.insert(itemsToProcess, moneyList:get(i))
    end

    local totalMoney = #itemsToProcess
    local bundlesToMake = math.floor(totalMoney / 100)
    
    if bundlesToMake > 0 then
        local countToRemove = bundlesToMake * 100
        
        -- Remove exact amount (using shared helper)
        for i = 1, countToRemove do
            Helpers.RemoveItem(itemsToProcess[i])
        end
        
        -- Add bundles (using shared helper)
        Helpers.AddItem(inv, "Base.MoneyBundle", bundlesToMake)
        
        player:setHaloNote("Bundled $" .. countToRemove .. " into " .. bundlesToMake .. " Rolls", 0, 255, 0, 300)
        DynamicTrading.Log("DTCommons", "Money", "Server", "Player " .. tostring(player:getUsername()) .. " compressed " .. countToRemove .. " cash.")
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
    for i = 0, bundleList:size() - 1 do
        table.insert(itemsToProcess, bundleList:get(i))
    end

    local bundleCount = #itemsToProcess
    
    if bundleCount > 0 then
        -- 3. Remove all bundles (using shared helper)
        for _, item in ipairs(itemsToProcess) do
            Helpers.RemoveItem(item)
        end

        -- 4. Add loose money (100 per bundle) (using shared helper)
        local cashToAdd = bundleCount * 100
        Helpers.AddItem(inv, "Base.Money", cashToAdd)

        player:setHaloNote("Unwrapped " .. bundleCount .. " Rolls into $" .. cashToAdd, 0, 255, 0, 300)
        DynamicTrading.Log("DTCommons", "Money", "Server", "Player " .. tostring(player:getUsername()) .. " uncompressed " .. bundleCount .. " bundles.")
    end
end

-- =============================================================================
-- 2. EVENT LISTENER
-- =============================================================================

local function OnClientCommand(module, command, player, args)
    -- This event fires in SP (Internal Server) and MP (Dedicated/Host).
    if module == "DT_Money" and Commands[command] then
        Commands[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
DynamicTrading.Log("DTCommons", "Init", "Server", "Registered server command: CompressMoney")
DynamicTrading.Log("DTCommons", "Init", "Server", "Registered server command: UncompressMoney")

