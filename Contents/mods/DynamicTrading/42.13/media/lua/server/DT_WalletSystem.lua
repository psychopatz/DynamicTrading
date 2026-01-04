if isClient() then return end

local Commands = {}

-- =============================================================================
-- CALCULATION LOGIC
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
-- COMMAND HANDLER
-- =============================================================================
function Commands.OpenWallet(player, args)
    local walletItem = args.item
    local inv = player:getInventory()
    local serverItem = inv:getItemById(walletItem:getID())
    
    -- Safety Check
    if not serverItem then return end

    -- 1. Remove Wallet
    inv:Remove(serverItem)

    -- 2. Calculate
    local totalMoney, type = CalculateWalletContents(player)

    -- 3. Add Items
    if totalMoney > 0 then
        local bundles = math.floor(totalMoney / 100)
        local looseCash = totalMoney % 100

        if bundles > 0 then inv:AddItems("Base.MoneyBundle", bundles) end
        if looseCash > 0 then inv:AddItems("Base.Money", looseCash) end
    end

    -- 4. Sync Inventory
    player:sendObjectChange("addItem")
    player:sendObjectChange("removeItem")

    -- 5. Send Result to Client
    sendServerCommand(player, "DynamicTrading", "WalletResult", {
        total = totalMoney,
        type = type
    })
end

local function OnClientCommand(module, command, player, args)
    if module == "DynamicTrading" and Commands[command] then
        Commands[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)