-- =============================================================================
-- DYNAMIC TRADING: WALLET SYSTEM (SERVER SIDE)
-- =============================================================================

require "DT/Common/ServerHelpers"

local Commands = {}
local Helpers = DynamicTrading.ServerHelpers

-- =============================================================================
-- 1. CALCULATION LOGIC
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
-- 2. COMMAND HANDLER
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

    -- B. REMOVE WALLET (using shared helper)
    Helpers.RemoveItem(serverItem)

    -- C. ADD MONEY (using shared helper)
    if totalMoney > 0 then
        local bundles = math.floor(totalMoney / 100)
        local looseCash = totalMoney % 100

        if bundles > 0 then 
            Helpers.AddItem(inv, "Base.MoneyBundle", bundles)
        end
        if looseCash > 0 then 
            Helpers.AddItem(inv, "Base.Money", looseCash)
        end
    end

    -- D. SEND FEEDBACK TO CLIENT (using shared helper)
    local resultArgs = {
        total = totalMoney,
        type = type
    }
    Helpers.SendResponse(player, "DynamicTrading", "WalletResult", resultArgs)
end

-- =============================================================================
-- 3. EVENT LISTENER
-- =============================================================================
local function OnClientCommand(module, command, player, args)
    if module == "DynamicTrading" and Commands[command] then
        Commands[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)

print("[DynamicTradingCommon] Registered wallet system.")
