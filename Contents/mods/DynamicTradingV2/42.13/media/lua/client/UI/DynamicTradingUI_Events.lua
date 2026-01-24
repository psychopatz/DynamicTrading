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
        local wasLastOne = false
        if ui.isBuying and args.success then
            for i=1, #ui.listbox.items do
                local row = ui.listbox.items[i]
                if row.item and row.item.name == srvItemName and row.item.isBuy then
                    if row.item.qty <= 1 then
                        wasLastOne = true
                    end
                    break 
                end
            end
        end

        -- Prepare arguments for Dialogue Manager
        local diagArgs = {
            itemName = srvItemName,
            price = srvPrice,
            success = args.success,
            wasLastOne = wasLastOne 
        }

        if args.success then
            -- 1. [PLAYER DIALOGUE] (Immediate)
            -- "I'll take that..."
            local playerMsg = DynamicTrading.DialogueManager.GeneratePlayerMessage(actionType, diagArgs)
            -- Delay 0: Shows instantly when you click button
            ui:queueMessage(playerMsg, false, true, 0)

            -- 2. [TRADER DIALOGUE] (~1 Second Later)
            -- "Credits received."
            local traderMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, ui.isBuying, diagArgs)
            -- Delay 60 ticks: Wait for signal travel time
            -- Sound: "DT_RadioRandom" (Defined implicitly in UI processor if no sound arg, 
            -- or explicit here if we want to be safe)
            ui:queueMessage(traderMsg, false, false, 10, "DT_RadioRandom")

            -- 3. [SYSTEM AUDIT LOG] (~0.3 Seconds Later)
            -- "Purchased: Apple (-$10)"
            local auditMsg = ""
            if ui.isBuying then
                auditMsg = "Purchased: " .. srvItemName .. " (-$" .. srvPrice .. ")"
            else
                auditMsg = "Sold: " .. srvItemName .. " (+$" .. srvPrice .. ")"
            end
            -- Delay 20 ticks: Short pause after trader speaks
            -- Sound: "DT_Cashier" (The money actually moving)
            ui:queueMessage(auditMsg, false, false, 10, "DT_Cashier")
            
            -- Refresh List (Happens immediately so logic is secure)
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
            
            -- 1. Player Intent (Immediate)
            local playerMsg = DynamicTrading.DialogueManager.GeneratePlayerMessage(actionType, diagArgs)
            ui:queueMessage(playerMsg, false, true, 0)
            
            -- 2. Trader Refusal (~1 Second Later)
            local failMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, true, diagArgs)
            -- isError = true (Red Text)
            ui:queueMessage(failMsg, true, false, 20, "DT_RadioRandom")
            
            -- Force refresh
            ui:populateList()
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)