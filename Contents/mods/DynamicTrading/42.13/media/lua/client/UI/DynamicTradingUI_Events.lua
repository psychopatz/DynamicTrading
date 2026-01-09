require "DT_DialogueManager"

-- 1. DATA SYNC (Global Mod Data updates)
local function OnDataSync(key, data)
    if key == "DynamicTrading_Engine_v1.1" then
        if DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            DynamicTradingUI.instance:populateList()
        end
    end
end
Events.OnReceiveGlobalModData.Add(OnDataSync)

-- 2. SERVER COMMAND HANDLING (Transaction Results)
local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end

    if command == "TransactionResult" then
        local ui = DynamicTradingUI.instance
        if not ui or not ui:isVisible() then return end
        
        -- Reset Idle Timer
        if ui.resetIdleTimer then ui:resetIdleTimer() end

        -- Fetch Trader
        local trader = DynamicTrading.Manager.GetTrader(ui.traderID, ui.archetype)
        if not trader then return end

        local srvItemName = args.itemName or "Unknown Item"
        local srvPrice = args.price or 0
        local actionType = ui.isBuying and "Buy" or "Sell"

        -- ==========================================================
        -- "LAST STOCK" DETECTION LOGIC
        -- ==========================================================
        -- We scan the CURRENT listbox (which represents the state BEFORE this buy)
        -- to see if the quantity was 1.
        local wasLastOne = false
        
        if ui.isBuying and args.success then
            for i=1, #ui.listbox.items do
                local row = ui.listbox.items[i]
                -- Match by name and ensure it's a Buyable item
                if row.item and row.item.name == srvItemName and row.item.isBuy then
                    if row.item.qty <= 1 then
                        wasLastOne = true
                    end
                    break -- Found it, stop looking
                end
            end
        end

        -- Prepare arguments for Dialogue Manager
        local diagArgs = {
            itemName = srvItemName,
            price = srvPrice,
            success = args.success,
            wasLastOne = wasLastOne -- [NEW] Pass the flag
        }

        if args.success then
            -- 1. [SFX]
            local player = getSpecificPlayer(0)
            if player then
                getSoundManager():PlaySound("DT_Cashier", false, 1.0)
                getSoundManager():PlaySound("DT_RadioClick", false, 0.5)
            end

            -- 2. [PLAYER DIALOGUE] (Right Side, Cyan)
            -- Logic inside DialogueManager now checks diagArgs.wasLastOne
            -- to switch to "BuyLast" lines if needed.
            local playerMsg = DynamicTrading.DialogueManager.GeneratePlayerMessage(actionType, diagArgs)
            ui:logLocal(playerMsg, false, true)

            -- 3. [TRADER DIALOGUE] (Left Side, Grey)
            -- Logic inside DialogueManager now checks diagArgs.wasLastOne
            -- to switch to "LastStock" replies if needed.
            local traderMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, ui.isBuying, diagArgs)
            ui:logLocal(traderMsg, false, false)

            -- 4. [SYSTEM LOG] (Left Side, Colored)
            local auditMsg = ""
            if ui.isBuying then
                auditMsg = "Purchased: " .. srvItemName .. " (-$" .. srvPrice .. ")"
            else
                auditMsg = "Sold: " .. srvItemName .. " (+$" .. srvPrice .. ")"
            end
            ui:logLocal(auditMsg, false, false)
            
            -- 5. Refresh List
            ui:populateList()

        else
            -- FAILURE HANDLING
            local srvMsg = args.msg or ""
            
            if string.find(srvMsg, "Sold Out") then
                diagArgs.failReason = "SoldOut"
            elseif string.find(srvMsg, "Not enough cash") then
                diagArgs.failReason = "NoCash"
            else
                diagArgs.failReason = "Generic"
            end
            
            -- Player Intent
            local playerMsg = DynamicTrading.DialogueManager.GeneratePlayerMessage(actionType, diagArgs)
            ui:logLocal(playerMsg, false, true) 
            
            -- Trader Refusal
            local failMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, true, diagArgs)
            ui:logLocal(failMsg, true, false) -- isError = true
            
            -- Force refresh
            ui:populateList()
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)