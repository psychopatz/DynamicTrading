-- =============================================================================
-- DYNAMIC TRADING: WALLET SYSTEM (SERVER SIDE)
-- =============================================================================

local Commands = {}

-- =============================================================================
-- 1. NETWORK HELPERS (SP & MP COMPATIBLE)
-- =============================================================================
-- These functions check if we are in MP (isServer) or SP.
-- If MP, they send the required sync packets.
-- If SP, they just do the action locally (since there is no server to sync to).

local function ServerRemoveItem(item)
    if not item then return end
    local container = item:getContainer()
    if not container then return end
    
    -- 1. Perform the action (Updates Server/SP State)
    container:DoRemoveItem(item)
    
    -- 2. Sync to Client (Only needed in Multiplayer)
    if isServer() then
        sendRemoveItemFromContainer(container, item)
    end
end

local function ServerAddItem(container, fullType, count)
    if not container or not fullType then return end
    local qty = count or 1
    
    -- 1. Perform the action (Updates Server/SP State)
    -- AddItems returns a Java ArrayList of the items created
    local newItems = container:AddItems(fullType, qty)
    
    -- 2. Sync to Client (Only needed in Multiplayer)
    if isServer() and newItems then
        for i=0, newItems:size()-1 do
            local item = newItems:get(i)
            sendAddItemToContainer(container, item)
        end
    end
end

-- =============================================================================
-- 2. CALCULATION LOGIC
-- =============================================================================
local function CalculateWalletContents(player)
    local minCash = SandboxVars.DynamicTrading.WalletMinCash or 1
    local maxCash = SandboxVars.DynamicTrading.WalletMaxCash or 300
    local emptyChance = SandboxVars.DynamicTrading.WalletEmptyChance or 20
    local jackpotChance = SandboxVars.DynamicTrading.WalletJackpotChance or 5.0

    -- Roll for Empty
    if ZombRand(100) < emptyChance then
        return 0, "EMPTY"
    end

    local amount = 0
    local resultType = "NORMAL"

    -- Roll for Jackpot
    if ZombRandFloat(0.0, 100.0) <= jackpotChance then
        local bonus = ZombRandFloat(0.8, 1.5)
        amount = math.floor(maxCash * bonus)
        resultType = "JACKPOT"
    else
        -- Weighted Roll
        local roll = ZombRand(100)
        if roll < 60 then
            amount = ZombRand(minCash, math.floor(maxCash * 0.3))
        elseif roll < 90 then
            amount = ZombRand(math.floor(maxCash * 0.3), math.floor(maxCash * 0.7))
        else
            amount = ZombRand(math.floor(maxCash * 0.7), maxCash)
        end
        resultType = "MONEY"
    end

    if amount < 1 then amount = 1 end
    return amount, resultType
end

-- =============================================================================
-- 3. COMMAND HANDLER
-- =============================================================================
function Commands.OpenWallet(player, args)
    local walletItem = args.item
    local inv = player:getInventory()
    
    -- Find the true Server-side object
    local serverItem = inv:getItemById(walletItem:getID())
    
    if not serverItem then 
        print("[DynamicTrading] Warning: Wallet item not found on server.")
        return 
    end

    -- A. CALCULATE LOOT FIRST
    local totalMoney, type = CalculateWalletContents(player)

    -- B. REMOVE WALLET
    -- We use the helper to ensure MP Clients get the "delete" packet
    ServerRemoveItem(serverItem)

    -- C. ADD MONEY
    -- We use the helper to ensure MP Clients get the "add" packet
    if totalMoney > 0 then
        local bundles = math.floor(totalMoney / 100)
        local looseCash = totalMoney % 100

        if bundles > 0 then 
            ServerAddItem(inv, "Base.MoneyBundle", bundles)
        end
        if looseCash > 0 then 
            ServerAddItem(inv, "Base.Money", looseCash)
        end
    end

    -- D. SEND FEEDBACK TO CLIENT (Visuals/Audio)
    local resultArgs = {
        total = totalMoney,
        type = type
    }

    if isServer() then
        -- MULTIPLAYER: Send the packet over the network
        sendServerCommand(player, "DynamicTrading", "WalletResult", resultArgs)
    else
        -- SINGLEPLAYER: 'sendServerCommand' doesn't loop back automatically in SP.
        -- We must manually trigger the event so the Client-side script receives it.
        triggerEvent("OnServerCommand", "DynamicTrading", "WalletResult", resultArgs)
    end
end

-- =============================================================================
-- 4. EVENT LISTENER
-- =============================================================================
local function OnClientCommand(module, command, player, args)
    if module == "DynamicTrading" and Commands[command] then
        Commands[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)

print("[DynamicTrading] Server: Wallet System Loaded (MP/SP Compatible).")