
require "DT_DialogueManager"

-- 1. DATA SYNC (Global Mod Data updates)
-- This ensures that when the server changes stock or prices, your UI updates.
local function OnDataSync(key, data)
    if key == "DynamicTrading_Engine_v1.1" then
        if DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            DynamicTradingUI.instance:populateList()
        end
    end
end
Events.OnReceiveGlobalModData.Add(OnDataSync)

-- 2. SERVER COMMAND HANDLING (Transaction Results)
-- This is where the server tells us if the Buy/Sell actually worked.
local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end

    if command == "TransactionResult" then
        local ui = DynamicTradingUI.instance
        if not ui or not ui:isVisible() then return end
        
        -- Reset Idle Timer because the player just did something
        if ui.resetIdleTimer then ui:resetIdleTimer() end

        -- Fetch the Trader identity for the dialogue engine
        local trader = DynamicTrading.Manager.GetTrader(ui.traderID, ui.archetype)
        if not trader then return end

        -- [FIX] We now use itemName and price provided by the SERVER args.
        -- This prevents the "null" concatenation crash if the list selection is lost.
        local srvItemName = args.itemName or "Unknown Item"
        local srvPrice = args.price or 0

        -- Prepare arguments for the Dialogue Manager (Flavor Text)
        local diagArgs = {
            itemName = srvItemName,
            price = srvPrice,
            success = args.success
        }

        if args.success then
            -- 1. Success Sound
            getSpecificPlayer(0):playSound("Transaction")
            
            -- 2. Trader Dialogue (Flavor Text)
            local talkMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, ui.isBuying, diagArgs)
            ui:logLocal(talkMsg, false)

            -- 3. System Audit Log (Financial Record)
            -- We use the safe server-provided variables here.
            local auditMsg = ""
            if ui.isBuying then
                auditMsg = "Purchased: " .. srvItemName .. " (-$" .. srvPrice .. ")"
            else
                auditMsg = "Sold: " .. srvItemName .. " (+$" .. srvPrice .. ")"
            end
            ui:logLocal(auditMsg, false)
            
            -- 4. Refresh List to show updated inventory/wallet
            ui:populateList()

        else
            -- FAILURE HANDLING
            -- Determine why it failed based on the server message
            local srvMsg = args.msg or ""
            
            if string.find(srvMsg, "Sold Out") then
                diagArgs.failReason = "SoldOut"
            elseif string.find(srvMsg, "Not enough cash") then
                diagArgs.failReason = "NoCash"
            else
                diagArgs.failReason = "Generic"
            end
            
            -- Trader Dialogue (Refusal message)
            local failMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, true, diagArgs)
            
            -- Log as Error (Red Text)
            ui:logLocal(failMsg, true)
            
            -- Force refresh in case the failure was due to a stock desync
            ui:populateList()
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)